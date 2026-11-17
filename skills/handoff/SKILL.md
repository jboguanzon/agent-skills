---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. **It MUST be saved to the user's OS temporary directory via `$TMPDIR` and nowhere else.** Never write it into the project directory, the user's home directory, or any other location. Resolve the temp directory from the `$TMPDIR` environment variable (or `os.tmpdir()` in code) — on macOS this is typically `${TMPDIR}` under `/var/folders/...`, so do not hardcode `/tmp`. Only deviate from the OS temp directory when the user explicitly specifies a different path; otherwise the temp directory is non-negotiable.

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Include a suggested session title: a short, specific name (roughly 60 characters or less) that the user can give the next session so it is easy to find later. Derive it from the work that will continue, not from the current session's history.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

## Output a copy-pasteable prompt

After saving the document, also print a ready-to-paste raw markdown prompt the user can copy to start the next session. It must be wrapped in a markdown code fence so it can be copied verbatim (including any code blocks inside it). Right before the fence, print one line telling the user they can name the new session with the suggested title using their harness's session naming command (e.g. `/name <title>` in pi). The prompt should:

1. Open with the suggested session title as a plain line, e.g. "Session title: <title>".
2. Name the file to read first, e.g. "Read the handoff at `${TMPDIR}/<filename>`." (The printed prompt must reference the `$TMPDIR`-based path the save used — if the user overrode the location, reference that path instead.)
3. Restate the next session's goal in one or two sentences (from the handoff's purpose).
4. List the suggested skills as `/skill` invocations, one per line.
5. Tell the agent to work through the handoff and confirm once done.

Keep it short — it's a kickoff, not the handoff itself.
