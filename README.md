# GOOSE — Your AI Sales Co-Pilot

AI-powered sales assistant for Brightcove. Automates the most time-consuming parts of the sales workflow. Never fly solo.

## What It Does

- **Daily Call Prep** — Dark-theme HTML timeline with per-meeting cards enriched from Gong transcripts, Gmail, and Salesforce account data
- **Live Call Companion** — Real-time resource research during calls via Granola, then creates a follow-up subpage under the customer's Active Customers row in Notion
- **Email Triage** — Categorizes inbox, drafts responses using Brightcove docs, archives noise (never auto-sends)
- **On-Demand Call Prep** — Account briefings from Gong + Salesforce + Gmail for any customer
- **Call Debrief** — Post-call capture with action items and Notion follow-up
- **Account Summaries** — 360° view with health score, 6 months Gong history, full Salesforce pull
- **Competitor Analysis** — Competitive intel from web + your Gong call history
- **DB Migration** — One-time migration of legacy Call Follow-Ups entries into the shared Active Customers database

## Integrations

| Platform | Type | Setup |
|----------|------|-------|
| Brightcove Gateway (BigQuery) | MCP connector | Auto-configured on install — authenticate with Brightcove credentials when prompted |
| Gmail | MCP connector | Self-serve — connect twice (read + write) |
| Google Calendar | MCP connector | Self-serve (read-only) |
| Google Drive | MCP connector | Self-serve |
| Notion | MCP connector | Self-serve — connects to shared Active Customers DB |
| Granola | MCP connector | Self-serve (optional, recommended for live call companion) |

## Setup

1. **Download the plugin** — Get the latest `.zip` from [Releases](https://github.com/nveer/goose/releases)
2. **Upload to Claude Desktop** — Open Claude Desktop → Cowork tab → Customize → Personal plugins → **+** → Browse files → select `goose-v2.6.zip` → Upload
3. **Connect integrations** — In Claude Desktop, click Customize → Connectors → Connect your tools. Search for and connect: **Gmail** (twice — read + write), **Google Calendar**, **Google Drive**, and **Notion**. Sign in with your Brightcove accounts. The Brightcove Gateway auto-connects on install.
4. **Start a new task** — Open a Cowork task pointed at the GOOSE folder and type **"start"**. Claude will walk you through a 5-minute onboarding: your name, role, and team. Notion workspace is connected automatically — no database IDs or config files to edit.
5. **You're ready** — Say "prep me for my calls today" to get your first daily briefing.

> **Full setup guide with screenshots:** Open `docs/index.html` or visit the [landing page](https://nveer.github.io/goose/)

## Commands

| Command | Description |
|---------|-------------|
| `/prime` | Session startup — reads all context, confirms Claude is up to speed |
| `/morning_schedule` | Daily 7am briefing — loads calendar, classifies customer vs internal meetings |
| `/daily_prep` | Generate a dark-theme HTML call prep page for today with enriched meeting cards |
| `/call_companion` | Live call assistant — monitors Granola, researches docs in real time, creates follow-up subpage under Active Customers row |
| `/email_triage` | Inbox triage — categorizes, drafts responses, archives noise (never auto-sends) |
| `/call_prep [customer]` | On-demand pre-call briefing with Gong, Gmail, Salesforce, and Notion intel |
| `/call_debrief [customer]` | Post-call capture with action items and account context updates |
| `/account_summary [customer]` | 360° account view — 6 months of history, health score, Salesforce pull |
| `/competitor_analysis [name]` | Research and analyze a competing video platform |
| `/migrate-history` | One-time migration of legacy Call Follow-Ups DB into shared Active Customers DB |

## Architecture

- **Active Customers DB** (Notion) — Shared database, one row per customer (hub). Each call creates a child page under the customer row. Multi-rep safe.
- **Brightcove Gateway** (BigQuery) — All Gong transcripts, Salesforce data, contract/financial data, and usage metrics accessed via SQL. No direct API keys needed.
- **Salesforce links** — Always use `brightcove2.lightning.force.com` (not `brightcove.lightning.force.com`)

## Source of Truth

All Brightcove product questions: https://support.brightcove.com/
