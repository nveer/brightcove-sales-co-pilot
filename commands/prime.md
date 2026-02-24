# /prime — Session Startup Command

## Instructions
Perform the following steps to get fully contextualized for this session:

1. **First-run check** — Check if `scripts/.env` exists.
   - If it does NOT exist: tell the user "Welcome to SE Command Center! It looks like this is your first time. Please open **se-plugin-onboarding.html** in your workspace folder for step-by-step setup instructions." Then stop and wait for confirmation before continuing.

2. **List workspace structure** — Run `find . -type f` to see all files and their locations

3. **Read CLAUDE.md** — Understand the workspace purpose, rules, and available commands

4. **Read all context files** — Read everything in `./context/`:
   - `about_me.md` — Who you are and how you work
   - `brightcove_overview.md` — Product knowledge
   - `se_team.md` — Gong user IDs and priority rules
   - `current_accounts.md` — Active accounts and status

5. **Check Gong skill** — Confirm `./skills/gong/SKILL.md` is present and readable

6. **Summarize back** — Provide a brief confirmation:
   - Your name and role (from about_me.md)
   - Active account count and any flagged situations
   - Available commands
   - Gong skill status (connected or not)
   - "Ready to assist" confirmation

## Important
- Keep the summary concise — don't waste tokens repeating everything
- Flag anything that looks outdated or needs attention
- If any context files are missing or empty, note that immediately
