#!/usr/bin/env bash
# Writes a scrutinize snapshot and prints the facts Step C dispatches on.
#
# Usage: snapshot.sh working-tree | branch <name> | commit <sha> | base <ref> | replay <sha-ts>
#
# A snapshot is a directory under /tmp/scrutinize/<flattened-repo-path>/<short-sha>-<UTC-ISO>[-N]/:
#   full.diff    the whole diff, for replay and the trigger scan
#   files/       one diff per changed file, at files/<repo-path>.diff
#   index.tsv    one line per changed file: status, diff line count, repo path, per-file diff path
#
# Runs under bash 3.2 (the macOS default), so it uses no associative arrays.
set -euo pipefail

# Paths with non-ASCII characters print as themselves, so diff headers and index paths match the repo.
git() { command git -c core.quotePath=false "$@"; }

mode=${1:?usage: snapshot.sh working-tree | branch <name> | commit <sha> | base <ref> | replay <sha-ts>}
ref=${2:-}

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"
scrutinize_dir="/tmp/scrutinize/$(printf '%s' "$repo_root" | sed 's#^/##; s#/#_#g')"
mkdir -p "$scrutinize_dir"

if [ "$mode" = replay ]; then
  snapshot="$scrutinize_dir/$ref"
  [ -s "$snapshot/full.diff" ] || { echo "scrutinize: snapshot not found: $snapshot" >&2; exit 5; }
