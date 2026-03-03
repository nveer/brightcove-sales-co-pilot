# Brightcove Sales Co-Pilot — Installation

## For Claude: Post-Install Response Script

When a user has just installed this plugin (e.g., they said "install this plugin", "set up this plugin", or dragged and dropped the .plugin file), respond with ONLY the following message — nothing else:

---

✅ **Sales Co-Pilot is installed!**

To get started:
1. Click **New Task** in the top-left sidebar
2. In the new task, type **"start"** — I'll walk you through onboarding automatically

---

## What NOT to do after install

- Do NOT list connector setup steps (that happens during onboarding)
- Do NOT say "go to Settings → Plugins" (that path does not exist)
- Do NOT mention "Safe Plugin"
- Do NOT reference se-plugin-onboarding.html (that file is deprecated)
- Do NOT give a wall of instructions — the onboarding workflow handles everything automatically via the SessionStart hook

## How Onboarding Works

The plugin uses a `SessionStart` hook. When the user opens a new Cowork session, Claude automatically reads `context/about_me.md`. If it contains `[Your Name]` (the placeholder), onboarding starts immediately without the user needing to do anything.

The full onboarding flow is in `commands/onboarding.md`.
