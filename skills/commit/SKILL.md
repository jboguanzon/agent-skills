---
name: commit
description: Commit specified files as a conventional commit. Use when the user wants to commit files they specify (e.g. "staged changes", "files in X dir", a specific file).
---

# Commit

Create a git commit of exactly what the user specified, nothing more.

## Workflow

1. **Identify the target** from the user's request: staged changes, a specific file or files, a directory, or the whole repo. If the user specified no target at all, **default to the staged changes** — commit what's already staged.
2. **Stage only that target.** For a directory or file, run `git add <path>`. For staged changes (explicit or defaulted), `git add` nothing new — commit what's already staged.
3. **Review the staged diff** (`git diff --cached`) so the message describes what's actually being committed.
4. **Write a conventional commit message** and commit.
5. **Confirm** the result with `git log --oneline -1`.

## Message rules

- **Conventional Commits format:** `<type>(<scope>): <description>`
- **Imperative mood, present tense:** "add", "fix", "update", "remove" — never past tense ("added", "fixed"). The message should read as a command: *this commit adds foo*.
- **Common types:** `feat` (new feature), `fix` (bug fix), `refactor` (no behavior change), `docs`, `test`, `chore`, `style`, `perf`.
- **Scope** (optional): add it when it genuinely helps, e.g. `feat(web): add sign-in screen` for a change confined to the web app. Skip it when the change spans the whole project.
- **Keep the subject short** — a single concise line. Use a body only when the "why" can't fit in the subject.

## Examples

```
feat: add session finalization flow
fix(api): reject duplicate climb logs
refactor: extract XP calculation into convex/xp.ts
docs: document the admin approval workflow
```

## Notes

- Never amend, force-push, or rewrite history unless the user explicitly asks.
- If a pre-commit hook or lint step fails, report it — don't bypass it silently.
