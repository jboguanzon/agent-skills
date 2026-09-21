# OVERVIEW.md Format

The course-complete consolidation: the whole topic compressed into one standalone note for quick future reference. Written once, when every node in `PLAN.md` is done and the user has no open questions. Lives at the topic root next to `MISSION.md`. It contains no new material — it is a re-compression of what the lessons already established.

````md
# <Topic> — Overview

<One paragraph: what the topic is and the mission it serves. Link [[MISSION.md]].>

## The roots
<The unconditional truths the whole topic stands on, one line each.>

## <Cluster / decision rule>
<The compressed essence: decision rules, syntax tables, algorithm pseudocode, gotchas — tables over prose.>
<Link each block back to the lesson that introduced it.>

## Glossary
| Term | Meaning |
|---|---|
| ... | ... |

## Where to go next
<One line pointing at lessons/ for the full build-up and reference/ for the per-topic sheets.>
````

Rules:

- Terse and scannable: the user reaches for this mid-task. Tables, one-liners, decision rules — cut narration, analogies, and teaching scaffolding.
- Preserve the dependency order: roots first, then derived material in the order it was taught, so re-reading reconstructs the logic, not just the facts.
- Every section links back to the lesson that introduced it.
- Link it from `MISSION.md` so it is the obvious entry point.
- No new claims: everything here must already be established (and verified) in a lesson.
