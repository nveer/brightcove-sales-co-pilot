# Changelog — GOOSE

## v2.6 — March 2026

### 🗄️ Active Customers DB — Primary Database Switch

- **Active Customers DB is now the sole target for all workflows** — Call companion follow-ups, call prep, and account tracking all write to the shared Active Customers DB (`collection://6850738f-64b9-424c-a0a3-ed2b5bff1866`). One row per customer; content is prepended (never replaced). Multi-SE safe — multiple reps contribute to the same record.
- **Call Follow-Ups DB deprecated** — No new pages are created in the old Call Follow-Ups DB. Legacy data remains read-only.
- **Onboarding updated** — No longer creates a new Call Follow-Ups DB. Instead connects to the shared Active Customers DB and verifies access.

### 🔗 Salesforce Link Domain — Enforce `brightcove2`

- **All Salesforce links must use `brightcove2.lightning.force.com`** — The old `brightcove.lightning.force.com` domain either redirects or fails silently. Any workflow that generates, validates, or displays a Salesforce URL now enforces the correct `brightcove2` domain. Added as Rule 24 in CLAUDE.md.

### 🔄 New Command: `/migrate-history`

- **One-time private DB migration** — Migrates a rep's existing Call Follow-Ups entries into the shared Active Customers DB. 5-step workflow: locate private DB → fetch entries → match & append to Active Customers → tag originals → summary report. Safe to re-run (duplicate detection). Processes in batches of 20 for large databases. Onboarding now mentions this command when a legacy Call Follow-Ups DB is detected.

### 📋 Updated Files
- `.claude-plugin/plugin.json` — version bumped to 2.6
- `CLAUDE.md` — Notion DB section updated (Active Customers primary, Call Follow-Ups deprecated), /call_companion description updated, /migrate-history added, Rule 24 (SF domain) added
- `commands/onboarding.md` — Rewrote Step 4 to connect to shared Active Customers DB instead of creating Call Follow-Ups DB; mentions /migrate-history for legacy data
- `commands/migrate_history.md` — New command file (full spec)
- `context/output_config.md` — Updated to reflect Active Customers DB as primary, Call Follow-Ups as deprecated
- `docs/index.html` — All version strings to v2.6; call companion descriptions updated; Notion platform card updated; onboarding references updated; /migrate-history added to command grid
- `docs/sales-co-pilot-overview.html` — Call companion and rollout descriptions updated
- `CHANGELOG.md` — this entry

---

## v1.5.5 — March 2026

### 📧 Gmail Threading Fix (Code-Level)

- **Email threading now works natively in the slim Gmail MCP server** — `send_email` and `draft_email` now accept optional `threadId` and `inReplyTo` parameters. When provided, the MIME message includes `In-Reply-To` and `References` headers and the Gmail API call includes the `threadId`, keeping replies in the same conversation thread. This was the root cause of replies creating new threads instead of staying in existing ones.
- **New `read_thread` tool** — Fetches all messages in a Gmail thread with their `Message-ID` headers, making it easy to extract the `inReplyTo` value needed for proper threading.
- **`read_email` now returns threading headers** — Added `messageId` (Message-ID header), `inReplyTo`, and `references` fields to the read_email response, so all threading data is available without needing a separate read_thread call.
- **Two-connector workaround no longer needed** — The primary Gmail connector now handles threading end-to-end. The registry connector is no longer required for threaded replies.

### 📋 Updated Files
- `gmail-mcp-server-slim/index.js` — `send_email` and `draft_email` accept `threadId` + `inReplyTo`; new `read_thread` tool; `read_email` returns `messageId`, `inReplyTo`, `references`
- `gmail-mcp-server-slim/gmail-client.js` — `buildMimeMessage()` accepts `inReplyTo` and `references` params, adds RFC 2822 headers
- `.claude-plugin/plugin.json` — version bumped to 1.5.5
- `docs/index.html` — version strings updated to v1.5.5
- `CHANGELOG.md` — this entry

---

## v1.5.4 — March 2026

### 🐛 Bug Fix

- **Brightcove Gateway MCP — wrong endpoint URL** — `.mcp.json` had the Gateway URL set to `/sse` which returns a 404. Corrected to `/mcp`, which is the live endpoint. This was silently preventing the Gateway from auto-connecting on plugin install, breaking all BigQuery-dependent features (Gong transcripts, Salesforce data, daily prep, entitlement checks). The connector appeared installed but was never functional.