else
  short_sha=$(git rev-parse --short HEAD 2>/dev/null || echo nohead)
  snapshot="$scrutinize_dir/${short_sha}-$(date -u +%Y%m%dT%H%M%SZ)"
  # Two runs in the same second get separate directories.
  base_name=$snapshot; suffix=1
  while ! mkdir "$snapshot" 2>/dev/null; do suffix=$((suffix + 1)); snapshot="$base_name-$suffix"; done
  full="$snapshot/full.diff"
  case $mode in
    working-tree)
      if git rev-parse -q --verify HEAD >/dev/null; then base=HEAD; else base=4b825dc642cb6eb9a060e54bf8d69288fbee4904; fi
      git diff "$base" > "$full"
      git ls-files --others --exclude-standard -z | while IFS= read -r -d '' untracked_file; do
        # --no-index exits 1 whenever the files differ, which is every time here.
        git diff --no-index -- /dev/null "$untracked_file" >> "$full" || true
      done
      ;;
    branch)
      [ -n "$ref" ] || { echo "scrutinize: branch mode needs a branch name" >&2; exit 2; }
      main_ref=""
      for candidate in main master origin/HEAD; do
        if git rev-parse -q --verify "$candidate" >/dev/null; then main_ref=$candidate; break; fi
      done
      [ -n "$main_ref" ] || { echo "scrutinize: no main, master, or origin/HEAD to diff $ref against" >&2; exit 4; }
      git diff "$(git merge-base "$main_ref" "$ref")..$ref" > "$full"
      ;;
    commit)
      [ -n "$ref" ] || { echo "scrutinize: commit mode needs a sha" >&2; exit 2; }
      # A merge commit is reviewed against its first parent; git show would print an empty combined diff.
      if git rev-parse -q --verify "$ref^1" >/dev/null; then
        git diff "$ref^1" "$ref" > "$full"
      else
        git show --format= "$ref" > "$full"
      fi
      ;;
    base)
      [ -n "$ref" ] || { echo "scrutinize: base mode needs a ref" >&2; exit 2; }
      git diff "$ref..HEAD" > "$full"
      ;;
    *)
      echo "scrutinize: unknown mode: $mode" >&2; exit 2
      ;;
  esac
  if [ ! -s "$full" ]; then
    rm -rf "$snapshot"
    echo "scrutinize: the diff is empty; there is nothing to review" >&2
    exit 3
  fi

  mkdir -p "$snapshot/files"
  awk -v out="$snapshot/files" -v index_path="$snapshot/index.tsv" '
    function flush() {
      if (file != "") { close(file); printf "%s\t%d\t%s\t%s\n", status, lines, path, file > index_path }
    }
    /^diff --git / {
      flush()
      path = $0; gsub(/"/, "", path); sub(/^.* b\//, "", path)
      file = out "/" path ".diff"
      dir = file; sub(/\/[^\/]*$/, "", dir)
      system("mkdir -p \"" dir "\"")
      status = "M"; lines = 0; in_header = 1
    }
    in_header && /^@@/ { in_header = 0 }
    in_header && /^new file mode/ { status = "A" }
    in_header && /^deleted file mode/ { status = "D" }
    in_header && /^rename from/ { status = "R" }
    file != "" { print > file; lines++ }
    END { flush() }
  ' "$full"

  # Keep the 30 most recent snapshots. The script runs under bash, so no ls alias reaches rm.
  ls -td "$scrutinize_dir"/*/ 2>/dev/null | tail -n +31 | while IFS= read -r old_snapshot; do rm -rf "$old_snapshot"; done
fi

index="$snapshot/index.tsv"

# Test files, by path. Everything else is production code.
test_path_regex='(^|/)(test|tests|spec|specs|__tests__|__test__|Tests)/|\.(test|spec)\.(ts|tsx|js|jsx|mjs|cjs|mts|cts|py|go|rs|java|kt|rb|swift)$|_test\.(go|py)$|(^|/)test_[^/]*\.py$|_spec\.rb$|Tests?\.swift$'

# Security trigger catalog. A changed path matching path_regex, an added code line matching
# code_regex, or an added file under a security or module-boundary directory dispatches security.
path_regex='auth|session|login|signup|password|token|credential|secret|key|jwt|oauth|saml|csrf|cors|middleware|guard|policy|permission|rbac|acl|identity|account|user|iam|principal|\.env|config/secrets|credentials\.'
code_regex='(SELECT|INSERT|UPDATE|DELETE).*\$\{|`.*\$\{.*`.*(query|exec)|exec\(|eval\(|spawn\(|system\(|shell|popen\(|req\.(body|query|params)|request\.(form|args|json)|process\.env|os\.environ|getenv|(api[_-]?key|secret|password|token|jwt|bearer)[[:space:]]*[:=][[:space:]]*["'"'"']|crypto|jwt|bcrypt|argon2|scrypt|md5|sha1|INSERT INTO|UPDATE [A-Za-z_]+ SET|DELETE FROM|\.(insert|upsert|transaction)\('
boundary_dir_regex='(^|/)(api|routes|controllers|services|middleware)/'
prose_file_regex='\.(md|mdx|txt|rst)$'

file_count=0; test_count=0; production_count=0; total_lines=0
path_hits=""; code_hits=""; new_file_hits=""
production_files=""
while IFS="$(printf '\t')" read -r status lines path file_diff; do
  file_count=$((file_count + 1)); total_lines=$((total_lines + lines))
  if printf '%s\n' "$path" | grep -Eq "$test_path_regex"; then
    test_count=$((test_count + 1))
  else
    production_count=$((production_count + 1))
    production_files="$production_files$path
"
  fi
  if printf '%s\n' "$path" | grep -Eq "$path_regex"; then path_hits="$path_hits$path
"; fi
  if ! printf '%s\n' "$path" | grep -Eq "$prose_file_regex" \
    && grep -E '^\+' "$file_diff" | grep -Ev '^\+\+\+ ' | grep -E "$code_regex" >/dev/null; then
    code_hits="$code_hits$path
"
  fi
  if [ "$status" = A ]; then
    path_dir=$(dirname "$path")/
    if printf '%s\n' "$path_dir" | grep -Eq "$boundary_dir_regex|$path_regex"; then new_file_hits="$new_file_hits$path
"; fi
  fi
done < "$index"

# A changed production file has a home for tests when its package (the nearest directory with a
# manifest, or the repo root) holds a test file or declares a test script.
tests_home=""
tests_home_reason=""
if [ "$production_count" -gt 0 ] && [ "$test_count" -eq 0 ]; then
  if [ -f CODING_STANDARDS.md ] && grep -qiE '^#+ .*\btests?\b' CODING_STANDARDS.md; then
    tests_home=yes; tests_home_reason="CODING_STANDARDS.md has a section on tests"
  else
    checked_packages=""
    while IFS= read -r production_file; do
      [ -n "$production_file" ] || continue
      package_dir=$(dirname "$production_file")
      while :; do
        for manifest in package.json Package.swift go.mod pyproject.toml setup.py Cargo.toml Gemfile pom.xml build.gradle build.gradle.kts; do
          [ -f "$package_dir/$manifest" ] && break 2
        done
        [ "$package_dir" = . ] && break
        package_dir=$(dirname "$package_dir")
      done
      case " $checked_packages " in *" $package_dir "*) continue ;; esac
      checked_packages="$checked_packages $package_dir"
      if git ls-files -- "$package_dir" | grep -E "$test_path_regex" >/dev/null; then
        tests_home=yes; tests_home_reason="$package_dir has test files"; break
      fi
      if [ -f "$package_dir/package.json" ] && grep -Eq '"test"[[:space:]]*:' "$package_dir/package.json"; then
        tests_home=yes; tests_home_reason="$package_dir/package.json declares a test script"; break
      fi
    done <<EOF
$production_files
EOF
    if [ -z "$tests_home" ]; then
      tests_home=no; tests_home_reason="no test files or test script in$checked_packages"
    fi
  fi
fi

# Names the first three matching paths (one per line in $1) and counts the rest.
first_paths() {
  printf '%s' "$1" | awk 'NF { count++; if (count <= 3) shown = shown (count > 1 ? " " : "") $0 }
    END { printf "%s", shown; if (count > 3) printf " (and %d more)", count - 3 }'
}
if [ -n "$path_hits" ]; then security_trigger="path: $(first_paths "$path_hits")"
elif [ -n "$new_file_hits" ]; then security_trigger="mandatory-new-file: $(first_paths "$new_file_hits")"
elif [ -n "$code_hits" ]; then security_trigger="code-pattern: $(first_paths "$code_hits")"
else security_trigger=none
fi

echo "snapshot: $snapshot"
echo "index: $index"
echo "files: $file_count (production $production_count, test $test_count)"
echo "diff lines: $total_lines"
echo "security trigger: $security_trigger"
if [ "$production_count" -gt 0 ] && [ "$test_count" -eq 0 ]; then
  echo "zero tests: true"
  echo "tests home: $tests_home ($tests_home_reason)"
else
  echo "zero tests: false"
fi
