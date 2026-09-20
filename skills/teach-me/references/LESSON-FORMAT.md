# Lesson Format (lessons/NNNN-<slug>.md)

The primary unit of teaching: one self-contained lesson = one sitting, one tangible win, tied to the mission. Numbers increment in the order produced; gap-fillers get the next number with a `-supp-` infix (`0004-supp-logical-and-operators.md`).

````md
# <Lesson Title>

<Topic> · Lesson NNNN · <date> · <mission link>

## Why this matters
<1-3 sentences tying the lesson to MISSION.md>

## <Concept in dependency order>
<plain-language explanation, built from what the previous lesson established — never from nothing>
<code snippet with inline comments + expected output when applicable>
<mermaid or verified SVG when a picture is clearer>

> [!tip] Analogy
> <one strong analogy when it helps>

## <Next concept>
...

## Self-check

> [!question] Self-check 1 — <topic of the question>
> <question stem — one question that applies or reasons about the material>
>
> 1. <plausible distractor — same style and length as the answer>
> 2. <plausible distractor>
> 3. <correct answer — indistinguishable in style from the distractors>
> 4. <plausible distractor>
>
> > [!success]- Answer
> > <why the correct answer is right and why each distractor misses; markdown supported, multiple lines fine>

## Sources
- <cited links with context; entries live in RESOURCES.md>

## Next
- <link to the next lesson, or "planned: <node>" if not yet written>
````

Rules:

- Re-reading the file reproduces the lesson; assume nothing from chat.
- Ends with 2-3 callout self-check quizzes — plain Obsidian, no plugin; authoring rules under [Self-check quizzes (callouts)](#self-check-quizzes-callouts).
- Recommends one primary source for the user to read themselves when one exists.
- The compressed essence (syntax table, algorithm, glossary) lives in `reference/` too — lessons are revisited rarely, reference documents are.
- Supp lessons additionally state at the top: `> [!warning] Supplementary — fills a gap quiz-gated in lesson NNNN` and link back to it.

## Self-check quizzes (callouts)

Plain-Obsidian callout quizzes; no plugin involved. The question and options render in a `> [!question]` callout; the answer hides in a **collapsed nested callout** (`> [!success]-`) that the reader unfolds to check. Unfolding is the only interactivity — there is no auto-grading, so both the options and the collapsed answer must be authored so the reader can honestly self-check.

### Anatomy

````markdown
> [!question] Self-check 1 — <topic of the question>
> <Question stem — markdown allowed; keep to one line unless a vignette genuinely needs more>
>
> 1. <distractor>
> 2. <distractor>
> 3. <correct answer>
> 4. <distractor>
>
> > [!success]- Answer
> > <Explanation — why the right option is right and why each distractor misses; markdown allowed, multiple lines fine>
````

Note the nesting: `> > [!success]-` (two `>` levels, `-` sign to collapse). In Obsidian the answer callout renders folded until clicked.

### Authoring rules

- Exactly one correct option per question, marked by nothing special in the listing — the answer lives only in the nested callout. Never flag the correct option in the list itself (no bold, no checkmark, no "right"): the list must not leak.
- The answer callout is **collapsed by default** (`> [!success]-`). The reader commits to an answer, then unfolds it.
- **Rotate the correct option's position across questions.** Callouts do not shuffle options, so a fixed position (always 3rd, always last) leaks the answer by position alone.
- The correct answer must be indistinguishable in style, length, and grammatical form from the distractors — no lists or semicolons in one option but not the others. If you can pick the right one cold, rewrite the block.
- Distractors are plausible errors the learner might actually make, not obviously silly ones; which one they pick should diagnose something.
- One clearly correct answer. If two options are both technically true, the answer callout explains the distinction.
- Prefer questions that apply or reason about the material over bare recall.