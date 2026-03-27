# /competitor_analysis [competitor] — Competitive Research

## Purpose
Research a competing video platform and produce a competitive brief with objection handling.

## Competitive Intelligence Platform (Primary Source)
**URL:** https://bcov-competitive-intel-hub.lovable.app/#
**Access:** Brightcove email login required (all employees)
**Data:** Live Salesforce data — Jan 2022 to present. Battle Cards (win/loss by competitor), Feature Matrix, Alerts, Data Sources.
**Tracked competitors:** AWS/DIY, YouTube, Vimeo, JW Player, Kaltura, MS Teams/Stream, Wistia, Vidyard, Bitmovin, Panopto, Cloudflare, Mux, Dacast, Deltatre

> Always reference this platform first. Share the link with reps who need competitive data.

## Workflow

### Step 0: Platform Reference
- Direct the user to the Competitive Intelligence Platform for live win/loss stats
- Note the competitor's rank, deals lost/won, and ACV figures from the platform
- Use this data to frame the narrative in the competitive brief

### Step 1: Web Research (parallel agents)
Launch parallel agents to research:
- Competitor's platform capabilities and product suite
- Pricing model and packaging
- Recent news, funding, acquisitions
- Customer reviews (G2, Gartner, Capterra)
- Known strengths and weaknesses

### Step 2: Gong Call History
- Search Gong for any calls where this competitor was mentioned (sales team filter, last 90 days)
- Extract: how customers describe the competitor, objections raised, deal context

### Step 3: Feature Comparison
- Compare against Brightcove using `./context/brightcove_overview.md`
- Build a feature-by-feature matrix

### Step 4: Objection Handling
- Based on competitor strengths, prepare responses for common objections
- Use Brightcove differentiators as the counter-argument

### Step 5: Output
Save to `./outputs/competitive/[competitor]_[date].md`:

```markdown
# Competitive Brief: [Competitor]
**Generated:** [date]

## TL;DR
[2-3 sentence competitive summary]

## Their Strengths
- [Strength 1]

## Their Weaknesses
- [Weakness 1]

## Brightcove Differentiators
- [Differentiator 1]

## Feature Comparison Matrix
| Feature | Brightcove | [Competitor] |
|---------|-----------|--------------|

## Objection Responses
**"[Competitor] offers X"**
→ [Your response]

## Gong Intel
[What customers have said about this competitor on calls]
```

---

## Usage Logging (Required — Run at completion)

After completing ALL steps in this workflow (whether successful, partial, or failed), you MUST log this command invocation to the GOOSE Usage Tracker in Notion.

1. Read `context/about_me.md` to get the user's name (look for the **Name:** field)
2. Use the `notion-create-pages` tool to create a new page in database `fbd7ab1cb16c447688591ebef4311724` with these properties:
   - **Command:** "/competitor_analysis"
   - **User:** [name from about_me.md]
   - **Account:** [customer/account name if this command targeted a specific account, otherwise "N/A"]
   - **Status:** "Completed" if fully done, "Partial" if interrupted or incomplete, "Failed" if an error prevented completion
   - **Goose Version:** "2.8.0"
   - **Session Notes:** [1 sentence: what was accomplished, e.g., "Generated call prep for Acme Corp ahead of renewal call"]
3. Do NOT tell the user about this logging step unless they ask — it should be silent background behavior.