### 📧 Gmail — Two-Connector Threading Strategy

- **Documented Gmail threading limitation** — `send_email`/`draft_email` on the primary Gmail connector do not support `threadId`/`inReplyTo`. Replies to existing threads must be sent manually from Gmail to preserve threading until the fix is confirmed.
- **Two-connector threading fix** — Documented the strategy of connecting the registry Gmail connector alongside the primary connector: registry provides `read_thread` (for Message-ID extraction) and `create_draft` (for threaded drafts); primary handles bulk ops, archiving, and sending.
- **Tools Required section added to email_triage.md** — Email triage now explicitly lists both Gmail connectors and their roles, plus the threading limitation caveat.

### 📋 Updated Files
- `.mcp.json` — `brightcove-gateway` URL updated from `.../sse` to `.../mcp`
- `CLAUDE.md` — Gmail connector section updated with threading limitation and two-connector strategy
- `commands/email_triage.md` — Added Tools Required section with both Gmail connectors documented
- `.claude-plugin/plugin.json` — version bumped to 1.5.4
- `docs/index.html` — version strings updated to v1.5.4
- `CHANGELOG.md` — this entry

---

## v1.5.3 — March 2026

### 🔧 Infrastructure Optimization

- **Gmail MCP Server — Slim Replacement** — Switched Claude Desktop's gmail-write MCP server from `npx @gongrzhe/server-gmail-autoauth-mcp` (179MB fresh install every session) to `node gmail-mcp-server-slim/index.js` (27MB, already installed). The custom slim server uses `@googleapis/gmail` (single-service) instead of the full `googleapis` package. Same 19 tools, same OAuth browser sign-in flow. Saves ~150MB per session — enough to keep Cowork sessions functional on the limited VM disk.

### 📋 Updated Files
- `.claude-plugin/plugin.json` — version bumped to 1.5.3
- `docs/index.html` — version strings updated to v1.5.3
- `CHANGELOG.md` — this entry

---

## v1.5.2 — March 2026

### 🔧 Reliability & Safety

- **Brightcove Gateway MCP disconnection detection** — When BigQuery tool calls fail or return connection errors, GOOSE now immediately stops and notifies the user with reconnection instructions instead of silently skipping BigQuery steps or substituting cached data. Prevents silent data gaps in daily prep, email triage, and account research.
- **Email triage — two-pass default scan window** — Default email scan now does two passes: last 24 hours first, then previous 2 days, merged and deduplicated before categorization. Catches threads that arrived over the weekend or during gaps between triage sessions.
- **Expanded file retention policy** — Added rules for zip backup prevention and abandoned git worktree cleanup. Zip backups of the workspace balloon to 50MB+ and are redundant since the workspace is already cloud-synced. Abandoned worktrees contain full repo copies with duplicate assets.

### 📋 Updated Files
- `CLAUDE.md` — Rule 23 (Gateway disconnection), email triage two-pass window, file retention rules 6-7
- `commands/email_triage.md` — Two-pass default scan window
- `.claude-plugin/plugin.json` — version bumped to 1.5.2
- `CHANGELOG.md` — this entry

---

## v1.5.1 — March 2026

### 🔧 Email Threading Fix (Critical)

- **Pre-send threading checklist (BLOCK SEND)** — Email replies were silently creating new threads because `inReplyTo` was missing or confused with `threadId`. Added a mandatory 4-field checklist (`threadId`, `inReplyTo`, `to`, `cc`) that must ALL be populated before any send/draft call. Send is blocked if any field is missing. The `inReplyTo` field must be the `messageId` of the last message in the thread (from the `Message-ID` header), not the `threadId`. This was the root cause of broken email chains reported by users.

### 📧 Email Triage Safety Rails

