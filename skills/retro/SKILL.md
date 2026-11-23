---
name: retro
description: "Conduct a retrospective on a coding session and propose concrete improvements to the agent's environment: navigation pointers, automated checks, coding standards, AGENTS.md, tool economy, and information access."
disable-model-invocation: true
---

The user has asked for a **retrospective**. You are suggesting improvements to the coding agent's **environment** to improve future runs.

## Steps

1. Read the primary sources for the session the user specifies. If they name none, default to the current one. On pi, sessions are JSONL files under `~/.pi/agent/sessions/--<cwd-slug>--/`, where the working directory loses its leading separator and has `/`, `\`, and `:` replaced with `-`; `/session` or `pi --resume` names the file for this one. If the session ran under another harness with its own transcript store (Claude Code keeps them under `~/.claude/projects/<cwd-slug>/*.jsonl`), read that store instead.

2. Look for candidates for improvement in these categories.

- **Navigation**: how easy was it for the agent to find the right files? Are there hidden dependencies between files? Would a **navigation pointer** make it easier? _Use when_ the session took a long time to find a piece of information.
- **Automated checks**: are there automated checks that could catch errors the agent made? Linting, typing, tests, filesystem linters? Read the repo's own check command first (its `package.json`/build-tool `lint`/`check` scripts, its CI workflow), so a check that already exists but sits unwired or silently broken is the finding, not a reinvention. A repo with no **guardrail** (no pre-commit hook and no CI job running its lint/typecheck/test command) is itself a finding: an un-linted repo is a standing missed opportunity, not a neutral default. _Use when_ the agent made a mistake an automated check could have caught, or the repo has no guardrail at all.
- **Coding standards**: should the **review pass** (`/code-review`) be given a new rule to enforce? Should an existing rule be removed or clarified? Classify the violation first: a **mechanical** one (a fixed syntactic pattern, a banned API, an import shape, a file-location rule) gets a deterministic check, full stop: a custom rule in the repo's own linter, a new pre-commit hook, or a new CI job, whichever the repo's language and existing guardrail make cheapest. Default to building the check over writing the rule. Reserve `CODING_STANDARDS.md` (or `CONTRIBUTING.md` where that is the repo's home for it) for genuine **judgement calls** (cross-file consistency, "matches the surrounding style", anything no guardrail could ever substitute for). _Use when_ the review pass failed to catch a mistake.
- **AGENTS.md**: are there steering instructions that should move to coding standards (or automated checks) instead? _Use when_ an AGENTS.md is particularly large, in the repo or in the user's global scope (`~/.pi/agent/AGENTS.md`).
- **Tool economy**: did the agent make expensive tool calls that could be streamlined? Is there any custom tooling (CLIs, MCP servers) that is particularly token-inefficient? _Use when_ the agent made an expensive tool call.
- **No-ops**: look for instructions in steering files that don't modify the agent's behavior. _Use when_ the steering files are large and unwieldy.
- **Information access**: look for opportunities to increase the agent's access to information. Teeing dev server logs, readonly access to third-party services. _Use when_ a crucial piece of information was not available to the agent.

3. Present these candidates to the user, in order of severity.

Write every proposal per the [Writing for agents](#writing-for-agents) rules below.

## Reference

### Implementation vs Review

Remember that all work goes through two stages: implementation and review. The implementation agent has the most **context pressure**. They are responsible for exploration, writing code, and debugging failures.

The review agent has the least context pressure: it receives a diff, so no exploration needed. It often does not need to write code or debug. That is the `/code-review` pass.

This means the review agent should be responsible for imposing coding standards, not the implementation agent.

### Files

You have access to the steering files below:

- `AGENTS.md` (and `CLAUDE.md` where the harness reads that name): pushed into the context window of any agent working in this repo. Use it incredibly sparingly, usually only for **navigation pointers** to other files.
- `CODING_STANDARDS.md`/`CONTRIBUTING.md`: read during review, not implementation. Add **navigation pointers** to docs folders if the standards file grows past about 1,000 lines.
- Docs: use docs as reference files, pointed to by other files. Look for existing docs before writing new ones.
- Skills: use skills for docs (their description sits in the agent's context window) or for user-invoked commands. A new skill in the skills repo must pass `./validate.sh`: `name` equal to its directory, a single-line `description`.
- Session logs: `~/.pi/agent/sessions/` (Claude Code: `~/.claude/projects/`). Read them, don't summarize them into steering files; a log is evidence, not documentation.

### Writing for agents

Every proposal is text an agent will read, so it is judged on behavior, not polish. The default fix is to **delete**, not to explain.

- **No-op test**: delete the sentence and ask whether the agent's behavior changes. If not, it spent context for nothing. A model already knows how to write code; a line restating that is a no-op.
- **No duplication**: nothing stated twice in any form. The same rule in `AGENTS.md` and in a skill means one of them leaves.
- **Context pointers, not content**: an `AGENTS.md` line or skill description is a pointer; its wording decides how reliably the agent follows it. Name the file and the moment to reach for it.
- **Progressive disclosure**: in-file step → in-file reference → disclosed file behind a pointer. Push detail only one branch needs down the ladder.
- **Leading words**: a compact word already in the model's vocabulary (*tight*, *red*, *tracer bullet*) carries more behavior per token than a sentence of explanation. Reuse words the skill already uses.
- **Pruning**: single source of truth; cut sediment (lines no one remembers adding) and sprawl. A document that keeps growing is not getting better.

When a proposal adds a line to a steering file, write that line in its final, pasteable form.
