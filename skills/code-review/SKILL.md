---
name: code-review
description: Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes — Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/spec asked for?). Run both reviews as independent passes and report them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X". The spec source is passed as an argument (path or URL) or found in the repo.
---

Two-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the originating issue / spec?

Both axes run as **independent passes** so they don't bias each other, then this skill aggregates their findings.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point — a commit SHA, branch name, tag, `main`, `HEAD~5`, etc. If they didn't specify one, use the merge-base with the default branch's remote ref (`origin/HEAD`, falling back to `origin/main`, then `main`) and state the choice; ask only if no default branch resolves.

Capture the diff command once: `git diff <fixed-point>...HEAD` for a fixed point the user named, or `git diff <merge-base>` for the derived one, so uncommitted work is included. Also list commits via `git log <fixed-point>..HEAD --oneline` and untracked files via `git ls-files --others --exclude-standard`, for the commit/file list.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here — not inside the two passes.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. **The spec path/link the user passed** (e.g. `/skill:code-review docs/tickets/feature.md` or a URL). If the user gave a link, fetch it (curl/read) and save the contents to a local file so both passes can reference it.
2. **An issue/ticket ID in the branch name** (e.g. `ABC-123`, `#123`). Resolve it with whatever exists: a tracker CLI or MCP the session has, then any local notes or spec folder named after that ID that the user's instructions point to. Don't hardcode Jira or any vault path. If nothing resolves, fall through to the next source.
3. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.) — fetch them with whatever the repo already has set up (GitHub `gh` CLI, GitLab `glab`, a repo-local issue-tracker doc). If no documented fetch path exists, ask the user to paste the issue text.
4. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
5. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** pass is skipped and the final report notes "no spec available".

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below — a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation — and, like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Run both passes

The two axes must not share conclusions while they're forming, or one masks the other. Prefer real separation:

- **If the harness can spawn sub-agents**, run both reviews as parallel sub-agents using the prompts below — each gets a clean context.
- **Otherwise**, run them sequentially in this session with explicit isolation: complete the **Standards** pass first and write its findings to a scratch file (e.g. `/tmp/code-review-standards.md`) *before* starting the **Spec** pass; the Spec pass must not read the Standards findings until both passes are finished. (Or the reverse order — the point is one pass completes and is parked before the other starts.)

**Standards pass prompt** — include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, **plus the smell baseline from step 3** pasted in full — the pass has no other access to it.
- The brief: "Report — per file/hunk where relevant — (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls — documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec pass prompt** — include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec pass and note this in the final report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings — the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue *within each axis* (if any). Don't pick a single winner across axes — that's the reranking the separation exists to prevent.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other. This should be user-scoped.
