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

## Watch Out For
[Sensitive topics, renewal tensions, escalations]
```

### Step 7: Confirm
- Tell the user the briefing is ready and where it's saved
- Highlight the #1 thing to address on this call
