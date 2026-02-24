# /call_companion — Live Call Resource Assistant

## Purpose
Two-phase workflow: (1) During call — researches resources in real time. (2) After call — writes ONE consolidated Notion follow-up page.

## Phase 1: During Call

1. **Identify the meeting** — Check Google Calendar for the current customer call. Skip internal meetings.
2. **Monitor Granola** — Watch for resource requests, questions, or topics that need follow-up docs
3. **Research in parallel** — When a topic arises, search Brightcove docs in the background:
   - SDK docs: sdks.support.brightcove.com
   - API docs: apis.support.brightcove.com
   - Studio/Product docs: studio.support.brightcove.com
4. **Store in memory** — Accumulate all action items, questions, and resources. Do NOT interrupt the call with updates.

## Phase 2: After Call

Write ONE consolidated Notion follow-up page.

### Page Format Rules
- **Title:** `[Customer] — [Date]` (no "Call Follow-Up:" prefix)
- **One context sentence per section** + doc links. No lengthy explanations.
- **No internal meta-commentary** ("What was asked:", "What [name] said:") — just the content
- **ONE consolidated copy-paste email at the bottom** covering ALL topics. Not per-section snippets.

### Page Sections
1. Action Items (with owners and deadlines)
2. Resources Shared (doc links only)
3. Follow-up Email (one consolidated email covering everything)

### Notion Write
- Target: Call Follow-Ups database (see CLAUDE.md for DB ID)
- Known bug: `parent` parameter may fail — if it does, create at workspace level and note for user to drag into correct DB

## Important Rules
- Complex topics (code samples, XML, architecture) → ask first: "Email body or PDF attachment?"
- Keep the follow-up page concise. Link out instead of explaining.
- Link to Brightcove docs using correct subdomain URLs (sdks.support.brightcove.com, not support.brightcove.com/sdks/)
