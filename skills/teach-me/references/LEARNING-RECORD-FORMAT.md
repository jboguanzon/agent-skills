# Learning Record Format (learning-records/N-<slug>.md)

ADR-style evidence of what the user has **demonstrated** learning. Used to compute the zone of proximal development and to steer what to teach next. Most records are a single paragraph. Number sequentially in the order produced, plain `N-<slug>.md` with no padding — records are a flat chronological log, so the letter-suffix scheme used for lesson supplements does not apply here.

Write one when any of these is true:

1. **Demonstrated genuine understanding of something non-trivial** — not exposure, but evidence they can use it correctly (the evidence goes in the record). Sets a new floor.
2. **Disclosed prior knowledge** — "I already know X" (record the depth claimed) so future sessions don't re-teach it.
3. **A misconception was corrected** — high-value: mark it with a trailing `!` in the title or body. It predicts future stumbling blocks on related topics.
4. **The mission shifted in response to learning** — record and cross-link [[MISSION.md]].

````md
# <short title of what was learned or established> [!]

<1-3 sentences: what was learned and why it matters for future sessions. What is now known (floor) and what it unlocks or rules out.>

**Evidence**: <how it was demonstrated — a quiz answered, an exercise completed, prior experience cited>
**Implications**: <what this changes for future sessions>   # only when non-obvious
````

Rules:

- **Coverage is not learning.** Material merely covered does not qualify; wait for evidence.
- Not a journal: no session-by-session activity logs.
- **Supersession**: when a later record contradicts an earlier one, mark the old record `Status: superseded by record N` rather than deleting — the history of how understanding evolved is itself signal.