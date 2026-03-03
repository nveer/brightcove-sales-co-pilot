# /call_companion — Live Call Resource Assistant

## Purpose
Two-phase workflow: (1) During call — researches resources in real time. (2) After call — writes ONE consolidated Notion follow-up page. Starts immediately with no pre-loading delay.

## Transcript Sources

| Source | When Available | Requires |
|--------|---------------|----------|
| Brightcove Gateway (Gong via BigQuery) | Post-call: ~1 hour after call ends | Nothing — pre-configured |
| Granola | Real-time during call | Granola app installed and recording |

---

## Phase 1: During Call

Two paths depending on Granola availability.

### Path 1A: With Granola (Real-Time Monitoring)

1. **Monitor Granola live** — Watch for resource requests, questions, or topics that need follow-up docs.
2. **Research in parallel** — When a topic arises, search Brightcove docs in the background:
   - SDK docs: sdks.support.brightcove.com
   - API docs: apis.support.brightcove.com
   - Studio/Product docs: studio.support.brightcove.com
3. **Store in memory** — Accumulate all action items, questions, and resources. Do NOT interrupt the call with updates.

### Path 1B: Without Granola (Manual Topic Flagging)

1. **Stand by for manual requests** — No pre-loaded context. Nathan drives what gets researched.
2. **Manual flagging** — During the call, Nathan can type: `look up [topic]` and Claude will immediately research and return relevant Brightcove docs.
3. **Store in memory** — Accumulate all action items, questions, and resources flagged during the call.

---

## Phase 2: After Call

Generate ONE consolidated Notion follow-up page. Two paths depending on Granola.

### Path 2A: With Granola (Immediate)

1. **Use Granola transcript** — The recorded call is available immediately in Granola.
2. **Generate follow-up page** — Write the Notion page using Granola transcript + accumulated notes from Phase 1.

### Path 2B: Without Granola (Wait for BigQuery Sync)

1. **Query today's transcript** — Check BigQuery for the call transcript synced from Gong:
   - Table: `v_raw_salesforce_transcript` (joined to `v_raw_salesforce_task`)
   - Filter: `task.date = current_date()` AND account matches
   - Always validate with `bigquery_validate_query` first

2. **If transcript is ready (usually ~1 hour after call ends):**
   - Generate follow-up page using BigQuery transcript + accumulated notes from Phase 1

3. **If transcript is not yet synced:**
   - Tell Nathan: "Your Gong transcript is still syncing — it should be ready within the hour. Type 'run call follow-up for [customer]' when you're ready and I'll generate the page automatically."
   - Nathan can re-run this command later and the transcript will be available

### Page Format Rules
- **Title:** `[Customer] — [Date]` (no "Call Follow-Up:" prefix)
- **One context sentence per section** + doc links. No lengthy explanations.
- **No internal meta-commentary** ("What was asked:", "What [name] said:") — just the content
- **ONE consolidated copy-paste email at the bottom** covering ALL topics. Not per-section snippets.

### Page Sections
1. Action Items (with owners and deadlines)
2. Resources Shared (doc links only)
3. Follow-up Email (one consolidated email covering everything)

### Notion Write
- Target: Call Follow-Ups database (see CLAUDE.md for DB ID)
- Known bug: `parent` parameter may fail — if it does, create at workspace level and note for user to drag into correct DB

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
