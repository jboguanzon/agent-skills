# Teach-Me Verification Tooling

How to verify anything the lesson depends on before it ships. Accuracy beats flow. Read this before verifying code or visuals.

Run every check in a throwaway scratch dir, never in the vault or the user's project. Clean up afterwards:

```bash
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
cd "$scratch"
```

Never install packages into the user's environment (no global pip/npm/cargo installs). Tools below download to their own caches (`uv` cache, npm cache).

## Code execution

Run the snippet as the lesson will present it, capture the output, and include that output in the lesson. If the snippet can't be executed (toolchain missing, network-restricted, too heavy), say so in the lesson: `// reviewed, not executed`.

### Python — via uv

```bash
cd "$scratch"
uv run --isolated --quiet python - <<'EOF'
# snippet here
EOF
```

- `--isolated` skips venv creation; `uv` caches the interpreter. For snippets needing third-party packages, add them as `--with <pkg>`, e.g. `uv run --isolated --with requests --quiet python - <<'EOF'`. Prefer stdlib-only snippets for the lesson; keep `--with` for checks.
- Pin the Python version with `--python 3.12` if the snippet relies on a version-specific behavior.

### JavaScript / TypeScript — node / npx tsx

```bash
node -e '<snippet, or read a scratch file>'       # pure JS
npx --yes tsx file.ts                             # TS — transpiles in a single step, no install
```

### Rust — rustc (single file; avoids cargo's project ceremony)

```bash
rustc -o "$scratch/a.out" file.rs && "$scratch/a.out"
```

For multi-file examples, `cargo run` in a scratch project (`cargo init` in the scratch dir). Compile times are long; time-box.

### Go — go run

```bash
cd "$scratch" && go mod init scratch >/dev/null 2>&1
go run file.go
```

### Sandbox hygiene

- Snippets must not touch the network or the filesystem outside the scratch dir (unless the lesson is explicitly about network/fs behavior — then note it and keep reads to scratch files).
- Time-box every execution; kill anything that hangs.
- If a snippet crashes or behaves differently than the lesson claims, fix the lesson — don't soften the claim.

## Visuals

### Mermaid — default

Write ```` ```mermaid ```` blocks directly in the lesson. Obsidian renders them natively, so there is **no verification step** beyond careful authoring: keep labels short, arrows correct, and layout so a left-to-right `graph TD` reads cleanly. If you can't reason confidently about the structure, prefer a flowchart you can hold in your head over a big diagram you can't.

### SVG — only for spatial/geometric things mermaid can't lay out

Author the SVG file into `<topic>/assets/`, then **verify it by looking at it** before referencing it in a lesson:

```bash
# Option A — macOS QuickLook (simplest)
qlmanage -t -s 1400 -o "$scratch" assets/diagram.svg   # produces "$scratch/diagram.svg.png"

# Option B — headless Chrome (more faithful rendering)
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --screenshot="$scratch/diagram.png" \
  --window-size=1400,900 "file://$PWD/assets/diagram.svg"
```

Then **look at the PNG** (read the file with your vision ability; if the harness has an image-handoff mechanism, use that). Verify:

- Nothing false: wrong arrow direction, misplaced label, wrong containment = failure, even if it looks clean.
- Legible at the size it will render in Obsidian. If it's cramped, prune elements — every extra label makes it harder to read *and* harder to lay out correctly. "If I delete this, is the idea still clear?" Yes → delete.

Ship only verified SVGs. If you can't verify (no vision available), prefer mermaid or a carefully checked ASCII diagram and say the SVG is unverified. Never ship an unverified SVG.

### Diagrams that are just wrong

A decorative diagram that restates the sentence next to it adds noise and a chance to be wrong. When in doubt, don't visualize; a missing picture is cheaper than a false one.

## Fact verification

- Any fact, name, date, formula, or behavior you're not sure of: verify with web search before teaching it.
- Verified sources get annotated entries in `RESOURCES.md` and citation links in the lesson.
- If verification corrects something you already said in this session, say so plainly — quietly papering over it erodes trust.