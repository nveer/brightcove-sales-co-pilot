# GOOSE — Your AI Sales Co-Pilot

AI-powered sales assistant for Brightcove. Automates the most time-consuming parts of the sales workflow. Never fly solo.

## What It Does

- **Daily Call Prep** — Dark-theme HTML timeline with per-meeting cards enriched from Gong + Gmail
- **Live Call Companion** — Real-time resource research during calls + one Notion follow-up page after
- **Email Triage** — Categorizes inbox, drafts responses using Brightcove docs, archives noise (never auto-sends)
- **On-Demand Call Prep** — Account briefings from Gong + Salesforce + Gmail for any customer
- **Call Debrief** — Post-call capture with action items and Notion follow-up page
- **Account Summaries** — 360° view with health score, 6 months Gong history, full Salesforce pull
- **Competitor Analysis** — Competitive intel from web + your Gong call history

## Integrations

| Platform | Type | Setup |
|----------|------|-------|
| Gong | API key | Requires IT ticket |
| Salesforce | Connected App | Requires IT ticket |
| Gmail | MCP connector | Self-serve |
| Google Calendar | MCP connector | Self-serve (read-only) |
| Google Drive | MCP connector | Self-serve |
| Notion | MCP connector | Self-serve |
| Granola | MCP connector | Self-serve (optional) |

## Setup

1. Open `se-plugin-onboarding.html` for full setup instructions
2. Copy `scripts/.env.example` to `scripts/.env` and fill in credentials
3. Connect MCP integrations in Claude Desktop (Gmail, Calendar, Drive, Notion)
4. Fill in your `context/` files (about_me.md, se_team.md, current_accounts.md, brightcove_overview.md)
5. Run `/prime` to verify everything is working

## Commands

| Command | Description |
|---------|-------------|
| `/prime` | Session startup — reads all context, first-run detection |
| `/daily_prep` | Generate today's call prep HTML page |
| `/call_companion` | Live call assistant + Notion follow-up |
| `/email_triage` | Inbox triage and response drafting |
| `/call_prep [customer]` | Pre-call briefing |
| `/call_debrief [customer]` | Post-call capture |
| `/account_summary [customer]` | Full account overview |
| `/competitor_analysis [name]` | Competitive research |

## Sharing & Hosting

See the "GitHub Hosting" section in `se-plugin-onboarding.html` for instructions on hosting the onboarding page and plugin on GitHub Pages + GitHub Releases.

Quick summary:
1. Create a private GitHub repo
2. Enable GitHub Pages (serve from `/docs`)
3. Create a Release and upload `se-command-center.plugin`
4. Share one URL with your team

## Source of Truth

All Brightcove product questions: https://support.brightcove.com/
