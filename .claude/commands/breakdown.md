# /breakdown — Task Breakdown from Specification

Takes an approved specification and breaks it into ordered, atomic tasks with dependencies and agent assignments.

## Usage
```
/breakdown [spec-file]
```

## Arguments
- `$ARGUMENTS` — Optional path to a spec file in `specs/`. If empty, use the most recently modified spec file in `specs/`.

## Prerequisites

1. A spec file must exist in `specs/` with **Status: Approved**
2. If the spec status is still "Draft", inform the user: "This spec hasn't been approved yet. Please review `specs/[file]` and change the status to 'Approved', or run `/specify` to create a new spec."

## PHASE 1: Load Context

Read these files in order:
1. The spec file (from `$ARGUMENTS` or most recent in `specs/`)
2. `constitution.md` — architecture rules and constraints
3. `.claude/memory/MEMORY.md` — past lessons
4. `CLAUDE.md` — project structure and available agents

Verify the spec status is "Approved". If not, stop and inform the user.

## PHASE 2: Deep File Analysis

For every file listed in the spec's "Affected Areas" section:
1. **Read the file** completely
2. **Map its dependencies**: What does it import? What imports it?
3. **Identify the change points**: Exactly which lines/functions/blocks need to change
4. **Estimate scope**: How many lines will change? Is it a simple rename or a logic change?
5. **Check for cascading effects**: Will changing this file require changes in other files not listed in the spec?

If you discover files that should have been in the spec but weren't, note them as additions.

## PHASE 3: Generate Task Breakdown

Create atomic tasks following these rules:

### Task Granularity Rules
- **One task = one logical change** that can be verified independently
- A task should touch **1-3 files** maximum (exception: rename/replace across many files)
- Each task must have a clear **done condition**
- Tasks should take **5-30 minutes** to implement (not hours)
- If a task would take longer, break it into sub-tasks

### Task Ordering Rules
- **Types/interfaces first** — define the data shapes before using them
- **Core/domain before presentation** — business logic before UI
- **Data layer before domain** — repositories before use cases
- **Independent tasks before dependent ones**
- **Riskiest changes first** — catch problems early

### Agent Assignment Rules
Assign each task to the most appropriate agent based on the files it touches:

| Files in... | Agent |
|-------------|-------|
| Core/domain/data layers, business logic, API, types | architect |
| UI components, styles, routes, composables, stores | frontend-engineer |
| Both core + UI (tightly coupled change) | architect first, then frontend-engineer |
| Bug investigation with runtime symptoms | runtime-debugger |

### Task Format

For each task, generate:

```markdown
### Task [N]: [Short imperative title]

**Agent**: [agent name]
**Files**: [list of files to change]
**Depends on**: [task numbers this task requires to be done first, or "None"]
**Blocks**: [task numbers that can't start until this is done]

**Description**:
[Detailed description of what to change and why]

**Change details**:
- In `path/to/file.ts`:
  - [specific change description with line numbers if possible]
  - [another change in same file]
- In `path/to/other.ts`:
  - [specific change]

**Done when**:
- [ ] [Testable condition]
- [ ] [Another testable condition]
- [ ] TypeScript compiles without errors
- [ ] ESLint passes on changed files

**Spec criteria addressed**: AC-[numbers]
```

## PHASE 4: Save the Breakdown

Save the task breakdown to `todo/DD-MM-YYYY-HH-MM-[spec-name].md` (Ukrainian timezone).

### Breakdown File Format:

```markdown
# Task Breakdown: [Feature Name]

**Spec**: [path to spec file]
**Generated**: [date and time]
**Total tasks**: [count]
**Estimated total files**: [count]

## Dependency Graph

[Simple text representation showing task order]
```
Task 1 (types) ──→ Task 2 (core) ──→ Task 4 (UI)
                ──→ Task 3 (core) ──→ Task 4 (UI)
                                  ──→ Task 5 (cleanup)
```

## Tasks

### Task 1: ...
### Task 2: ...
...

## Additions to Spec

[Any files or changes discovered during analysis that weren't in the original spec]
[These should be minor — if major gaps exist, suggest updating the spec first]

## Risk Assessment

| Task | Risk | Reason |
|------|------|--------|
| Task N | High/Med/Low | [why] |
```

## PHASE 5: User Approval

**HARD GATE**: The task breakdown MUST be approved before execution begins.

Present a summary:

"I've broken down the spec into **[N] tasks**:

[List each task: number, title, agent, and dependency info — one line each]

Dependency chain: [simplified graph]

Riskiest tasks: [list high-risk tasks and why]

Please review `todo/[filename].md` and approve. You can:
1. Approve as-is → run `/execute-task 1` to start
2. Request changes → I'll update the breakdown
3. Reject → I'll revisit the spec

Once approved, tasks should be executed in order (dependencies are marked)."

## IMPORTANT RULES

1. **Atomic tasks** — each task must be independently verifiable. Never bundle unrelated changes
2. **Explicit dependencies** — if task B uses types defined in task A, mark it. Missing dependencies cause bugs
3. **Agent per task** — assign ONE agent per task. If a task needs both, split it
4. **Include verification in every task** — every task's "Done when" must include tsc + lint checks
5. **Reference spec criteria** — every task must map to at least one acceptance criterion (AC-N)
6. **All ACs covered** — every acceptance criterion from the spec must be addressed by at least one task
7. **Don't over-split** — a simple find-and-replace across 5 files is ONE task, not five tasks