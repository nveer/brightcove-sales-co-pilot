# /call_companion — Post-Call Wrap-Up Assistant

## Purpose
After a call ends, gathers the transcript (Granola or Gong via BigQuery), researches resources, and writes ONE consolidated Notion follow-up page. Nathan can optionally flag topics manually while the call is happening (see below), but there is no automatic real-time transcript monitoring — Granola encrypted its local database in March 2026, which removed the real-time access this workflow used to rely on.

## Transcript Sources

| Source | When Available | Requires |
|--------|---------------|----------|
| Granola | Post-call, once the meeting ends and Granola finishes processing | Granola app installed and recording |
| Brightcove Gateway (Gong via BigQuery) | Post-call: ~1 hour after call ends | Nothing — pre-configured |

---

## While the Call Is Happening (Optional, Manual Only)

There is no automatic Granola monitoring during the call — neither Granola's MCP server nor its public API expose a transcript until the meeting ends and processing completes. If Nathan wants something researched in the moment, he drives it manually:

1. **Manual flagging** — Nathan types `look up [topic]` and Claude immediately researches and returns relevant Brightcove docs.
2. **Store in memory** — Accumulate all action items, questions, and resources flagged this way for the after-call follow-up.

---

## After the Call: Generate the Follow-Up

Generate ONE consolidated Notion follow-up **child page** under the customer's Active Customers DB row. Two paths depending on Granola.

### Path A: With Granola

1. **Pull the Granola transcript** — Available once the meeting ends and Granola finishes processing.
2. **Generate follow-up page** — Write the Notion page using the Granola transcript + any notes accumulated from manual flagging above.

### Path B: Without Granola (Wait for BigQuery Sync)

1. **Query today's transcript** — Check BigQuery for the call transcript synced from Gong:
   - Table: `v_raw_salesforce_transcript` (joined to `v_raw_salesforce_task`)
   - Filter: `task.date = current_date()` AND account matches
   - Always validate with `bigquery_validate_query` first

2. **If transcript is ready (usually ~1 hour after call ends):**
   - Generate follow-up page using BigQuery transcript + accumulated notes

3. **If transcript is not yet synced:**
   - Tell Nathan: "Your Gong transcript is still syncing — it should be ready within the hour. Type 'run call follow-up for [customer]' when you're ready and I'll generate the page automatically."
   - Nathan can re-run this command later and the transcript will be available

### Optional: Slack Cross-Reference (Internal)
Only run this if the Slack MCP connector is connected. Follow the guardrails in CLAUDE.md's "Slack Usage Rules" — this is a targeted lookup, never a broad search.

1. Check `./context/slack_channels.md` for a row matching this customer.
2. **If a channel is mapped:** Use `slack_read_channel` on that channel only, last 30 days. Pull anything relevant to this call (internal flags, prior context, related discussion).
3. **If no channel is mapped:** Do NOT search Slack automatically. Ask Nathan: "No Slack channel mapped for [Customer] — want me to run a scoped public-channel search instead?" Only search if he says yes, and only with `slack_search_public` (never private/DMs), scoped with `after:` (last 30 days), capped at 10 results.
4. If nothing relevant is found, skip the "Internal Notes (Slack)" section entirely — no placeholder text.
5. If something is used, note which channel(s) were checked and the date range on the follow-up page.

### Page Format Rules
- **Title:** `[Customer] — [Date]` (no "Call Follow-Up:" prefix)
- **One context sentence per section** + doc links. No lengthy explanations.
- **No internal meta-commentary** ("What was asked:", "What [name] said:") — just the content
- **ONE consolidated copy-paste email at the bottom** covering ALL topics. Not per-section snippets.

### Page Sections
1. Action Items (with owners and deadlines)
2. Resources Shared (doc links only)
3. Internal Notes (Slack) — only if Slack is connected and something relevant was found; state which channel(s) were checked and the date range; omit entirely otherwise
4. Follow-up Email (one consolidated email covering everything)

### Notion Write
- Target: Active Customers DB (see CLAUDE.md for DB ID / collection URL)
- **Subpage model:** Each call creates a CHILD PAGE under the customer's existing row in Active Customers DB
- Flow: (1) Search Active Customers DB for customer by name. (2) If not found, create a new row with Name, Status, Account Owner. (3) Create a child page under the customer page using `notion-create-pages` with `parent: { page_id: "[customer_page_id]" }`. (4) Update parent customer properties (Last Call date, Status). (5) Notify account owner via @mention comment on the child page.
- Title format: `[Customer] — [Date]` (e.g., "Wonder Project — 2026-03-18")
- Every child page includes attribution: `**Written by:** [SE Name] | **Source:** Call Companion`

---

## Important Rules
- Complex topics (code samples, XML, architecture) → ask first: "Email body or PDF attachment?"
- Keep the follow-up page concise. Link out instead of explaining.
- Link to Brightcove docs using correct subdomain URLs (sdks.support.brightcove.com, not support.brightcove.com/sdks/)
- **BigQuery best practices:**
  - Always run `bigquery_validate_query` before `bigquery_run_query`
  - Use `bigquery_describe_table` to confirm field names before querying
  - Never invent table or field names — verify existence first
  - Join transcript to task table for accurate dates/owners: `transcript.task_id_c = task.id`

---

## Usage Logging (Required — Run at completion)

After completing ALL steps in this workflow (whether successful, partial, or failed), you MUST log this command invocation to the GOOSE Usage Tracker in Notion.

1. Read `context/about_me.md` to get the user's name (look for the **Name:** field)
2. Use the `notion-create-pages` tool to create a new page in database `fbd7ab1cb16c447688591ebef4311724` with these properties:
   - **Command:** "/call_companion"
   - **User:** [name from about_me.md]
   - **Account:** [customer/account name if this command targeted a specific account, otherwise "N/A"]
   - **Status:** "Completed" if fully done, "Partial" if interrupted or incomplete, "Failed" if an error prevented completion
   - **Goose Version:** "2.8.0"
   - **Session Notes:** [1 sentence: what was accomplished, e.g., "Generated call prep for Acme Corp ahead of renewal call"]
3. Do NOT tell the user about this logging step unless they ask — it should be silent background behavior.
