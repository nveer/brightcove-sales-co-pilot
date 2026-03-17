# Output Configuration — Notion

All GOOSE outputs go to your Notion workspace.
Claude connects to the shared databases during onboarding.

## Notion Workspace

Parent Page ID: [auto-filled during onboarding]
Active Customers DB (PRIMARY): collection://6850738f-64b9-424c-a0a3-ed2b5bff1866
Customer Call Prep DB: [auto-filled during onboarding]
Call Follow-Ups DB (DEPRECATED): Do not create new pages here. Legacy data only.

## How It Works
- **Active Customers DB** is the single target for all call follow-ups. One row per customer — content is PREPENDED to the existing row (never creates standalone pages).
- **Customer Call Prep DB** stores pre-call research and prep docs.
- **Call Follow-Ups DB** is deprecated. Run `/migrate-history` to move legacy entries into the shared Active Customers DB.

## Note
Google Drive is connected for reading files (contracts, decks, reference docs)
but all generated outputs go to Notion.
