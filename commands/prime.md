# /prime — Session Startup Command

## Instructions
Perform the following steps to get fully contextualized for this session:

1. **First-run check** — Check if `scripts/.env` exists.
   - If it does NOT exist: tell the user "Welcome to SE Command Center! It looks like this is your first time. Please open **se-plugin-onboarding.html** in your workspace folder for step-by-step setup instructions." Then stop and wait for confirmation before continuing.

2. **List workspace structure** — Run `find . -type f` to see all files and their locations

3. **Read CLAUDE.md** — Understand the workspace purpose, rules, and available commands

4. **Read all context files** — Read everything in `./context/`:
   - `about_me.md` — Who the rep is and how they work
   - `brightcove_overview.md` — Pre-bundled product knowledge
   - `current_accounts.md` — Active accounts (may be empty for new users — that's fine)
   - `output_config.md` — Notion database IDs (auto-populated during onboarding)

5. **Summarize back** — Provide a brief confirmation:
   - The rep's name and role (from about_me.md)
   - Available commands
   - "Ready to assist" confirmation

## Important
- Keep the summary concise — don't waste tokens repeating everything
- Flag anything that looks outdated or needs attention
- If any context files are missing or empty, note that immediately