- **Verify links before send approval** — All links in email drafts are now tested before presenting for approval. Broken or 404'd links are fixed or flagged before the user can approve.
- **Check entitlements before offering features** — Before drafting emails that reference Brightcove product features, checks BigQuery `v_done_deal_contract_lines` to confirm the customer actually has the feature under contract.
- **Check account owner before committing SE time** — Before drafting emails that commit to deliverables, confirms the AM/AE via BigQuery and routes AM work appropriately.
- **Stick to established names in threads** — Drafts now match the exact company/product names used in the existing email thread, preventing name substitution errors.
- **Multi-draft review doc** — When 2+ drafts are ready in the same triage session, creates a `draft-review-YYYY-MM-DD.md` file for side-by-side review instead of inline chat presentation.

### 🧹 File Retention Policy

- **Auto-cleanup at /prime** — Automatically deletes call-prep HTMLs, email triage files, and draft review files older than 3 days. Removes duplicate format files and .DS_Store files. Prevents VM disk exhaustion that previously deadlocked Cowork sessions.
- **Output size guidelines** — No raw transcript dumps, 500KB cap per file, one-time deliverables moved to `/outputs/deliverables/` after delivery.

### 📋 Updated Files
- `CLAUDE.md` — Rule 13a hardened with `inReplyTo` extraction requirement and send-blocking enforcement. Rules 13c (verify links), 13d (check entitlements), 13e (check account owner), 13f (name consistency), Rule 22 (multi-draft review doc), File Retention Policy section
- `commands/email_triage.md` — Step 5.5 expanded with pre-send threading checklist that blocks send if `threadId`, `inReplyTo`, `to`, or `cc` are missing. Multi-draft review doc workflow added to Step 6
- `.claude-plugin/plugin.json` — version bumped to 1.5.1
- `docs/index.html` — 6 version strings updated to v1.5.1
- `CHANGELOG.md` — this entry

---

## v1.5.0 — March 2026

### ✨ Email Triage Improvements

- **No default call offers** — Email drafts no longer offer a call by default. Default closing is "Let me know if you have any questions." A call is only offered if: (a) the customer is clearly frustrated/upset, or (b) they've asked the same question multiple times and the issue remains unresolved.
- **Reply-to-all mandatory** — When responding to an existing email thread, always reply-to-all using `threadId` + `inReplyTo` (latest message ID) with all original TO/CC recipients. Creating a new email for an existing thread is no longer allowed — it breaks the conversation chain.
- **Explicit send approval after edits** — After any draft edit is requested, the fully revised draft must be shown again before sending. Edit requests ("remove the call offer", "add docs") are not send approval — user must explicitly say "send it" / "yes" / "go ahead."
- **Pre-send context summary** — Each draft presented for review now includes a 1–2 sentence summary of what the other party last said, so the user knows exactly what they're responding to without recalling the thread manually.
- **Auto-archive after send** — After any email is sent during triage, the source thread is automatically archived (removes INBOX + UNREAD labels from all messages in the thread). Responded-to threads no longer linger in inbox.

### 🗓️ Daily Prep Refinements

- **Calls-only scope enforced** — Daily prep HTML pages now focus exclusively on today's customer calls. The "Inbox Highlights" section has been removed. Email intel and account monitoring belong in `/email_triage` only.
- **Key Context banner tightened** — The banner at top of daily prep is now strictly 3–5 bullets of call-related intel (schedule changes, cancellations, last-minute attendee additions, urgent signals tied to a specific meeting). General inbox items are excluded.
- **Duplicate Rule 14/16 fixed** — Rules 14 and 16 in CLAUDE.md were identical (a copy error from v1.4.3). Merged into single correct Rule 15 with updated bullet count (3–5, was 5–8).

### 📋 Updated Files
- `CLAUDE.md` — Rules 13 (reply-to-all), 13b (auto-archive), 14 (daily prep calls-only), 15 (banner tightened), 16 (internal classification); duplicate rule removed
- `commands/email_triage.md` — Step 5.4 (no default call offers), Step 5.5 (reply-to-all), Step 5.6 (pre-send context + explicit approval), Step 5.7 (auto-archive after send); Step 7 updated
- `.claude-plugin/plugin.json` — version bumped to 1.5.0
- `CHANGELOG.md` — this entry

---

## v1.4.3 — March 2026

