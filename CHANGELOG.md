# Changelog — Brightcove Sales Co-Pilot

## v1.4.1 — March 2026

### 🐛 Bug Fixes
- **Onboarding trigger:** SessionStart hook requires a user message to activate in Cowork mode. Updated post-install instructions and Step 6 of the install guide to tell users to type **"start"** in the new task — onboarding then fires automatically.
- **plugin.json version:** Corrected from `1.3.0` to `1.4.1` (was never bumped from v1.3.0 in the original v1.4.0 release)
- **Landing page version strings:** All 3 display version strings (topbar, hero subtext, footer) updated to `v1.4.1`

### 📋 Updated Files
- `INSTALL.md` — post-install response updated with "type start" instruction
- `docs/index.html` — Step 6 and all 3 version strings updated
- `.claude-plugin/plugin.json` — version bumped to 1.4.1

---

## v1.4.0 — March 2026

### ✨ New Capabilities

**Gong Transcript Integration in Call Companion (no setup required)**
- Call Companion now operates in two modes depending on whether Granola is available
- **Without Granola (default):** Loads the last 3 Gong transcripts for the account at call start via Brightcove Gateway (BigQuery). Displays key topics, open action items, and recurring themes as pre-call context. After the call, polls BigQuery for the new transcript (~1 hour sync delay) and auto-generates the follow-up Notion page.
- **With Granola (recommended):** Real-time monitoring and immediate post-call follow-up unchanged from v1.3.0
- Transcript source table: `v_raw_salesforce_transcript` joined to `v_raw_salesforce_task`

### 🔧 Installation Changes
- Connectors (Gmail ×2, Google Calendar, Google Drive, Notion, Granola) now connected **before** plugin install, not during onboarding
- "Before You Start" section on install page updated with step-by-step connector instructions
- Onboarding Steps 1–2 now verify connectors rather than guide first-time connection
- Granola updated from "Optional" to "Recommended" throughout install page and docs

### 📋 Updated Files
- `commands/call_companion.md` — 3-phase workflow with BigQuery/Gong integration
- `CLAUDE.md` — Gong transcripts now documented as live capability (not v3.1)
- `commands/onboarding.md` — Steps 1–2 updated to verification flow
- `docs/index.html` — "Before You Start" section expanded; Granola badge updated

### 🛠️ Release Checklist Note
When bumping versions in future releases, `docs/index.html` has **3 places** that must all be updated:
1. Topbar span — `🎬 Brightcove Sales Co-Pilot — vX.X.X`
2. Hero button subtext — `vX.X.X · Requires Claude Desktop · View all releases`
3. Footer — `Brightcove Sales Co-Pilot · vX.X.X`

---

## v1.3.0 — March 2026

### ✨ New Capabilities
- **Zero-touch Notion setup** — Onboarding now automatically creates Call Follow-Ups and Customer Call Prep databases. No database IDs to copy, no CLAUDE.md edits required.
- **Safe Plugin install flow** — Plugin installs via the Claude Desktop Save Plugin dialog. Verified as a Safe Plugin — no terminal commands or admin access needed.
- **Always Allow guidance** — Setup page now instructs reps to click Always Allow when prompted, enabling seamless workflow automation.

### 🔧 Onboarding Improvements
- Removed Step 4 (manual account entry) — accounts are no longer collected during onboarding; they accumulate organically through use
- Gong fully removed from onboarding — no longer mentioned as a required integration (moving to v3.1)
- `prime` command no longer reads `se_team.md` — reps will never be asked for Gong user IDs
- CLAUDE.md cleaned up — removed Gong API, Salesforce API, and se_team references for clean rep experience

### 🏷️ Branding & Versioning
- Product renamed: **Sales Command Center → Sales Co-Pilot**
- Version reset to 1.x series to reflect this is the first broadly distributed version
- GitHub repo: https://github.com/nveer/brightcove-sales-co-pilot

---

## v1.0.0 — February 2026 (SE Command Center, internal use only)

### 🔄 Breaking Changes

**Salesforce API connector replaced by Brightcove Gateway (BigQuery MCP)**
- The direct Salesforce OAuth integration has been deprecated and removed
- All account, opportunity, contract, usage, and entitlement data is now accessed via the Brightcove Gateway — a BigQuery-based MCP connector that queries Brightcove's internal data warehouse directly
- No more OAuth Connected App setup or security token required
- Setup is now a single MCP connector install in Claude Desktop — same pattern as Gmail, Calendar, and Notion
- Affected commands: /call_prep, /account_summary, /call_debrief (all now use BigQuery instead of Salesforce API)

