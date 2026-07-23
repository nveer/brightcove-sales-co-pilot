# Context Files — Setup Instructions

Fill in these files before running `/prime`. Claude reads them at the start of every session to personalize all responses to you.

## Files to Complete

### about_me.md
Your name, role, team, email, and working style. Claude uses this for every interaction.

### current_accounts.md
Your active customer accounts — tier, status, competitors, key contacts. Update this after significant changes.

### brightcove_overview.md
Brightcove product knowledge, 2026 roadmap highlights, competitive positioning, objection responses.
Update quarterly or after major product announcements.
Source of truth: https://support.brightcove.com/

### se_team.md
Your sales team members and their Gong user IDs.
**Important:** All Gong searches are filtered to these user IDs to return only your team's calls.
Ask your Gong admin to provide user IDs, or pull them from the Gong API once your credentials are set up.

### slack_channels.md
Optional. Maps a customer/account to the internal Slack channel(s) where it's discussed. If Slack is connected and you add a row here, `/call_prep`, `/account_summary`, and `/call_companion` will read that specific channel (last 30 days) for internal context — no channel mapped means no automatic Slack search. Grows organically as you learn which accounts have dedicated channels.
