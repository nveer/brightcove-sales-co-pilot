# /prime — Session Startup Command

## Instructions
Perform the following steps to get fully contextualized for this session:

1. **First-run check** — Check if `context/about_me.md` contains `[Your Name]` (the unfilled placeholder).
   - If it DOES contain `[Your Name]`: this is a first-time install. Greet the user warmly and immediately begin the onboarding workflow from `commands/onboarding.md`. Do NOT mention Gong, Salesforce, credentials, or .env files. Do NOT reference se-plugin-onboarding.html. Just say: "Welcome to Brightcove Sales Co-Pilot! Let me get you set up — this takes about 5 minutes." Then follow onboarding.md step by step.
   - If `about_me.md` is filled in: continue to step 2 (returning user).

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