**BigQuery tables now in use:**
- `v_salesforce_account`, `v_salesforce_opportunity`, `v_salesforce_quote`, `v_salesforce_quote_line` — enriched Salesforce exports
- `v_done_deal_contracts`, `v_done_deal_contract_lines` — contract and billing data
- `v_entitlement_usage_monthly`, `v_daily_usage_extraction` — bandwidth, streams, managed content, auto caption usage
- `v_raw_salesforce_*` — raw tables for fields not in enriched views

---

### ✨ New Capabilities

**Brightcove Gateway (BigQuery) Integration**
- Direct SQL access to Brightcove's internal BigQuery instance
- Project: `brightcove-lumenx-42` | Dataset: `external_shared_views`
- 5 BigQuery tools: `bigquery_list_datasets`, `bigquery_list_tables`, `bigquery_describe_table`, `bigquery_run_query`, `bigquery_validate_query`
- Queries validate before running — no accidental bad queries
- Covers: account data, usage analytics, contract/financial data, Salesforce exports, Video Cloud events

**Always-On Research Engine**
- Every command now auto-researches unanswered technical questions before presenting output
- Lookups run against support.brightcove.com using correct subdomain structure (studio, sdks, apis)
- Answers embedded inline with ✅ Researched Answer markers
- Applies to: daily prep cards, email drafts, call companion resources, follow-up pages

**Notion Integration (standalone)**
- Post-call Notion pages are now a documented first-class capability
- Every call companion run produces one structured follow-up page + one copy-paste follow-up email
- Consistent format: [Customer] — [Date]
- Pages enriched with Gong and BigQuery data automatically

---

### 🔧 Updated Capabilities

**Daily Call Prep** (merged with /morning_schedule)
- Now covers both morning schedule briefing and full day prep in a single command
- Pulls Google Calendar + Gong + Granola + Gmail simultaneously via parallel agents
- Auto-researches open customer questions and embeds answers with ✅ badges in per-meeting cards
- Trigger: "Prep me for my calls today"

**Live Call Companion**
- Now checks Gong Sales team call history first when a trigger phrase is detected — surfaces how Sales reps have handled the same issue before
- Cross-references Google Docs for internal playbooks and reference materials
- Deploys parallel agents per open question simultaneously while the call continues
- Post-call output unchanged: one Notion page + one copy-paste follow-up email

**Email Triage**
- Reads full email threads before drafting (never drafts from snippets)
- Auto-researches answers before writing — drafts arrive with support.brightcove.com citations
- Smart archive filter: won't archive if you're named, customer is frustrated, or thread is stalled
- Standing auto-archive rules: out-of-office replies, past Read AI pre-reads, completed support acknowledgments

---

### 📋 New Commands

| Command | Description |
|---------|-------------|
| `/morning_schedule` | Daily 7am briefing — loads calendar, classifies meetings, preps call companion state |

---

### 🏷️ Branding Updates

- Plugin renamed: **SE Command Center → Sales Command Center**
- Hero title updated: **"Your AI-Powered SE Assistant" → "Your AI-Powered Sales Assistant"**
- Badge updated: **"Brightcove SE Command Center" → "Brightcove Sales Command Center"**
- All references to "SE workflow", "SE team", "SE call history" updated to "Sales" equivalents throughout

---

### 🗂️ Skills & Reference Updates

- `skills/salesforce/SKILL.md` — marked **DEPRECATED** (retained for reference only; potential future write-back use)
- `skills/publish-report/SKILL.md` — **NEW** — Cloudflare Pages deployment skill for publishing HTML reports to https://reports-aoy.pages.dev
- `reference/gmail-mcp-setup-guide.md` — **NEW** — Step-by-step Gmail MCP server setup guide (17 tools documented)
- `reference/gong_competitive_analysis.md` — Updated February 2026 with 710+ call analysis
- `reference/jw_player_battlecard.md` — Updated January 2026

---

### ⚙️ Setup Changes

**Removed from setup:**
- Salesforce Connected App (no longer needed)
- SF_CONSUMER_KEY, SF_CONSUMER_SECRET, SF_USERNAME, SF_PASSWORD, SF_SECURITY_TOKEN environment variables

**Added to setup:**
- Brightcove Gateway MCP connector (install in Claude Desktop → Settings → Integrations)
- No additional credentials required — connector uses Brightcove's internal auth

---

## v1.2.0 — February 2026 (Sales Command Center, internal use only)

- Initial plugin release with 7 commands
- Gong API integration (SE-filtered call history)
- Salesforce API integration (OAuth 2.0 password flow)
- Gmail MCP (read + write)
- Google Calendar MCP (read-only)
- Google Drive MCP (read-only)
- Notion MCP (create/update)
- Granola MCP (meeting transcripts)
- Daily call prep HTML page generator
- Live call companion with Granola monitoring
- Email triage with smart archive filter
- Account summaries and competitor analysis

---

*Brightcove Sales Command Center · Built for Brightcove Sales*
