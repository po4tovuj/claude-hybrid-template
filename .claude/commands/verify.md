# /verify — Post-Task Verification

Verifies completed tasks against the original specification's acceptance criteria, performs code review, and updates persistent memory.

## Usage
```
/verify [spec-file]
```

## Arguments
- `$ARGUMENTS` — Optional path to a spec file. If empty, use the most recently modified spec in `specs/`.

## PHASE 1: Load Context

1. Read the spec file (from `$ARGUMENTS` or most recent in `specs/`)
2. Read the corresponding task breakdown in `todo/`
3. Read `constitution.md`
4. Read `.claude/memory/MEMORY.md`

## PHASE 2: Acceptance Criteria Check

For EACH acceptance criterion (AC-N) in the spec:

1. **Identify the task(s)** that addressed this criterion
2. **Read the changed files** and verify the criterion is actually satisfied
3. **Mark status**: PASS / FAIL / PARTIAL

Generate a checklist:

```markdown
## Acceptance Criteria Verification

| AC | Description | Task(s) | Status | Evidence |
|----|-------------|---------|--------|----------|
| AC-1 | [description] | Task [N] | PASS/FAIL | [file:line or explanation] |
| AC-2 | [description] | Task [N] | PASS/FAIL | [file:line or explanation] |
...
```

If ANY criterion is FAIL or PARTIAL:
- Identify what's missing
- Suggest which task needs to be re-executed or a new task to address the gap
- Do NOT attempt to fix it in this command — that's what `/execute-task` is for

## PHASE 3: Code Review

Review ALL files changed across all tasks in the breakdown. Check for:

### 3.1: Constitution Compliance
- Does every change follow the NON-NEGOTIABLE rules?
- Are there any NEVER DO violations?
- Does the code match the ALWAYS DO patterns?

### 3.2: Quality Checks
- **Type safety**: Run `tsc --noEmit` and report result
- **Linting**: Run ESLint on all changed files and report result
- **No leftover artifacts**: Debug logs, TODO comments, commented-out code
- **No scope creep**: Changes outside the spec's scope

### 3.3: Consistency Check
- Do the changes follow the same patterns as existing code in the same area?
- Are naming conventions consistent?
- Is error handling consistent with surrounding code?

### 3.4: Risk Check
- Could any change break existing functionality?
- Are there any null/undefined paths that aren't handled?
- Are there any edge cases from the spec's "Risks" section that aren't addressed?

## PHASE 4: Generate Verification Report

```markdown
## Verification Report

**Spec**: [spec file path]
**Breakdown**: [breakdown file path]
**Date**: [date/time]

### Acceptance Criteria
| AC | Status |
|----|--------|
| AC-1 | PASS/FAIL |
| AC-2 | PASS/FAIL |
...

**Result**: [ALL PASS / X of Y PASS]

### Code Quality
- TypeScript: PASS/FAIL
- ESLint: PASS/FAIL
- Constitution compliance: PASS/FAIL [details if fail]
- No scope creep: PASS/FAIL [details if fail]
- No leftover artifacts: PASS/FAIL [details if fail]

### Issues Found
[List any issues, categorized by severity]

#### Critical (must fix before merge)
- [issue description, file, suggested fix]

#### Warning (should fix, not blocking)
- [issue description, file, suggested fix]

#### Info (nice to have)
- [observation]

### Overall Verdict
[APPROVED / NEEDS WORK / REJECTED]

[If NEEDS WORK: specific tasks that need re-execution or new tasks needed]
[If APPROVED: ready for commit/PR]
```

## PHASE 5: Update Spec Status

If all acceptance criteria pass and code quality checks pass:
1. Update the spec file status to "Complete"
2. Update the breakdown file with a completion summary

If issues found:
1. Keep spec status as "In Progress"
2. Add issues to the breakdown file
3. Suggest next steps

## PHASE 6: Memory Update

Update `.claude/memory/MEMORY.md` with lessons learned from this feature:

- **What went well**: Patterns that worked, good decisions in the spec
- **What went wrong**: Issues discovered during verification, things that should have been caught earlier
- **New patterns**: Any new code patterns introduced that should be followed in future work
- **Pitfalls**: Gotchas discovered that should be avoided in similar work

Keep memory entries concise (1-2 lines each). Link to specific files if relevant.

## PHASE 7: Present Results

Show the user the verification report and recommend next action:

- If APPROVED: "All acceptance criteria are met and code quality checks pass. Ready for `/commit` or PR creation."
- If NEEDS WORK: "Found [N] issues. Recommend re-running `/execute-task [X]` for [reason]. Details in the verification report above."
- If REJECTED: "Critical issues found that require revisiting the spec. [Describe the fundamental problem]."

## IMPORTANT RULES

1. **Verify against spec, not assumptions** — the spec is the contract. If the code does something useful but the spec didn't ask for it, that's scope creep
2. **Be specific about failures** — "AC-2 fails because `orderState.soldToParty` is null when ShippingTypeEnum is SoldTo, but it should return the party data" not "AC-2 fails"
3. **Don't fix during verification** — verification is read-only. If something needs fixing, document it and let `/execute-task` handle it
4. **Memory updates are mandatory** — even if everything passed, record what you learned
5. **Constitution violations are always critical** — never downgrade a constitution violation to "warning"