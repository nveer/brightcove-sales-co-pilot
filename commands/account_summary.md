# /account_summary [customer] — Full Account Overview

## Purpose
Generate a 360° account overview with health score and recommendations.

## Workflow

### Step 1: Gong History (6 months)
- Search Gong for all team-attended calls with this customer (6-month window)
- Summarize: key themes across calls, recurring pain points, relationship trend

### Step 2: Salesforce Full Pull
- Run `full` command from Salesforce skill
- Extract: ACV, ARR, products, open opps, renewal date, platform usage, account owner, CSM

### Step 3: Gmail History (90 days)
- Search Gmail for emails from/to this customer
- Note: any unresolved threads, commitments made, escalations

### Step 4: Health Score
Assign Green / Yellow / Red with reasoning:
- **Green** — Active engagement, healthy usage, no open issues
- **Yellow** — Low usage, renewal risk, or open action items
- **Red** — Active escalation, competitive threat, churning signals

### Step 5: Output
Save to `./outputs/account_summaries/[customer]_[date].md`:

```markdown
# Account Summary: [Customer]
**Generated:** [date]
**Health:** 🟢 Green / 🟡 Yellow / 🔴 Red

## Snapshot
- ACV: $[acv] | Renewal: [date] | Tenure: [X] years
- Tier: [tier] | Account Owner: [name] | CSM: [name]
- Brightcove Accounts: [list]

## Products on Contract
[List of products]

## 6-Month Call Summary
[Key themes and relationship trend]

## Open Opportunities
[Active opps and their status]

## Platform Usage
- Active users: [X] | Last login: [date]

## Risks
- [Risk 1]

## Opportunities
- [Opportunity 1]

## Recommended Actions
1. [Action 1]
```
