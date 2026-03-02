# Brightcove Sales Co-Pilot — ~~Your Name~~

## Purpose
This workspace is the operational hub for ~~Your Name~~'s sales role at Brightcove. It enables Claude (via Cowork tasks in Claude Desktop) to act as an AI sales co-pilot — preparing for customer calls, debriefing after meetings, triaging email, analyzing accounts, and generating follow-ups automatically.

## How This Workspace Is Used
- **Platform:** Claude Desktop → Cowork → select this folder → start a task
- **Each task is a fresh session** — Claude reads this file + context folder to get up to speed
- **Persistence lives in files** — not chat history. Any updates to accounts, debriefs, or plans are saved as files in this workspace.
- **Start every task** by running the /prime workflow (read all context, confirm understanding)

## Who I Am
- **Name:** ~~Your Name~~ (populated during onboarding)
- **Role:** ~~Your Role~~, Brightcove (populated during onboarding)
- **Focus:** ~~Your sales focus~~ (populated during onboarding)
- **Weekly cadence:** ~~X~~ customer calls/week (populated during onboarding)
- **Key tools:** Gmail, Google Calendar, Notion, Granola

## What This Workspace Does
Claude operates as your sales assistant with access to:
- **Brightcove Gateway** (pre-configured MCP) — Account data, opportunities, usage metrics, contract details via Brightcove's BigQuery data warehouse. No setup needed — auto-connects on install.
- **Gmail** (MCP connectors) — Read, search, send, draft, archive, and batch-modify emails. Used by /email_triage for inbox management and response drafting.
- **Google Calendar** (MCP connector, read-only) — List events, find free time. Cannot create/modify events.
- **Notion** (MCP connector) — Create pages, search, fetch, update. Used for call follow-up pages and account tracking. Databases auto-created during onboarding.
- **Granola** (MCP connector) — Meeting transcripts and notes. Used by /call_companion.
- **Account context** (/context/current_accounts.md) — Active accounts, tiers, competitors, status (grows as you work)
- **Brightcove product knowledge** (/context/brightcove_overview.md) — Pre-bundled platform overview. Source of truth: https://support.brightcove.com/
- **Gong** — Coming in v3.1 via Brightcove Gateway. Do NOT reference Gong or ask for Gong user IDs.

## Workspace Structure
/context/          → Business context, personal info, accounts, Brightcove overview
/commands/         → Reusable workflow prompts (call_prep, call_companion, etc.)
/outputs/          → Generated reports organized by type

## Notion Databases
These are auto-created during onboarding and saved to `/context/output_config.md`. Never ask the user for database IDs — read them from output_config.md.
- **Customer Call Prep DB:** See output_config.md
- **Call Follow-Ups DB:** See output_config.md
- **Parent page:** See output_config.md

## Commands Available
- /prime — Run at task start. Reads all context files and confirms understanding.
- /call_companion — **Live call resource assistant.** Two-phase flow: (1) During call — monitors Granola, researches docs/resources in parallel, stores in memory. (2) After call — writes ONE consolidated Notion follow-up page. Calendar-aware, skips internal meetings.
- /daily_prep — **Generate daily call prep HTML page.** Pull Google Calendar, classify events, enrich customer calls with Gmail and Granola context, and output a styled HTML timeline. Format: dark theme, timeline with color-coded dots (blue=customer, gray=internal, yellow=hold/conflict, red=escalation, purple=work block).
- /email_triage — **Inbox triage & response drafting.** Scans Gmail, categorizes by action needed, archives noise, drafts responses using Brightcove docs. Interactive review loop — never auto-sends.
- /call_prep [customer] — Generate pre-call briefing with account context, recent email/meeting intel, and agenda prep
- /call_debrief [customer] — Capture post-call outcomes, action items, update account context
- /account_summary [customer] — Full account overview with history, health, and recommendations
- /competitor_analysis [competitor] — Research and analyze a competing video platform

## Execution Strategy: Parallel Agents
**Always deploy multiple agents (Task tool) in parallel when work can be done concurrently.**
- **Email drafting:** Launch one agent per email thread
- **Call prep:** Launch parallel agents for Gmail search, Granola, Notion, and Calendar simultaneously
- **Account research:** Launch parallel agents for web research, email history, Notion, and Brightcove Gateway data

Rules:
1. If two or more tasks have no dependency, run them as parallel agents in a single message
2. Each agent should be self-contained — give it full context
3. Collect results from all agents, then synthesize into a single output
4. Use `subagent_type: "general-purpose"` for research/drafting, `subagent_type: "Bash"` for scripts

## Key Rules
0. **First-run check** — At the start of every /prime, check if `context/about_me.md` contains `[Your Name]`. If it does, this is a first-time install — immediately greet the user and begin `commands/onboarding.md`. Do NOT mention Gong, Salesforce, .env, or se-plugin-onboarding.html. Just say: "Welcome to Brightcove Sales Co-Pilot! Let me get you set up." Then follow onboarding.md step by step.
1. **Always prime at task start** — Read this file and all context before doing anything
2. **Brightcove source of truth** — For product questions, reference https://support.brightcove.com/
3. **Keep outputs organized** — All generated files go in /outputs/[type]/
4. **Save everything to files** — Chat history doesn't persist between tasks. Anything worth keeping goes in a file.
5. **Gong — Coming in v3.1.** Do NOT reference Gong, ask for Gong user IDs, or mention Gong credentials.
6. **Follow-up pages are concise** — One context sentence per section + doc links. NO per-section email snippets. ONE consolidated copy-paste follow-up email at the bottom.
7. **Complex topics → ask first** — If a follow-up item needs detailed technical content (code samples, XML templates, architecture), ask the user: "Email body or attachable PDF?"
8. **Page titles: [Customer] — [Date]** — No "Call Follow-Up:" prefix.
9. **Doc URL structure** — SDK docs at sdks.support.brightcove.com. Product/Studio docs at studio.support.brightcove.com. API docs at apis.support.brightcove.com. The old support.brightcove.com/[section]/ paths are deprecated.
10. **Email drafts: read full threads first** — Before drafting ANY email reply, read the full thread. Never draft from snippets alone.
11. **Email tone rules** — No scolding language. Use helpful callbacks. Don't offer calls prematurely. Keep follow-ups short.
12. **Support email archive filter** — Before archiving any support case email, check 3 criteria: (1) Does it mention you by name in the body? (2) Does it show customer frustration? (3) Is the thread stalled/circular? If ANY are true, leave in inbox and flag.
13. **Daily prep = HTML file** — When asked to "prep for my day" or "morning prep", ALWAYS generate a styled HTML call prep page. Dark theme, timeline format, per-meeting cards with intel and action items.
