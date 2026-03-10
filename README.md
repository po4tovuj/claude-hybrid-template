# Claude Hybrid Template

A spec-driven development template for Claude Code that combines structured specification workflow with enforced execution quality.

## Philosophy

**Spec-kit's intake** (spec → plan → tasks) for scoping + **enforced execution** (approve → implement → verify) for quality.

Every phase transition requires explicit user approval. No step can be skipped.

## Installation

1. Copy the `.claude/` directory to your project root:
   ```bash
   cp -r /path/to/claude-hybrid-template/.claude /path/to/your-project/
   ```

2. Copy the `specs/` and `todo/` directories:
   ```bash
   cp -r /path/to/claude-hybrid-template/specs /path/to/your-project/
   cp -r /path/to/claude-hybrid-template/todo /path/to/your-project/
   ```

3. Open your project in Claude Code and run the setup wizard:
   ```
   /setup-wizard
   ```

4. The wizard will:
   - Detect your project structure automatically
   - Ask clarifying questions about your stack
   - Generate `CLAUDE.md`, `constitution.md`, agents, hooks, and memory
   - Remove the templates directory when done

## Workflow

```
/setup-wizard  →  /constitute  →  /specify  →  /breakdown  →  /execute-task  →  /verify
   (once)          (once)        (per feature)   (auto)        (per task)       (per task)
```

### Phase 0: `/setup-wizard` (one-time)
Interactive wizard that adapts the template to your project. Detects frameworks, testing tools, linting, architecture patterns, and generates all configuration files.

### Phase 1: `/constitute` (one-time)
Deep codebase analysis that produces `constitution.md` — your project's non-negotiable rules, architecture decisions, and quality standards. Persists across all sessions.

### Phase 2: `/specify "feature description"` (per feature)
Takes a natural language feature request, asks clarifying questions, and produces a structured specification with acceptance criteria. Saved to `specs/`.

### Phase 3: `/breakdown` (automatic after specify)
Takes an approved spec and breaks it into ordered, atomic tasks with dependencies and agent assignments. Saved to `todo/`.

### Phase 4: `/execute-task [number]` (per task)
Picks up a task from the breakdown, selects the right specialized agent, and follows the enforced execution workflow with automated quality checks.

### Phase 5: `/verify` (per task)
Code review against the original spec's acceptance criteria, cross-referenced with constitution rules. Updates persistent memory with lessons learned.

## Hard Gates

Every phase transition blocks for user approval:

| Transition | Gate |
|-----------|------|
| setup-wizard → constitute | User confirms generated config |
| constitute → specify | User approves constitution |
| specify → breakdown | User approves spec |
| breakdown → execute | User approves task list |
| execute → verify | Automated hooks must pass |
| verify → done | User confirms acceptance criteria met |

## Automated Guardrails

- **PostToolUse hooks**: Type checking runs after every file edit
- **Persistent memory**: Lessons learned carry across sessions
- **Agent specialization**: Domain-specific agents, not generic ones
- **Minimal changes rule**: Every task touches as little code as possible
- **Mandatory linting**: Must pass before task completion

## Customization

After running `/setup-wizard`, you can manually edit:
- `.claude/agents/*.md` — Add domain-specific knowledge
- `.claude/memory/MEMORY.md` — Pre-seed with known patterns
- `CLAUDE.md` — Adjust workflow steps
- `constitution.md` — Add project-specific rules
- `.claude/settings.json` — Modify hooks and plugins

## Template Files

The `.claude/templates/` directory contains raw templates with `{{PLACEHOLDER}}` variables. These are consumed by `/setup-wizard` and can be deleted after setup.
