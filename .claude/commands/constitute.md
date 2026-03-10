# /constitute — Generate Project Constitution

You are generating the project's constitution — a persistent document that captures non-negotiable rules, architecture decisions, quality standards, and domain knowledge. This document is referenced by ALL other commands and agents.

## Prerequisites

- `/setup-wizard` must have been run first
- `CLAUDE.md` must exist at project root
- `.claude/agents/` must contain at least one agent

If any prerequisite is missing, inform the user and suggest running `/setup-wizard` first.

## PHASE 1: Deep Codebase Analysis

Perform a thorough analysis of the entire codebase. This is the most important step — the constitution's quality depends on how well you understand the project.

### 1.1: Architecture Mapping

Scan the full source tree and identify:
- **Layer boundaries**: Where does data access live? Business logic? Presentation?
- **Dependency direction**: Which modules import from which? Are there circular dependencies?
- **Entry points**: Main application entry, route definitions, API endpoints
- **Shared code**: Utilities, helpers, shared types/interfaces
- **Configuration**: Environment variables, feature flags, build config

### 1.2: Pattern Extraction

Read 10-15 representative source files across different parts of the codebase and extract:
- **Naming conventions**: camelCase vs snake_case, file naming, component naming
- **Import patterns**: Barrel exports, path aliases, relative vs absolute imports
- **Error handling style**: How are errors created, propagated, and displayed?
- **State management patterns**: How is state structured, updated, and consumed?
- **API patterns**: How are API calls structured? Request/response typing?
- **Testing patterns**: Test file location, naming, setup/teardown patterns
- **Component patterns**: How are UI components structured? Props, events, slots?

### 1.3: Domain Knowledge

Identify domain-specific concepts:
- **Key entities**: What are the core business objects?
- **Workflows**: What are the main user/system workflows?
- **Business rules**: Any validation rules, calculations, or constraints visible in code?
- **External integrations**: Third-party services, APIs, SDKs
- **Authentication/Authorization**: How is auth handled?

### 1.4: Existing Rules

Check for existing code quality rules:
- ESLint/Prettier configuration (read the actual config files)
- TypeScript strict settings
- Pre-commit hooks (`.husky/`, `.githooks/`)
- CI/CD checks (`.github/workflows/`)
- Existing `CONTRIBUTING.md` or `CODE_OF_CONDUCT.md`

## PHASE 2: Draft Constitution

Write `constitution.md` at the project root with the following structure:

```markdown
# Project Constitution — {{PROJECT_NAME}}

Generated: {{DATE}}
Last updated: {{DATE}}

## 1. Project Identity

**Name**: [project name]
**Type**: [frontend/backend/fullstack/library]
**Domain**: [brief domain description]
**Stack**: [key technologies]

## 2. Architecture Rules (NON-NEGOTIABLE)

These rules MUST be followed in every code change. Violating these rules requires explicit user approval.

### 2.1 Layer Boundaries
[Describe the architectural layers and what belongs in each]
[Specify allowed dependency directions]
[List what is FORBIDDEN (e.g., "presentation layer must never import from data layer directly")]

### 2.2 File Organization
[Where new files of each type should be created]
[Naming conventions for files, directories, components]
[File structure within components/modules]

### 2.3 Dependency Rules
[Internal dependency rules between modules/packages]
[Rules about external dependency additions]
[Import ordering and style]

## 3. Code Quality Standards

### 3.1 Type Safety
[TypeScript strict mode requirements]
[Rules about `any`, type assertions, non-null assertions]
[Generated types vs manual types]

### 3.2 Error Handling
[Which pattern to use (Either/try-catch/Result)]
[How to create errors]
[How to propagate errors]
[How to display errors to users]
[What NEVER to do (e.g., "never swallow errors silently")]

### 3.3 Naming Conventions
[Variables, functions, classes, interfaces, types]
[File names, directory names]
[Component names, store names, route names]
[Constants, enums]

### 3.4 Testing Requirements
[What must be tested]
[Test file location and naming]
[Minimum coverage expectations]
[Test patterns and anti-patterns]

## 4. Patterns & Anti-Patterns

### 4.1 ALWAYS Do
[List of required patterns extracted from codebase]
- Example: "Always use `computed()` for derived state in Vue components"
- Example: "Always handle both Left and Right cases when using Either"

### 4.2 NEVER Do
[List of forbidden patterns]
- Example: "Never use `any` type — use `unknown` and narrow"
- Example: "Never mutate state directly — use store actions"
- Example: "Never commit `.env` files"

### 4.3 PREFER
[List of preferred approaches when multiple options exist]
- Example: "Prefer composition over inheritance"
- Example: "Prefer named exports over default exports"

## 5. Domain Rules

### 5.1 Key Entities
[List core domain objects and their relationships]

### 5.2 Business Rules
[Critical business logic that must be preserved]
[Validation rules]
[Calculation rules]

### 5.3 External Contracts
[API contracts that must not break]
[Third-party integration constraints]
[Authentication/authorization rules]

## 6. Workflow Rules

### 6.1 Minimal Changes
Every code change MUST impact as little code as possible. Do not refactor, improve, or "clean up" code outside the scope of the current task.

### 6.2 Semantic Understanding
Before renaming or replacing any identifier, VERIFY:
1. What the identifier semantically means
2. All callers/consumers of the identifier
3. That the new name correctly represents the concept

### 6.3 Deprecation Handling
[How to handle deprecated fields/methods/APIs in this project]

### 6.4 Documentation
[What must be documented]
[Where documentation lives]
[Documentation format]
```

## PHASE 3: User Review

Present the draft constitution to the user with a summary of key decisions. Highlight anything you're uncertain about.

**HARD GATE**: The constitution MUST be approved by the user before it becomes active. Save it to `constitution.md` and explicitly ask:

"I've generated the project constitution at `constitution.md`. Please review it, especially the NON-NEGOTIABLE rules in Section 2 and the NEVER DO list in Section 4.2. These will be enforced in all future tasks. Should I make any changes?"

## PHASE 4: Integrate

After approval:
1. Update `.claude/memory/MEMORY.md` with a link to the constitution
2. Verify that `CLAUDE.md` references the constitution
3. Confirm that all agents can access the constitution path

## IMPORTANT RULES

1. **Extract, don't invent** — every rule in the constitution must be backed by evidence from the codebase
2. **Be specific** — "follow best practices" is useless. "Use `Either<Error, T>` for all repository return types" is useful
3. **Prioritize** — put the most impactful rules first in each section
4. **Keep it scannable** — bullet points, not paragraphs. Developers skim, they don't read essays
5. **Include examples** — for every ALWAYS/NEVER/PREFER rule, include a concrete code example from the project