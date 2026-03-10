# /execute-task — Execute a Task from Breakdown

Picks up a single task from the breakdown, selects the assigned agent, and executes it with the full enforced workflow.

## Usage
```
/execute-task [task-number]
```

## Arguments
- `$ARGUMENTS` — Task number to execute. If empty, execute the next pending task (lowest number with all dependencies satisfied).

## Prerequisites

1. A task breakdown must exist in `todo/` with approved status
2. The specified task's dependencies must all be completed
3. If dependencies are not met, inform the user which tasks must be completed first

## PHASE 1: Load Task Context

1. Find the most recent task breakdown file in `todo/`
2. Read the specific task (from `$ARGUMENTS` or next pending)
3. Read the linked spec file
4. Read `constitution.md`
5. Read `.claude/memory/MEMORY.md`
6. Read ALL files listed in the task's "Files" section

Verify:
- Task exists and is not already completed
- All dependencies (listed in "Depends on") are marked complete
- The assigned agent matches what's available

## PHASE 2: Pre-Flight Check

Before writing ANY code, verify:

1. **Constitution compliance**: Does the planned change violate any NON-NEGOTIABLE rules?
2. **Memory check**: Does MEMORY.md have any warnings about similar changes?
3. **File state**: Are the target files in the expected state? (No unexpected changes since the breakdown was created)
4. **Type safety**: Read the type definitions involved and verify the change is type-safe on paper

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

1. **Files changed match task scope**: Check `git diff --name-only` against the task's file list. If extra files were changed, investigate why.
2. **TypeScript compiles**: Run `tsc --noEmit` (the PostToolUse hook should catch this, but verify explicitly)
3. **ESLint passes**: Run lint on all changed files
4. **Done conditions met**: Check each "Done when" item from the task

## PHASE 4: Mark Complete

1. Update the task tracking (TaskUpdate → completed)
2. In the breakdown file (`todo/[file].md`), mark the task's done conditions with `[x]`
3. Add a completion note to the breakdown:
   ```
   **Completed**: [date/time]
   **Files changed**: [actual files that changed]
   **Notes**: [any deviations from plan or things to watch]
   ```

## PHASE 5: Report

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

**Spec criteria addressed**: AC-[numbers]

**Next task**: Task [M] — [title] (ready / blocked by Task [X])
```

## PHASE 6: Memory Update

If anything unexpected happened during execution (a gotcha, a pattern discovery, a near-mistake), update `.claude/memory/MEMORY.md` with a concise note.

## IMPORTANT RULES

1. **One task at a time** — never execute multiple tasks in a single command invocation
2. **Scope discipline** — if the agent changes files outside the task scope, revert those changes and investigate
3. **Fail fast** — if pre-flight checks fail, stop immediately. Don't try to work around constitution violations
4. **Agent isolation** — the agent should only know about its task, not the entire breakdown. This prevents scope creep
5. **Verify everything** — trust but verify. Even if hooks ran, run explicit verification after the agent finishes
6. **Track deviations** — if the actual changes differ from the planned changes, document WHY in the breakdown file
