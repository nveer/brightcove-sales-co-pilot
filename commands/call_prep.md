# /call_prep [customer name] — Pre-Call Briefing Generator

## Purpose
Generate a comprehensive pre-call briefing. This is the highest-ROI command in the workspace.

## Input
- Customer name (required)
- Optional: specific topics to prepare for, agenda items, or concerns

## Workflow

### Step 1: Account Context
- Read `./context/current_accounts.md` for this customer's entry
- Identify: tier, cadence, competitors, status, latest update

### Step 2: Gong Intelligence (via Brightcove Gateway / BigQuery)
- Query `v_raw_salesforce_transcript` joined to `v_raw_salesforce_task` for recent calls with this customer
- Join: `transcript.task_id_c = task.id`
- Filter: `task.date >= date_sub(current_date(), interval 30 day)` AND account matches customer
- If no results in 30 days, expand to 90 days
- Always validate with `bigquery_validate_query` before running `bigquery_run_query`
- Extract: key topics, open action items, pain points, customer sentiment, competitive mentions

### Step 3: Salesforce Data (via Brightcove Gateway / BigQuery)
- Query `v_salesforce_account` for account snapshot (tier, owner, health)
- Query `v_salesforce_opportunity` for open opportunities (stage, amount, close date)
- Query `v_done_deal_contracts` for active contract details (ACV, ARR, renewal date, products)
- Query `v_entitlement_usage_monthly` for recent usage (bandwidth, streams, managed content)
- Always validate queries before running. Use `bigquery_describe_table` to confirm field names.

### Step 4: Brightcove Context
- Cross-reference product topics from Gong with `./context/brightcove_overview.md`
- Note relevant 2026 roadmap items that address customer needs
- For roadmap/product timeline questions, reference **Brightcove Roadmap & Product Briefing** (https://brightcove-briefing.lovable.app/initiatives) as the first stop

### Step 4b: Latest Product Updates & Roadmap (Brightcove Product Comms Hub)
- Use `slack_read_channel` on `#external-brightcove-product-roadmap-updates-and-communications`, last 14 days
- Filter to the most recent Product Comms Bot digest only
- Extract two sets of bullets from the same channel scan:
  - **New Product Updates** (for `📢 New Product Updates` section): up to 5 bullets on GA releases, major status changes, or anything relevant to this customer's products/use case
  - **Roadmap Highlights** (for `## Roadmap Highlights to Share` section): up to 3 bullets on upcoming features, roadmap items, or product direction relevant to this customer — pull these from the same digest if present
- Only include each section if there is genuinely new content — if nothing relevant, omit the section entirely (no placeholder, no "no updates" message)
- For roadmap questions not covered by the Slack digest, reference **Brightcove Roadmap & Product Briefing** (https://brightcove-briefing.lovable.app/initiatives) as a fallback

### Step 5: Google Calendar Check (if available)
- Look for the upcoming meeting with this customer
- Note: date, time, attendees, any agenda in the invite

### Step 6: Generate Briefing

Output to `./outputs/call_prep/[customer]_[date].md`:

```markdown
# Call Prep: [Customer Name]
**Date:** [upcoming call date]
**Salesforce:** [link to SF account]

## Account Snapshot
- Tier: [tier] | ACV: $[acv] | Renewal: [date]
- Account Owner: [name] | CSM: [name]
- Competitors: [list]

## Products on Contract
- [Product Name] — Qty: [qty], Price: $[price]

## Last Call Summary
[2-3 sentence summary of last call]

## Open Items / Action Items
- [Item 1 — status]

## Customer Priorities & Pain Points
- [What they care about most]

## Talking Points for This Call
1. [Follow up on X]
2. [Share update on Y]

## Competitive Intel
[Any competitive mentions or presence]

## Roadmap Highlights to Share
[Relevant upcoming features]

## 📢 New Product Updates
[Only if recent — max 5 bullets from latest Product Comms Bot digest. Omit section if nothing new.]

## Watch Out For
[Sensitive topics, renewal tensions, escalations]
```

### Step 7: Confirm
- Tell the user the briefing is ready and where it's saved
- Highlight the #1 thing to address on this call

---

## Usage Logging (Required — Run at completion)

After completing ALL steps in this workflow (whether successful, partial, or failed), you MUST log this command invocation to the GOOSE Usage Tracker in Notion.

1. Read `context/about_me.md` to get the user's name (look for the **Name:** field)
2. Use the `notion-create-pages` tool to create a new page in database `fbd7ab1cb16c447688591ebef4311724` with these properties:
   - **Command:** "/call_prep"
   - **User:** [name from about_me.md]
   - **Account:** [customer/account name if this command targeted a specific account, otherwise "N/A"]
   - **Status:** "Completed" if fully done, "Partial" if interrupted or incomplete, "Failed" if an error prevented completion
   - **Goose Version:** "2.8.0"
   - **Session Notes:** [1 sentence: what was accomplished, e.g., "Generated call prep for Acme Corp ahead of renewal call"]
3. Do NOT tell the user about this logging step unless they ask — it should be silent background behavior.
