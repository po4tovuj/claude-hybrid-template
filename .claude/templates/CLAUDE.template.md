# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

**Name**: {{PROJECT_NAME}}
**Type**: {{PROJECT_TYPE}}
**Framework**: {{FRAMEWORK}}
**Language**: {{LANGUAGE}}
**Build Tool**: {{BUILD_TOOL}}

## Project Structure

{{PROJECT_STRUCTURE}}

## Development Commands

{{DEV_COMMANDS}}

## Architecture

**Pattern**: {{ARCHITECTURE}}
**Error Handling**: {{ERROR_HANDLING}}
**API Layer**: {{API_LAYER}}
**State Management**: {{STATE_MANAGEMENT}}
**Styling**: {{STYLING}}
**Monorepo**: {{MONOREPO_TOOL}}

## Workflow Commands

### Spec-Driven Development Flow

```
/setup-wizard  →  /constitute  →  /specify  →  /breakdown  →  /execute-task  →  /verify
   (once)          (once)        (per feature)   (auto)        (per task)       (per task)
```

### `/specify "feature description"`
Creates a structured specification with acceptance criteria. Asks clarifying questions, analyzes affected code, saves spec to `specs/`. **Requires approval before proceeding.**

### `/breakdown [spec-file]`
Takes an approved spec and generates ordered, atomic tasks with dependencies and agent assignments. Saves to `todo/`. **Requires approval before execution.**

### `/execute-task [number]`
Executes a single task from the breakdown using the assigned specialized agent. Follows enforced workflow:
1. Pre-flight check (constitution, memory, file state)
2. Agent execution with scope constraints
3. Post-execution verification (tsc, lint, done conditions)
4. Memory update

### `/verify [spec-file]`
Verifies all completed tasks against the spec's acceptance criteria. Performs code review against constitution rules. Updates memory with lessons learned.

### `/constitute`
One-time deep codebase analysis that generates `constitution.md` — non-negotiable rules, architecture decisions, patterns.

### Additional Commands

These commands can be used independently of the spec-driven flow:

- `/setup-wizard` — Re-run initial project setup (regenerates config files)

## Available Agents

{{AGENT_LIST}}

**Agent Selection** is automatic in `/execute-task` based on the task's assigned agent. You can also launch agents directly using the Task tool.

## Enforced Quality Gates

### Hard Gates (block until approved)
- Spec approval → before `/breakdown` can run
- Task breakdown approval → before `/execute-task` can start
- Acceptance criteria → verified in `/verify`

### Automated Guards (run automatically)
- **PostToolUse hook**: Type checking after every file Edit/Write
- **Pre-flight check**: Constitution and memory review before each task
- **Post-execution**: tsc + lint on all changed files after each task

## Key Rules

1. **Read before write** — always read files before modifying them
2. **Constitution is law** — `constitution.md` rules override everything except user instructions
3. **Minimal changes** — every change should impact as little code as possible
4. **Memory is persistent** — check `.claude/memory/MEMORY.md` for lessons from past sessions
5. **Specs are contracts** — once a spec is approved, implementation must satisfy every acceptance criterion
6. **One task at a time** — execute tasks sequentially following the dependency graph
7. **Document new code** — all new functions/variables must have clear documentation
8. **Lint everything** — ESLint/linting must pass on all changed files before task completion

## References

- [Constitution](constitution.md) — Project rules and patterns
- [Specs](specs/) — Feature specifications
- [Tasks](todo/) — Task breakdowns
- [Memory](/.claude/memory/MEMORY.md) — Persistent learnings