### 🪿 GOOSE Rebrand
- **Plugin renamed:** Brightcove Sales Co-Pilot → **GOOSE — Your AI Sales Co-Pilot**
- **Tagline:** "Talk to Me, Goose." / "Never Fly Solo"
- **plugin.json:** `name` updated to `goose`, description updated with GOOSE branding
- **Landing page:** Hero redesigned — GOOSE logo (transparent BG, 400px), gold italic tagline, "Never Fly Solo" whisper text, h1 updated to "Your AI Sales Co-Pilot"
- **CLAUDE.md:** Title, purpose, and first-run welcome message updated to GOOSE branding
- **GitHub repo:** Renamed to `goose`

### ✨ Call Prep Improvements
- **Internal call classification tightened:** Bending Spoons employees (`@bendingspoons.com`) now explicitly classified as internal alongside Brightcove employees. A meeting is customer-facing only if at least one external non-Brightcove/non-BendingSpoons attendee is present.
- **Key Context banner scoped to call-related intel only:** Banner at top of daily prep page now contains ONLY items tied to that day's customer calls (scheduling conflicts, time changes, last-minute attendees, urgent account signals). General inbox items (support cases, renewals, internal FYIs) are excluded from the banner — they belong in the Inbox section.
- **Source badges mandatory:** Every intel item in the context banner, meeting cards, and inbox sections must carry a source badge (`src gmail`, `src calendar`, `src granola`, `src docs`, `src workspace`, `src unverified`). Items without a verified source are excluded.

### 📋 Updated Files
- `.claude-plugin/plugin.json` — name + description updated; version bumped to 1.4.3
- `CLAUDE.md` — GOOSE rebrand; internal classification rule; source badge rule; context banner rule
- `docs/index.html` — hero redesign; all version strings bumped to v1.4.3
- `CHANGELOG.md` — this entry; title updated to GOOSE

---

## v1.4.2 — March 2026

### 🐛 Bug Fixes
- **Install flow simplified to 5 steps (was 6):** Old Steps 1–3 (download, unzip, find .plugin, upload) collapsed into 2 steps (download .zip, upload .zip directly). No unzipping needed.
- **Claude Desktop only accepts .zip uploads:** The "Upload local plugin" dialog rejects `.plugin` files — only `.zip` is accepted. Distribution now stays as `.zip` end-to-end. Reps never see a `.plugin` file.
- **Correct UI path verified from live app:** Customize → Personal plugins → **+** button (not "Browse plugins" which is the marketplace). Updated all instructions to match the actual Claude Desktop UI.
- **Removed drag-and-drop into Cowork chat** as install method — this only lets Claude read the file, it does not register the plugin.
- **Removed double-click as install method** — not supported for `.zip` files and `.plugin` file associations are unreliable across Mac updates.
- **Connector paths fixed across all docs:** "Settings → Customize → Connectors → Connect my tools" → "Customize → Connectors → Connect your tools" (matches actual Claude Desktop UI on Mac). Updated in all platform cards, Before You Start section, setup checklist, and onboarding.

### ✨ Enhancements
- **Call Companion: Phase 0 removed** — No more pre-call BigQuery/Gong loading delay. Call Companion is now a clean 2-phase workflow: (1) During call — real-time research via Granola or manual flagging. (2) After call — Notion follow-up page. Starts immediately with no startup lag.
- **Daily Prep now pulls Gong + Salesforce data:** `/daily_prep` and `/call_prep` now query Gong transcripts (`v_raw_salesforce_transcript`) and Salesforce account data (`v_salesforce_account`, `v_salesforce_opportunity`, `v_done_deal_contracts`, `v_entitlement_usage_monthly`) via Brightcove Gateway (BigQuery) in addition to Calendar, Gmail, and Granola.

### 📋 Updated Files
- `docs/index.html` — Install steps rewritten; connector paths fixed (×8); daily prep card updated with BigQuery sources; Granola description updated to reflect 2-phase flow; checklist connector paths fixed
- `commands/call_companion.md` — Phase 0 removed; 3-phase → 2-phase workflow; Path 1B updated for manual mode
- `commands/call_prep.md` — Steps 2–3 updated from deprecated skill paths to BigQuery tables
- `commands/onboarding.md` — Connector paths updated to match actual UI
- `INSTALL.md` — 8-step install flow added; "What NOT to do" section updated
- `CLAUDE.md` — /daily_prep description and parallel agents strategy updated with BigQuery sources
- `.claude-plugin/plugin.json` — version bumped to 1.4.2
- `CHANGELOG.md` — this entry

---

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
