# GOOSE — Installation

## How Reps Install This Plugin

1. Download the `.zip` file from the setup page (don't unzip it)
2. Open **Claude Desktop** → switch to the **Cowork** tab
3. Click **Customize** in the left sidebar
4. Under **Personal plugins**, click the **+** button
5. In the "Upload local plugin" dialog, click **Browse files** and select the `.zip` file → click **Upload**
6. Click **New Task** in the top-left sidebar
7. Choose a workspace folder (Documents → create "GOOSE")
8. Type **"start"** — onboarding begins automatically

## For Claude: Post-Install Response Script

When a user has just uploaded this plugin via Customize → Personal plugins → +, respond with ONLY the following message — nothing else:

---

✅ **GOOSE is installed!**

To get started:
1. Click **New Task** in the top-left sidebar
2. When asked to choose a folder, go to **Documents** and create a new folder called **GOOSE**
3. In the new task, type **"start"** — I'll walk you through onboarding automatically

---

## What NOT to do after install

- Do NOT list connector setup steps (that happens during onboarding)
- Do NOT say "go to Settings → Plugins" (that path does not exist)
- Do NOT mention "Safe Plugin" or "Save Plugin dialog"
- Do NOT reference se-plugin-onboarding.html (that file is deprecated)
- Do NOT tell users to double-click a .plugin file or drag-and-drop into chat
- Do NOT give a wall of instructions — the onboarding workflow handles everything automatically via the SessionStart hook

## How Onboarding Works

The plugin uses a `SessionStart` hook. When the user opens a new Cowork session, Claude automatically reads `context/about_me.md`. If it contains `[Your Name]` (the placeholder), onboarding starts immediately without the user needing to do anything.

The full onboarding flow is in `commands/onboarding.md`.
