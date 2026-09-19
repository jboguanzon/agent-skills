---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.
disable-model-invocation: true
---

# Grill with Docs

Run a `/grilling` session, using the `/domain-modeling` skill.

## How they combine

- The `/grilling` session drives the interview: design tree, rounds, frontier, question format, and the shared-understanding termination condition all apply unchanged.
- The `/domain-modeling` skill is active throughout: as decisions crystallise during the grilling, resolve terms into `CONTEXT.md` and record decisions as ADRs the moment they're settled — don't wait for the session to end.
- The session is done when the grilling frontier is empty **and** the domain model is up to date: every term that came up is in the glossary, every decision that meets the ADR criteria is recorded.
