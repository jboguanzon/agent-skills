---
name: wayfinder
description: Plan a huge chunk of work (more than one agent session can hold) as a shared map of decision tickets on a tracker (Forgejo by default, or Obsidian notes when asked), and resolve them one at a time until the way to the destination is clear.
disable-model-invocation: true
---

A loose idea has arrived, too big for one agent session, and wrapped in fog: the way from here to the **destination** isn't visible yet. Wayfinding is about finding that way, not charging at the destination. This skill charts the way as a **shared map** on a tracker, then works its **decision tickets** (questions whose resolution is a decision, not slices of a build to execute) one at a time until the route is clear.

The destination varies per effort, and naming it is the first act of charting: it shapes every ticket. It might be a spec to hand off and iterate on, a decision to lock before planning starts, or a change made in place like a data-structure migration. The map is domain-agnostic: engineering work, course content, whatever fits the shape.

## Plan, don't do

Wayfinder is **planning** by default: each ticket resolves a decision, and the map is done when the way is clear, with nothing left to decide before someone goes and does the thing. The pull to just do the work is usually the signal you've reached the edge of the map and it's time to hand off, usually to `/to-tickets`. An effort can override this in its **Notes**, carrying execution into the map itself, but absent that, produce decisions, not deliverables.

## Refer by name

