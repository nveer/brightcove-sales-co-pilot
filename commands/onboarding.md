---
description: First-time setup wizard for Brightcove Sales Co-Pilot. Walks new users through Google/Notion sign-in, personalization, and output destination choice. Triggered automatically on first session via SessionStart hook.
allowed-tools: Write, Read, mcp__brightcove-gateway, mcp__notion
---

IMPORTANT — CONTEXT AUTO-CREATION:
When the user chooses Notion as their output destination in Step 5, do NOT ask them to create Notion databases manually. Instead, automatically:
1. Create a page in their Notion workspace titled "Sales Co-Pilot" as the parent hub
2. Under that page, create a database called "Call Follow-Ups" with these properties:
   - Name (title)
   - Customer (select)
   - Date (date)
   - Status (select: options = "Draft", "Sent", "In Progress")
   - Attendees (rich text)
3. Under that page, create a database called "Customer Call Prep" with these properties:
   - Name (title)
   - Account (select)
   - Date (date)
   - Priority (select: options = "High", "Medium", "Low")
   - Notes (rich text)
4. Save the database collection:// URLs and parent page ID to context/output_config.md automatically
5. Tell the user: "I've set up your Notion workspace for you — all your follow-up pages and call prep will go there automatically."

They should never have to create, configure, or find Notion database IDs.

---

# Onboarding Workflow

## Overview
This workflow guides a new Sales Co-Pilot user through initial setup (5-7 minutes). It collects user info, verifies integrations, and configures output destinations.

## Start Onboarding

Display warm welcome message:
"Welcome to Brightcove Sales Co-Pilot! I'm going to walk you through a quick setup — it takes about 5 minutes. I'll ask you a few questions, and when we're done you'll be ready to prep for calls, triage your inbox, and get post-call follow-ups automatically."

Create and display a TodoWrite checklist:
1. ✅ Connect Google (Gmail, Calendar, Drive)
2. ✅ Connect Notion
3. ✅ Tell me about yourself
4. ✅ Add your top accounts
5. ✅ Set up Notion workspace (automatic)
6. ✅ Finish setup

---

## STEP 1 — Google Connections

Tell the user:
"When you installed Sales Co-Pilot, Claude Desktop should have already prompted you to connect Gmail, Google Calendar, and Google Drive. If you haven't done that yet — look for a notification in Claude Desktop or go to **Settings → Integrations**. Let me know when all three show as connected."

Wait for the user to confirm they have completed the integration step.

Once confirmed:
- Mark step 1 as complete in the TodoWrite checklist
- Display: "Great! All three Google integrations are live."

---

## STEP 2 — Notion Connection

Tell the user:
"Now connect Notion the same way — **Claude Desktop → Settings → Integrations → Notion**. Sign in with the Brightcove Notion workspace."

Wait for the user to confirm they have completed the integration step.

Once confirmed:
- Mark step 2 as complete in the TodoWrite checklist
- Display: "Perfect! Notion is connected."

---

## STEP 3 — About You

Ask the user:
"What's your name, your role at Brightcove, and which team are you on? (For example: 'Sarah Chen, Account Executive, East Enterprise')"

Wait for their response. Parse the answer to extract:
- Name
- Role
- Team

Silently write the extracted information to `/context/about_me.md`, replacing the placeholder values [Your Name], [Your Role], [Your Team] with their actual responses.

Also update:
- Focus: [Ask if not provided: "What's your main focus in your sales role?" e.g., "Enterprise video platform adoption" or "Streaming platform migrations"]
- Weekly call cadence: [Ask: "How many customer calls do you typically do per week?"]
- Email: [Ask: "What's your Brightcove email address?"]

Once all fields are collected:
- Mark step 3 as complete in the TodoWrite checklist
- Display: "Perfect! I've saved your profile."

---

## STEP 4 — Top Accounts

Ask the user:
"What are your top 3–5 accounts right now? Just tell me the company names and a quick note on each (e.g. 'Acme Corp — renewal coming up', 'TechCo — new logo opportunity')."

Wait for their response.

Parse the account list and silently write to `/context/current_accounts.md` in this format:

```markdown
# Current Accounts

| Account | Status | Focus | Next Steps |
|---------|--------|-------|-----------|
| [Company Name] | [Status from user input] | [Focus/Notes] | [TBD] |
| [Company Name] | [Status from user input] | [Focus/Notes] | [TBD] |
...
```

Once written:
- Mark step 4 as complete in the TodoWrite checklist
- Display: "Accounts saved! I'll use these for call prep and research."

---

## STEP 5 — Set up your Notion workspace

Tell the user: "Last step — I'm going to set up your Notion workspace now. This is where all your call follow-ups, call prep docs, and research will live. I'll create everything automatically — you don't need to do anything."

Then silently execute:
1. Create a Notion page titled "Sales Co-Pilot — [Their Name]" as the parent hub
2. Under that page, create a "Call Follow-Ups" database with properties: Name (title), Customer (select), Date (date), Status (select: Draft/Sent/In Progress), Attendees (rich text)
3. Under that page, create a "Customer Call Prep" database with properties: Name (title), Account (select), Date (date), Priority (select: High/Medium/Low), Notes (rich text)
4. Write the page ID and database collection:// URLs to context/output_config.md

Tell the user: "Your Notion workspace is ready. All follow-ups and call prep will go there automatically."
Mark step 5 complete.

---

## STEP 6 — Complete Setup

Silently write a completion marker to `/context/.setup_complete` with the current date (from the system).

Display the completion message:
"🎉 You're all set! Here's what you can do right now:

- Say **'prep me for my calls today'** to get your daily briefing
- Say **'triage my inbox'** to sort through your emails
- Say **'call prep for [customer name]'** before any customer call
- After a call, say **'run call companion'** and I'll write up a follow-up for you"

Mark step 6 as complete in the TodoWrite checklist.

Display final message:
"You're ready to go! Need help? Just ask, and I'll support your calls, research, and follow-ups from here on out."

---

## Notes for Claude Implementation

- Use TodoWrite to track progress through all 6 steps
- All file writes happen silently (no confirmation messages to the user for writes)
- Validation: After writing each config file, do not re-read it back to confirm — trust the Write operation
- If user skips a step: Politely prompt them to complete it before moving forward
- If user provides insufficient info (e.g., no account names): Ask clarifying questions until you have what you need
- Keep the user experience warm and conversational — avoid technical jargon
- At the end, provide a quick reference of what they can ask for next
