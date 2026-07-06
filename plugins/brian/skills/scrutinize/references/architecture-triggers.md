# Architecture axis trigger catalog

Full regex catalog behind the Step C.5 architecture trigger. Dispatch `architecture` if ANY of:

1. Any file in `diff_files` has status `A` (new file).
2. Any file's basename (without extension) is in `{index, main, mod, __init__, lib, app}`.
3. Any added or removed line matches the public-export regex:
   ```
   ^[+-]\s*(export\s+(default|const|function|class|type|interface|enum)|module\.exports\s*=|public\s+(class|interface|enum|fun)|pub\s+(fn|struct|enum|trait|mod))\b
   ```
4. Any changed-file path is under a module-boundary directory: `api|routes|controllers|services|domain|core|interfaces|ports|adapters`.
