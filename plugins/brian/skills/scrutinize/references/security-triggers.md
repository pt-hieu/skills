# Security axis trigger catalog

Full regex catalog behind the Step C.3 security trigger. Dispatch `security` if ANY of:

1. Any changed-file path matches the path regex:
   ```
   auth|session|login|signup|password|token|credential|secret|key|jwt|oauth|saml|csrf|cors|middleware|guard|policy|permission|rbac|acl|identity|account|user|iam|principal|\.env|config/secrets|credentials\.
   ```
2. Any added line (`^+` in diff_text, excluding `+++` headers) matches a code-pattern regex:
   ```
   (SELECT|INSERT|UPDATE|DELETE).*\$\{|`.*\$\{.*`.*(query|exec)
   exec\(|eval\(|spawn\(|system\(|shell|popen\(
   req\.(body|query|params)|request\.(form|args|json)
   process\.env|os\.environ|getenv
   (api[_-]?key|secret|password|token|jwt|bearer)\s*[:=]\s*["']
   crypto|jwt|bcrypt|argon2|scrypt|md5|sha1
   ```
3. **Mandatory-Security rule**: any file with `git diff --name-status` status `A` (added) AND (the file is under one of the security-trigger directory tokens above OR the file is under a module-boundary directory `api|routes|controllers|services|middleware`).

When dispatched, record the trigger reason (path / code-pattern / mandatory-new-file) in `axes_dispatched[]` metadata for chat output.
