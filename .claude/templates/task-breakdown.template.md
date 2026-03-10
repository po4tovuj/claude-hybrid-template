# Task Breakdown: {{FEATURE_NAME}}

**Spec**: {{SPEC_PATH}}
**Generated**: {{DATE}}
**Status**: Pending Approval
**Total tasks**: {{TASK_COUNT}}
**Estimated total files**: {{FILE_COUNT}}

## Dependency Graph

```
<!-- Text representation showing task order -->
<!-- Example:
Task 1 (types) ──→ Task 2 (core) ──→ Task 4 (UI)
                ──→ Task 3 (core) ──→ Task 4 (UI)
                                  ──→ Task 5 (cleanup)
-->
```

## Tasks

### Task 1: {{TITLE}}

**Agent**: {{AGENT}}
**Files**: {{FILES}}
**Depends on**: None
**Blocks**: {{BLOCKED_TASKS}}

**Description**:
{{DESCRIPTION}}

**Change details**:
- In `{{FILE_PATH}}`:
  - {{CHANGE_DESCRIPTION}}

**Done when**:
- [ ] {{CONDITION}}
- [ ] TypeScript compiles without errors
- [ ] ESLint passes on changed files

**Spec criteria addressed**: AC-{{NUMBERS}}

---

<!-- Repeat for each task -->

## Additions to Spec

<!-- Any files or changes discovered during analysis that weren't in the original spec -->

## Risk Assessment

| Task | Risk | Reason |
|------|------|--------|
| | | |