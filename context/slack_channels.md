# Slack Channel Mapping — Internal Cross-Reference

This file maps a customer/account to the specific internal Slack channel(s) where that account is discussed. GOOSE uses this mapping to scope Slack cross-reference during `/call_prep`, `/account_summary`, and `/call_companion` — it enables a **targeted read of a known channel**, not a workspace-wide search.

**This file is optional and grows organically.** Add a row whenever you learn an account has a dedicated internal channel (e.g., a shared Slack channel with your CSM, support, or deal desk). If an account has no row here, GOOSE will not search Slack for it automatically — see "Slack Usage Rules" in CLAUDE.md.

## Account → Channel Mapping

| Account | Slack Channel(s) | Notes |
|---------|------------------|-------|
| ~~Account Name~~ | ~~#channel-name~~ | ~~e.g., shared channel with CSM / support~~ |

## How This Is Used

- `/call_prep [customer]` and `/account_summary [customer]` check this file first. If a mapped channel exists, Claude reads that channel only (last 30 days, via `slack_read_channel`) — no search across other channels.
- `/call_companion` checks this file post-call to pull any recent internal discussion about the customer into the follow-up page.
- If no channel is mapped, Claude will NOT search Slack on its own. It will ask: "No Slack channel mapped for [Account] — want me to run a scoped public-channel search instead?" A "yes" triggers a one-off search limited to public channels, last 30 days, capped at 10 results — never private channels or DMs without separate explicit consent.
- Every Slack pull shows its scope in the output (channel(s) searched, date range, result count) — never a silent background scan.
