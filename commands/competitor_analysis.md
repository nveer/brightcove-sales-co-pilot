# /competitor_analysis [competitor] — Competitive Research

## Purpose
Research a competing video platform and produce a competitive brief with objection handling.

## Workflow

### Step 1: Web Research (parallel agents)
Launch parallel agents to research:
- Competitor's platform capabilities and product suite
- Pricing model and packaging
- Recent news, funding, acquisitions
- Customer reviews (G2, Gartner, Capterra)
- Known strengths and weaknesses

### Step 2: Gong Call History
- Search Gong for any calls where this competitor was mentioned (SE team filter, last 90 days)
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
