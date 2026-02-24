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

### Step 2: Gong Intelligence
- Use the Gong skill (`./skills/gong/SKILL.md`) to search for recent calls with this customer
- **Filter by your user ID first** (from context/se_team.md)
- Default: last 30 days. If no results, expand to 90 days.
- Extract: key topics, open action items, pain points, customer sentiment, competitive mentions

### Step 3: Salesforce Data
- Use the Salesforce skill (`./skills/salesforce/SKILL.md`) to run a `full` pull for this customer
- Extract: ACV, ARR, Customer Tier, Account Owner, renewal date, products on contract, open opps, platform usage

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