Every map and ticket is an issue or note, so it has a **name**: its title. In everything the human reads (narration, the map's Decisions-so-far), refer to it by that name, never by a bare id, number, or slug. A wall of `#42, #43, #44` is illegible; names read at a glance. A reference carries the id inside a readable name: Forgejo writes `<owner>/<repo>#<id>` as a link, and Obsidian links are `[[<effort-slug>/tickets/01-<ticket-slug>|Ticket title]]`.

## The Map

The map is a single artifact on the effort's tracker: an issue labelled `wayfinder:map` on Forgejo, or a `MAP.md` note at the root of its effort folder in the user's Obsidian vault. Its tickets are the issues whose body opens with a `Parent:` line naming the map, or the notes whose `map:` property points at it.

The map is an **index**, not a store. It lists the decisions made and points at the tickets that hold their detail; a decision lives in exactly one place, its ticket, so the map never restates it, only gists it and links.

## The tracker

One tracker per effort, chosen at chart time. **Forgejo is the default**: use it unless the user explicitly asks for the map in their Obsidian notes. Never split one map across both. An existing map decides by its location: a Forgejo issue URL or number means Forgejo, a folder or `MAP.md` path means Obsidian.

### Forgejo (default)

The repo's Forgejo issue tracker, driven with the `fj` CLI: load the `/forgejo-cli` skill first and follow it. Always pass `-H "$FORGEJO_HOST"` explicitly, and check `fj <cmd> --help` when unsure.

If `$FORGEJO_HOST` is unset or the repo has no Forgejo remote, say so and ask which tracker the user wants before creating anything.

```bash
# one-time per repo: a label that already exists errors, which is harmless
fj -H "$FORGEJO_HOST" repo labels create wayfinder:map "#1d76db"   # labels need a colour
fj -H "$FORGEJO_HOST" repo labels create wayfinder:research "#5319e7"
# likewise wayfinder:prototype, wayfinder:grilling, wayfinder:task

fj -H "$FORGEJO_HOST" issue create "<title>" --body-file <file> # the map, then each ticket
fj -H "$FORGEJO_HOST" issue edit <id> labels --add wayfinder:map
fj -H "$FORGEJO_HOST" issue edit <id> labels --add wayfinder:<type>
fj -H "$FORGEJO_HOST" issue assign <id> "$(fj -H "$FORGEJO_HOST" whoami)"  # the claim
fj -H "$FORGEJO_HOST" issue comment <id> "<answer>"             # the resolution
fj -H "$FORGEJO_HOST" issue close <id>
fj -H "$FORGEJO_HOST" issue edit <id> body "$(cat <file>)"      # rewrite the map body
fj -H "$FORGEJO_HOST" issue search -s open --all                # frontier source
fj -H "$FORGEJO_HOST" issue search -s closed --all              # blocker states
```

`fj issue create` has no label flag, so labels go on in a separate `fj issue edit` call. Keep bodies in files: `--body` with markdown is fragile over the shell, and `fj issue edit <id> body` takes no file flag, so read the file in with `$(cat <file>)`.

**Finding the frontier:** take the open issues, keep those carrying a `wayfinder:<type>` label whose body opens with this map's `Parent:` line, and drop any that are assigned or whose `## Blocked by` entries are all closed. There is no tracker-UI view of this; the query is how the human sees the edge.

### Obsidian notes

Only when the user asks for it ("put the map in my notes", "use Obsidian").

**Vault root.** If `~/.config/wayfinder/vault` exists, its first line is the vault root. Otherwise ask the user which folder to use, create it if needed, and offer to write the answer to that file so later sessions don't ask again. Don't guess a path.

**Layout.** One folder per effort, named for the thing being wayfound, grouped under a `wayfinder/` folder at the vault root so efforts don't clutter it:

```
<vault>/wayfinder/
├── <effort-slug>/          # named for the thing being wayfound, e.g. auth-migration
│   ├── MAP.md              # the map: same five sections as below
│   ├── tickets/            # one note per ticket, numbered by creation order
│   │   ├── 01-<ticket-slug>.md
│   │   └── 02-<ticket-slug>.md
│   └── assets/             # prototype artifacts, diagrams, anything the tickets link
└── <another-effort>/
```

Everything for one effort lives in its own folder: `MAP.md` at the root of it, the tickets it holds in `tickets/`, and what they link in `assets/`. Link by path from the vault root (`[[<effort-slug>/tickets/01-<ticket-slug>|Ticket title]]`): ticket filenames repeat across efforts, so bare filenames collide.

**Ticket notes** carry their state in frontmatter, so the frontier is a folder read, not prose parsing:

```yaml
---
wayfinder: research        # research | prototype | grilling | task
status: open               # open | closed | out-of-scope
map: "[[<effort-slug>/MAP]]"
blocked-by: ["[[<effort-slug>/tickets/01-<ticket-slug>]]"]
assignee:                  # blank = unclaimed
---
```

Above the frontmatter sits the title as the note's H1 (or the filename, Obsidian treats them alike); below it, `## Question`, then `## Resolution` appended on close. Assets are linked from the note (`![[<effort-slug>/assets/file.svg]]`), not pasted in.

- **Claim**: write the dev's name into `assignee` (`$USER`, or the name the user gives) before any work.
- **Frontier**: the notes in the effort's `tickets/` folder with `wayfinder:` set, `status: open`, a blank `assignee`, and every `blocked-by` note at `status: closed`.
- **Resolve**: append `## Resolution`, set `status: closed`, then add the one-line gist to `MAP.md`'s Decisions so far and graduate the fog it cleared.
- **Out of scope**: set `status: out-of-scope` (no `## Resolution`) and list it once in `MAP.md`'s Out of scope.
- **Refer by name**: link tickets as `[[<effort-slug>/tickets/01-<ticket-slug>|Ticket title]]`; in prose use the title, never the filename.

### The map body

The whole map at low resolution, loaded once per session (`MAP.md` itself under Obsidian). Open tickets are **not** listed: they are open issues or notes, found by query.

```markdown
## Destination

<what reaching the end of this map looks like: the spec, decision, or change this effort is finding its way to. One or two lines; every session orients to it before choosing a ticket.>

## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

<!-- the index: one line per closed ticket, enough to judge relevance, then zoom the link for the detail the ticket holds -->

- [<closed ticket title>](link): <one-line gist of the answer>

## Not yet specified

<!-- see "Fog of war": in-scope fog you can't ticket yet; graduates as the frontier advances -->

## Out of scope

<!-- see "Out of scope": work ruled beyond the destination; closed, never graduates -->
```

### Tickets

Each ticket is an issue whose body opens with a `Parent:` line naming the map, or a note whose `map:` property points at `[[<effort-slug>/MAP]]`; that line or property, not a tracker relationship, is what makes it a child. Its body is the question, sized to one 100K token agent session:

```markdown
Parent: <owner>/<repo>#<map id>

## Question

<the decision or investigation this ticket resolves>

## Blocked by

- <owner>/<repo>#<id> — <blocking ticket title>
  <!-- or "None — can start immediately" -->
```

Under Obsidian, drop the `Parent:` line and `## Blocked by` section: the `map:` and `blocked-by` properties carry them, and the body is just `## Question` plus `## Resolution` on close.

Each ticket carries a `wayfinder:<type>` label (Forgejo), or the equivalent `wayfinder:` frontmatter property (Obsidian), one of `research`, `prototype`, `grilling`, `task` (see [Ticket Types](#ticket-types)). `wayfinder:` markers are the only labels a map and its tickets carry, never a triage label like `ready-for-agent`: they are decisions, not implementation work.

A session **claims** a ticket before any work, so concurrent sessions skip it: assign it to the dev driving the map on Forgejo, or write their name into `assignee` in Obsidian. An open, unclaimed ticket is takeable; nothing else marks a claim. `fj whoami` prints the user to assign.

Forgejo, through `fj`, exposes no issue dependency relationship, so blocking is the `## Blocked by` body convention, with real `<owner>/<repo>#<id>` references; Obsidian uses the `blocked-by` property. Either way, a ticket is **unblocked** when every ticket it references there is closed; the **frontier** is the open, unblocked, unclaimed tickets, the edge of the known.

The answer isn't part of the body; it's recorded on resolution as a **resolution comment** on Forgejo, or a `## Resolution` section in the note (see [Work through the map](#work-through-the-map)). Assets created while resolving a ticket are linked from the issue or note, not pasted in.

## Ticket Types

Every ticket is either **HITL** (human in the loop, worked _with_ a human who speaks for themselves) or **AFK**, driven by the agent alone. A HITL ticket only resolves through that live exchange; the agent never stands in for the human's side of it (a grilling agent that answers its own questions has broken this).

- **Research** (AFK): Reading documentation, third-party APIs, or local resources like knowledge bases to surface a fact a decision waits on. Resolved by a fresh context given the ticket body and nothing else, so the findings arrive uncontaminated by the session that wrote the question (use a subagent when the harness provides one, otherwise a separate session). Use when knowledge outside the current working directory is required.
- **Prototype** (HITL): Raise the fidelity of the discussion by making a cheap, rough, concrete artifact to react to (an outline, a rough take, a stub, or throwaway UI/logic code). Link the artifact as an asset; code goes on a throwaway `prototype/<name>` branch that is never merged. Use when "how should it look" or "how should it behave" is the key question.
- **Grilling** (HITL): Conversation. The default case. Run `/grilling` with `/domain-modeling` alongside it, the way `/grill-with-docs` combines them.
- **Task** (HITL or AFK): Manual work that must happen before a _decision_ can be made: nothing to decide, prototype, or research, but the discussion is blocked until it's done. Signing up for a service so its API can be judged, provisioning access, moving data so its shape can be seen. This is the one type that _does_ rather than decides, and it earns its place by unblocking a decision, not by delivering the destination. The agent drives it alone where it can (AFK); otherwise it hands the human a precise checklist (HITL). Resolved when the work is done; the answer records what was done and any resulting facts (credentials location, new URLs, row counts) later tickets depend on.

## Fog of war

The map is _deliberately_ incomplete: don't chart what you can't yet see. Beyond the live tickets lies the **fog of war**: the dim view of decisions and investigations you can tell are coming but can't yet pin down, because they hang on questions still open. Resolving a ticket clears the fog ahead of it, graduating whatever's now specifiable into fresh tickets, one at a time, until the way to the destination is clear and no tickets remain.

The map's **Not yet specified** section is where that dim view is written down: the suspected question, the area to revisit later. It's the undiscovered frontier _toward_ the destination: everything here is in scope, just not sharp enough to ticket. Write as loosely or as fully as the view allows; it doubles as a signpost for collaborators reading where the effort is headed.

**Fog or ticket?** The test is whether you can state the question precisely now, _not_ whether you can answer it now.

- **Ticket when** the question is already sharp, even if it's blocked and you can't act on it yet.
- **Not yet specified when** you can't yet phrase it that sharply. Don't pre-slice the fog into ticket-sized pieces: it's coarser than a ticket, and one patch may graduate into several tickets, or none, once the frontier reaches it.

**Not yet specified** excludes what's already decided (Decisions so far), what's already a live ticket, and what's out of scope (the next section).

## Out of scope

Fog only ever gathers _toward_ the destination. The destination fixes the scope, so work beyond it is **out of scope**: it isn't fog, and it doesn't belong in **Not yet specified**. It gets its own **Out of scope** section on the map: work you've consciously ruled out of _this_ effort. Scope, not sharpness, lands it here.

Out-of-scope work never graduates (the frontier stops at the destination), so it returns only if the destination is redrawn, and then as a fresh effort, not a resumption.

Ruling something out of scope is a scoping act, not a step on the route. When a ticket that already exists turns out to sit past the destination (mis-scoped in while charting, or exposed by a resolution), **close it** (a closed ticket is unambiguously off the frontier; `status: out-of-scope` under Obsidian) and leave one line in the **Out of scope** section: the gist plus why it's out of scope, linking the closed ticket. It stays out of **Decisions so far**, which records the route actually walked; a scope boundary isn't a step on it.

## Invocation

Two modes. Either way, **never resolve more than one ticket per session**, with the exception of research tickets.

### Chart the map

User invokes with a loose idea.

1. **Name the destination.** Run `/grilling` with `/domain-modeling` alongside it (`/grill-with-docs` combines them) to pin down what this map is finding its way to: the spec, decision, or change. The destination fixes the scope, so it's settled first.
2. **Map the frontier.** Grill again, **breadth-first** this time: fan out across the whole space rather than deep on any one thread, surfacing the open decisions and the first steps takeable now. **If this surfaces no fog** (the way to the destination is already clear, the whole journey small enough for one session), you don't need a map. Stop and ask the user how they'd like to proceed.
3. **Create the map** (Forgejo: an issue labelled `wayfinder:map`; Obsidian: `<vault>/wayfinder/<effort-slug>/MAP.md` plus its `tickets/` and `assets/` folders): Destination and Notes filled in, Decisions-so-far empty, the fog sketched into **Not yet specified**.
4. **Create the tickets you can specify now**, each with its parent and blocked-by references (Forgejo: the `Parent:` line and `## Blocked by` list; Obsidian: the `map:` and `blocked-by` properties), then wire the blocking edges in a **second pass** (references need real ids or filenames before they can point at each other). Write cross-references in that pass too, with real ids: a placeholder `#<n>` may auto-link to an unrelated issue on Forgejo, so use the full `<owner>/<repo>#<id>` form, and link Obsidian notes only by their existing filenames. Wiring sorts them into the frontier and the blocked; everything you can't yet specify stays in the fog: the **Not yet specified** section.
5. **Fire the research tickets.** For each `research` ticket you just created, resolve it in a parallel fresh context (a subagent where the harness provides one): capture the findings on a throwaway `research/<name>` branch with a context pointer from the ticket, and push the branch but open no PR: it is never merged.
6. Stop: charting is one session's work; it hand-resolves nothing.

### Work through the map

User invokes with a map (a Forgejo URL or number, or the path to its Obsidian `MAP.md`). A ticket is **optional**: without one, you pick the next decision, not the user.

1. Load the **map**: the low-res view, not every ticket body.
2. Choose the ticket. If the user named one, use it. Otherwise take the first frontier ticket in order. **Claim it** before any work: assign it on Forgejo (`fj -H "$FORGEJO_HOST" issue assign <id> <user>`), or set `assignee` in the note's frontmatter in Obsidian.
3. Resolve it as the type its `wayfinder:<type>` label (or frontmatter property) names (see [Ticket Types](#ticket-types)). Read the label, not just the body: the body never states the type. **Zoom as needed**: fetch the full body of any related or closed ticket on demand; consult whichever skills the `## Notes` block names. If in doubt, run `/grilling` with `/domain-modeling` alongside it.
4. Record the resolution. On Forgejo, post the answer as a **resolution comment** (`fj -H "$FORGEJO_HOST" issue comment <ticket> "<answer>"`) and **close** the issue (`fj -H "$FORGEJO_HOST" issue close <ticket>`); in Obsidian, append `## Resolution` and set `status: closed`. Either way, **append a context pointer** to the map's Decisions-so-far (`fj -H "$FORGEJO_HOST" issue edit <map> body "$(cat <file>)"` on Forgejo; edit `MAP.md` in Obsidian; never rewrite the whole body from scratch).
5. Add newly-surfaced tickets (create-then-wire); graduate any fog the answer has made specifiable, clearing each graduated patch from **Not yet specified** so it lives only as its new ticket. If the answer reveals that a ticket (this one or another) sits beyond the destination, **rule it out of scope** rather than resolving it on the route. If the decision invalidates other parts of the map, update or delete those tickets.

The user may run unblocked tickets in parallel, so expect other sessions to be editing the tracker concurrently.
