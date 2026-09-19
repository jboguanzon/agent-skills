# PR creation format

Follow this structure for the PR title and description. It mirrors the
established format in this repo's PR history.

## Title

One conventional-commit-style line summarizing **all** features the branch
adds — the type (usually `feat:`), then the features in one line, no trailing
period. Read the branch's commit subjects and collapse them into a single
feature list; don't reuse just the last commit's message.

Examples from this repo:

```
feat: add Changing Room, cosmetic buy flow, and Store shop window
feat: store gym grades as ranges, rebuild the request form, and add full request editing
```

## Body

### `## Summary`

A 2–3 sentence paragraph describing the end-to-end feature(s) the branch
implements. Lead with the overall capability, then the moving pieces.

### `## Closes`

One line per issue the branch completes, in issue-number order. Derive the
numbers from `#N` references in the commit messages; look up each issue's
title via `fj issue view N` and use it verbatim.

```
- Closes #8 — Scale mapping becomes grade ranges
- Closes #9 — Gym request form: drag-to-order grades with range editing + custom unit
```

Forgejo auto-closes these issues when the PR merges.

### `## Changes`

Grouped **by issue**, one bold heading per issue with its number, then
file-level bullets describing the actual changes. Base the bullets on the
real diffs (`git show --stat <sha>` per commit, then read the diff for the
key files) — not on commit-subject paraphrases. Name files/functions with
backticks. Keep each bullet to one concrete behavior; nest details under it
where useful. Skip an issue group only if a commit is pure chore/docs that
belongs to no user-facing feature.

```
**Grade ranges (#8)**
- `GradeRange {min, max}` spans on the shared V-scale (V0–V17, open-ended = 17)
  in both `convex/grades.ts` and `src/lib/grades.ts`; custom gyms store
  display→range mappings, point systems store degenerate ranges (min === max)
- ...
```

### `## Verification`

Bullet list of the checks that were **actually run in the session** with their
results — never boilerplate. Typical entries for this repo:

```
- `pnpm lint` — clean
- `npx tsc --noEmit` (root) and `-p convex/tsconfig.json` — clean
- `pnpm test` — N tests passing
- `npx expo export --platform ios` — Metro compiles the screen graph
- No schema change → no migration/codegen
```

If the checks weren't run yet, run them before opening the PR so the section
reports real results.
