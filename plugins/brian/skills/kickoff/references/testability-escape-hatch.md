# Task 9 — Testability escape hatch

Disclosed reference for kickoff Task 9 (Design tests). Read this only when `test-designer` fails on testability grounds, or when you need the rationale for Task 9's position in the pipeline.

## Why Test design runs after Challenge

Task 9 runs AFTER Challenge so Challenge's in-place revisions cannot orphan the Test design section (the failure mode plan-verifier exists to catch, commit `cee4f52`). The accepted cost is that Challenge's opus-level reviewers cannot critique the test commitments. The single authorized mitigation is the backward edge below.

## The backward edge (testability failures only)

If `test-designer` returns `verification: FAIL` with findings indicating **untestability of the chosen approach** (the finding `untestable approach — all tests deferred` from its conflict-and-abstinence rules, or test-designer cannot write a regression test that pins the diagnosed root cause), the orchestrator MUST reopen Task 6 (Plan-agent) with the testability concern as input.

Reopening Task 6 **cascades through Tasks 7 (Write the plan file) and 8 (Challenge)** so the on-disk plan file reflects the revised approach before Task 9 re-runs; the doubled Challenge cost is part of the accepted trade-off for testability failures.

This is the only authorized backward edge in the post-Challenge tail, and it is invoked only on testability failures — routine `FAIL` cases (e.g. a Recommended-approach ↔ Critical-file-paths contradiction) are fixed in place and re-invoked, per Task 9's Action.
