---
description: "Gong conversation intelligence — search calls, pull transcripts, and generate call prep summaries."
---

# Gong API Skill

## Overview
This skill provides Claude access to your Gong instance for searching and retrieving call recordings and transcripts.

## Files
- `SKILL.md` — This file (instructions)
- `gong_api.sh` — API script for searching and fetching calls

## Setup
1. Ensure your Gong API credentials are in `scripts/.env` (copy from `scripts/.env.example`)
2. Make the script executable: `chmod +x skills/gong/gong_api.sh`
3. Update the SALES_USER_IDS in `gong_api.sh` with your team's actual Gong user IDs

## Usage

### Search for calls
```bash
bash skills/gong/gong_api.sh search "CompanyName" [months_back]
```
- Default: searches last 30 days (1 month lookback)
- For sales best practices research, pass 24-36 as months_back

### Get call transcript
```bash
bash skills/gong/gong_api.sh transcript [call_id]
```

## Critical Rules
1. **ALWAYS filter by sales team user IDs** from `/context/se_team.md`
2. **Prioritize your own user ID** — weight your conversations highest
3. Default search window: 30 days for account prep, 2-3 years for best practices
4. Paginate results when searching large windows
