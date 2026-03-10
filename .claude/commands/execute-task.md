# /execute-task — Execute a Task from Breakdown

Picks up a single task from the breakdown, selects the assigned agent, and executes it with the full enforced workflow.

## Usage
```
/execute-task [task-number]           # task in active feature
/execute-task [feature]/[task]        # explicit feature (e.g. 001/3 or user-auth/3)
```

## Arguments
- `$ARGUMENTS` — Task number to execute, optionally prefixed with feature number or name. If empty, execute the next pending task (lowest number with all dependencies satisfied) from the active feature.

## Prerequisites

1. Task files must exist in `specs/NNN-feature/tasks/`
2. The specified task's dependencies must all be completed (status: Complete)
3. If dependencies are not met, inform the user which tasks must be completed first

## PHASE 1: Load Task Context

### 1.1: Resolve Feature Directory

If `$ARGUMENTS` contains a `/` (e.g. `001/3`, `user-auth/3`):
- Use the part before `/` to match a feature directory in `specs/` (by number prefix or name)
- Use the part after `/` as the task number

If `$ARGUMENTS` is just a number (e.g. `3`):
- Scan all feature directories in `specs/` and find the **active** one — the feature that has incomplete tasks (at least one task not marked Complete)
- If multiple features have incomplete tasks, use the **lowest numbered** one (finish earlier features first)
- If all features are complete, inform the user there are no pending tasks

If `$ARGUMENTS` is empty:
- Same active feature resolution as above, then pick the next pending task (lowest number with all dependencies satisfied)
### 1.2: Load Context

1. Read the task index at `specs/NNN-feature/tasks/README.md`
2. Read the specific task file (e.g., `specs/NNN-feature/tasks/001-title.md`)
3. Read the feature's `spec.md` and `plan.md`
4. Read `constitution.md`
5. Read `.claude/memory/MEMORY.md`
6. Read ALL files listed in the task's "Files" section
7. **Read relevant documentation**: Search `docs/` for files related to the area this task touches. This gives you context about existing behavior, APIs, and patterns before you make changes. Read only docs that are directly relevant — not all docs.

Verify:
- Task exists and is not already completed
- All dependencies (listed in "Depends on") are marked complete
- The assigned agent matches what's available

## PHASE 2: Pre-Flight Check

Before writing ANY code, verify:

1. **Constitution compliance**: Does the planned change violate any NON-NEGOTIABLE rules?
2. **Memory check**: Does MEMORY.md have any warnings about similar changes?
3. **File state check**:
   - **Existing files**: Are the target files in the expected state? (No unexpected changes since the breakdown was created)
   - **New files (greenfield)**: Does the target directory exist? If not, it should be created as part of this task or a prior task
4. **Type safety**: Read the type definitions involved and verify the change is type-safe on paper. For greenfield, verify the proposed types align with the constitution's patterns

If ANY pre-flight check fails, stop and inform the user with specifics.

## PHASE 3: Execute

### 3.1: Create Task Tracking

Use TaskCreate to create a tracking task:
- Subject: Task [N] title from the breakdown
- Description: Full description from the breakdown
- ActiveForm: "Implementing [short description]"

Set it to `in_progress`.

### 3.2: Launch Agent

Use the Task tool to launch the agent specified in the task's "Agent" field.

Provide the agent with:
1. The full task description and change details
2. The relevant section of the spec (acceptance criteria this task addresses)
3. The constitution's relevant rules
4. Any warnings from MEMORY.md
5. The list of files to change
6. Clear instruction: **make ONLY the changes described in this task, nothing more**

The agent prompt should follow this structure:

```
You are executing Task [N] from an approved task breakdown.

## Task
[Full task description from breakdown]

## Files to Change
[List from breakdown]

## Change Details
[Specific changes from breakdown]

## Rules
1. Make ONLY the changes described above — nothing more
2. Follow the project's constitution (key rules: [relevant rules])
3. Known pitfalls for this area: [from MEMORY.md]
4. Every file you change must pass TypeScript compilation
5. Every file you change must pass ESLint
6. Document any new functions/variables you create

## Done When
[Done conditions from breakdown]

## Do NOT
- Refactor surrounding code
- Add features not in the task
- Change files not listed above (unless absolutely necessary for compilation)
- Skip type checking or linting
```

### 3.3: Post-Agent Verification

After the agent completes, verify:

1. **Files changed match task scope**: Check `git diff --name-only` (or `git status` for new files) against the task's file list. If extra files were changed, investigate why.
2. **TypeScript compiles**: Run `tsc --noEmit` (the PostToolUse hook should catch this, but verify explicitly)
3. **ESLint passes**: Run lint on all changed files
4. **Done conditions met**: Check each "Done when" item from the task

## PHASE 4: Mark Complete

1. Update the task tracking (TaskUpdate → completed)
2. In the task file (`specs/NNN-feature/tasks/NNN-title.md`):
   - Change **Status** to `Complete`
   - Mark done conditions with `[x]`
   - Fill in the Completion Notes section:
     ```
     **Completed**: [date/time]
     **Files changed**: [actual files that changed]
     **Notes**: [any deviations from plan or things to watch]
     ```
3. Update the task index (`specs/NNN-feature/tasks/README.md`) — mark this task's status as Complete

## PHASE 5: Documentation Update (MANDATORY)

After code is verified, launch the **tech-writer** agent to update documentation.

Provide the agent with:
1. The completed task file (with completion notes and actual files changed)
2. The feature spec
3. The list of files that were actually changed

The tech-writer will:
- Read only the task, spec, and changed files
- Determine if documentation updates are needed
- Add or update **inline documentation** (JSDoc/docstrings) in changed source files for new/changed public APIs
- Update existing docs or create new ones in `docs/`
- Skip documentation if the change doesn't warrant it (internal refactoring, bug fixes, test-only changes)

If the tech-writer determines no docs are needed, that's fine — not every task produces documentation. But the step MUST run.

## PHASE 6: Report

Provide a concise summary to the user:

```
## Task [N] Complete: [Title]

**Changes**:
- [file]: [what changed, 1 line]
- [file]: [what changed, 1 line]

**Verification**:
- TypeScript: PASS
- ESLint: PASS
- Done conditions: [all met / exceptions]

**Documentation**: [Updated docs/features/X.md / Created docs/api/Y.md / No docs needed]

**Spec criteria addressed**: AC-[numbers]

**Next task**: [NNN]-[title] (ready / blocked by [NNN])
```

## PHASE 7: Memory Update

If anything unexpected happened during execution (a gotcha, a pattern discovery, a near-mistake), update `.claude/memory/MEMORY.md` with a concise note.

## IMPORTANT RULES

1. **One task at a time** — never execute multiple tasks in a single command invocation
2. **Scope discipline** — if the agent changes files outside the task scope, revert those changes and investigate
3. **Fail fast** — if pre-flight checks fail, stop immediately. Don't try to work around constitution violations
4. **Agent isolation** — the agent should only know about its task, not the entire breakdown. This prevents scope creep
5. **Verify everything** — trust but verify. Even if hooks ran, run explicit verification after the agent finishes
6. **Track deviations** — if the actual changes differ from the planned changes, document WHY in the task file's Completion Notes
