---
name: review
description: Review code changes for this project. Use when asked to review a branch, commit, file, or PR diff. Covers code quality, Rails conventions, security, performance, test coverage, and Docker/infra changes.
argument-hint: "[commit-sha | file-path]"
disable-model-invocation: true
allowed-tools: Bash(git *)
---

## Usage

- `/review` — reviews all changes on current branch vs main
- `/review <commit-sha>` — reviews a specific commit
- `/review <file-path>` — reviews a specific file's changes

## Instructions

Determine what to review from the arguments:
- No args: run `git diff main...HEAD` for branch changes
- Commit SHA provided: run `git show <sha>`
- File path provided: run `git diff main...HEAD -- <path>`

Then analyze the diff and produce a review with these sections:

### Overview
What the change does in 2-3 sentences.

### Code Quality
- Correctness — does the logic do what it intends?
- Rails conventions — follows ohloh-ui patterns (HAML views, `oh`/`fis` schema namespacing, dotenv config, Minitest tests)?
- Duplication — anything that could reuse existing code?
- Clarity — are names and structure obvious without comments?

### Security
Flag any of: SQL injection, XSS, mass assignment, hardcoded secrets, exposed credentials, insecure direct object references, missing authorization checks. Use Brakeman findings as a reference where relevant.

### Performance
Note N+1 queries, missing indexes, large unbounded queries, or synchronous work that should be backgrounded via Sidekiq.

### Test Coverage
- Are new code paths covered in `test/`?
- Are edge cases and failure paths tested?
- Any tests that should exist but don't?

### Docker / Infrastructure (if applicable)
If the diff touches `Dockerfile*`, `docker-compose*.yml`, `Makefile`, or `docker-entrypoint.sh`, review for: hardcoded credentials, global side-effects (e.g. `docker system prune`), BuildKit settings, layer caching, and shared-network compatibility with other BD services.

### Suggestions
Numbered list of specific, actionable improvements. Lead with the most important.

### Summary
One line: ship as-is / ship with minor fixes / needs rework.
