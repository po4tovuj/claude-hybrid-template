# Changelog

All notable changes to this template will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-17

### Added
- 8 workflow commands: setup-wizard, constitute, clarify, specify, plan, breakdown, execute-task, verify
- 14 specialized agent templates (code-reviewer, qa-engineer, runtime-debugger, tech-writer, frontend-engineer, backend-engineer, architect, db-engineer, devops-engineer, design-auditor, api-designer, performance-analyst, security-reviewer, migration-engineer)
- 6 configuration templates (CLAUDE.md, constitution, spec, memory, settings, storage-rules)
- MCP server integrations (Context7, Chrome DevTools)
- Hard gates at every workflow phase transition
- PostToolUse hooks for automated type checking
- Persistent memory system
- Session continuity via fixed-size sliding window
- Crash recovery with WIP checkpoints
- Greenfield project support
- Template update system (update.sh) with manifest-based file categorization
- install.sh for fresh project installation