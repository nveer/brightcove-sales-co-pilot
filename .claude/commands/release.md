# /release — GOOSE Plugin Release Automation

You are packaging a new release of the GOOSE Claude Code plugin. Execute every step below in order. Do not skip steps. Do not ask clarifying questions unless a step explicitly says to.

---

## Setup — Confirm Paths

The plugin repo root is the directory containing this file's `.claude/` folder. All paths below are relative to that root unless stated otherwise.

Workspace CHANGELOG (staging log) is at:
```
../../../CHANGELOG.md
```
(i.e., `SE_Workspace/CHANGELOG.md` — one level above `plugin-build/se-command-center/`)

Verify both files exist before proceeding:
- `CHANGELOG.md` (plugin changelog)
- `../../../CHANGELOG.md` (workspace staging log)

---

## Step 1 — Read Pending Changes

Read `../../../CHANGELOG.md` (the workspace staging log).

Find the section marked `## 🟡 Pending Changes`. Extract every bullet item listed there. If the section says `*(none)*` or is empty, stop and tell the user: "No pending changes found in the workspace CHANGELOG. Nothing to release."

Present the pending items to the user as a numbered list and ask:
> "I found [N] pending changes. Does this look right? Also — is this a **patch** (bug fixes only), **minor** (new behavior/rules), or **major** (breaking changes) release?"

Wait for confirmation before continuing.

---

## Step 2 — Determine New Version

Read `.claude-plugin/plugin.json` and extract the current `"version"` field.

Apply the version bump the user specified:
- **patch**: increment the third number (1.5.0 → 1.5.1)
- **minor**: increment the second number, reset third (1.5.0 → 1.6.0)
- **major**: increment the first number, reset second and third (1.5.0 → 2.0.0)

Store this as `NEW_VERSION` for all subsequent steps.

---

## Step 3 — Update Version Strings

Update every version reference across the codebase. Use Read + Edit (not bash sed) for each file.

### 3a. `.claude-plugin/plugin.json`
Find the `"version"` field and replace its value with `NEW_VERSION`.

### 3b. `docs/index.html`
Find and replace ALL occurrences of the old version string. There are exactly 6 locations:
1. Topbar `<span>`: `🪿 GOOSE — Your AI Sales Co-Pilot · vX.X.X`
2. First download `href`: `goose-vX.X.X.zip`
3. Second download `href`: `goose-vX.X.X.zip`
4. Hero subtext: `vX.X.X · Requires Claude Desktop`
5. Install step `<code>`: `goose-vX.X.X.zip`
6. Footer: `Your AI Sales Co-Pilot · vX.X.X`

Use `replace_all: true` for the zip filename replacements (they appear twice with identical text).

After editing, grep the file and confirm zero remaining occurrences of the old version string.

---

## Step 4 — Write Changelog Entry

### 4a. Plugin `CHANGELOG.md`
Prepend a new entry at the top (before the previous version's `## vX.X.X` heading).

Format:
```markdown
## vNEW_VERSION — [Month YYYY]

### [Grouped by theme — use emoji headers matching the pending items]

- **[Change title]** — [One-sentence description]
- ...

### 📋 Updated Files
- [List every file changed in this release]

---
```

Use the pending items from Step 1 as the source. Group them logically (Email Triage, Daily Prep, New Features, Bug Fixes, etc.). Write clean, user-facing descriptions — not internal jargon.

### 4b. Workspace staging log (`../../../CHANGELOG.md`)
Find the `## 🟡 Pending Changes` section. Replace its contents with:
```
*(none — all changes packaged into vNEW_VERSION on YYYY-MM-DD)*
```

Then add a new section immediately after:
```markdown
## ✅ Released in vNEW_VERSION (YYYY-MM-DD)

[Copy all the pending items here, preserving their original bullet text]
```

---

## Step 5 — Git Commit and Push

Run these bash commands in sequence from the repo root:

```bash
git add CLAUDE.md commands/email_triage.md .claude-plugin/plugin.json CHANGELOG.md docs/index.html ../../../CHANGELOG.md
```

> Note: Only add files that were actually modified in this release. If a file wasn't changed, omit it from `git add`.

Generate the commit message from the pending items:

```
vNEW_VERSION — [short summary of main theme]

[One bullet per pending change, using the exact text from CHANGELOG]
```

```bash
git commit -m "[generated message above]"
git push origin main
```

Confirm the push succeeded by checking for the `main -> main` line in the output.

---

## Step 6 — Package the Plugin Zip

Run from the **parent directory** of the repo root (i.e., `plugin-build/`):

```bash
cd ..
zip -r "goose-vNEW_VERSION.zip" se-command-center \
  --exclude "*.git*" \
  --exclude "*/.DS_Store" \
  --exclude "*/node_modules/*" \
  --exclude "*/__pycache__/*"
```

Confirm the zip was created and show its file size.

---

## Step 7 — Create GitHub Release

Check if `gh` (GitHub CLI) is available:
```bash
which gh && gh auth status
```

If available and authenticated, run:
```bash
gh release create "vNEW_VERSION" \
  "../goose-vNEW_VERSION.zip" \
  --title "GOOSE vNEW_VERSION — [short summary]" \
  --notes "[Release notes — copy the markdown from the CHANGELOG entry written in Step 4a]"
```

If `gh` is not available or not authenticated, skip this step and tell the user:
> "GitHub CLI not found or not authenticated. To install: `brew install gh && gh auth login`. Or create the release manually at https://github.com/nveer/goose/releases/new — tag `vNEW_VERSION`, attach `goose-vNEW_VERSION.zip`."

---

## Step 8 — Final Summary

Print a clean release summary:

```
✅ GOOSE vNEW_VERSION released

📦 Files updated:
  - .claude-plugin/plugin.json → vNEW_VERSION
  - docs/index.html → 6 version strings updated
  - CHANGELOG.md → new entry prepended
  - [any other files changed]

🔀 Git: committed + pushed to origin/main
📁 Zip: goose-vNEW_VERSION.zip ([size])
🚀 GitHub release: [created / manual step needed]

Next: Install the updated plugin in Claude Desktop by uploading goose-vNEW_VERSION.zip.
```
