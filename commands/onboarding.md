---
description: First-time setup wizard for Brightcove Sales Co-Pilot. Walks new users through Google/Notion sign-in, personalization, and output destination choice. Triggered automatically on first session via SessionStart hook.
allowed-tools: Write, Read, mcp__brightcove-gateway, mcp__notion
---

IMPORTANT — CONTEXT AUTO-CREATION:
**NEVER ask the user if they have existing Notion databases or for database IDs. Always create them automatically.** Assume no rep has anything pre-configured. Just do it silently in Step 5.

When executing Step 5, do NOT ask the user anything about Notion. Instead, automatically:
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
"Welcome to Brightcove Sales Co-Pilot! I'm going to walk you through a quick setup — it takes about 5 minutes. I'll ask you a few questions, and when we're done you'll be ready to prep for calls, triage your inbox, and get post-call follow-ups automatically.

**⚡ One quick thing before we start:** For the best experience, switch to **Claude Sonnet** — it's 3x faster than Opus for these workflows with no quality loss. Click the model name at the top of this window (or in Settings → Model) and select **Claude Sonnet 4.5**. Then come back and type **'start'** to continue."

Wait for the user to confirm they've switched or say they're ready to continue.

Create and display a TodoWrite checklist:
1. ✅ Switch to Claude Sonnet
2. ✅ Connect Google (Gmail, Calendar, Drive)
3. ✅ Connect Notion
4. ✅ Tell me about yourself
5. ✅ Set up Notion workspace (automatic)
6. ✅ Finish setup

---

## STEP 1 — Google Connections

Tell the user:
"Before installing, the setup guide asked you to connect Gmail, Google Calendar, and Google Drive. Can you confirm all three are showing as connected? If any are missing, here's how: go to **Settings → Customize → Connectors → Connect my tools**. A pop-up will appear — search for **Google** and connect Gmail (twice — once for reading, once for sending), Google Calendar, and Google Drive. Each takes about 30 seconds."

Wait for the user to confirm all three are connected.

Once confirmed:
- Mark step 1 as complete in the TodoWrite checklist
- Display: "Great! All three Google integrations are confirmed."

---

## STEP 2 — Notion Connection

Tell the user:
"Same check for Notion — can you confirm it shows as connected? If not: go to **Settings → Customize → Connectors → Connect my tools**, search for **Notion** in the pop-up, and sign in with your Brightcove Notion account."

Wait for the user to confirm Notion is connected.

Once confirmed:
- Mark step 2 as complete in the TodoWrite checklist
- Display: "Perfect! Notion is confirmed."

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
- Focus: Present exactly these three options and ask the user to pick one:
  "What's your main sales focus?
  1. Media
  2. BDR
  3. Something else"
  If they pick 1, save focus as "Media". If they pick 2, save as "BDR". If they pick 3, ask: "What's your focus?" and save their answer.
- Weekly call cadence: [Ask: "How many customer calls do you typically do per week?"]
- Email: [Ask: "What's your Brightcove email address?"]

Once all fields are collected:
- Mark step 3 as complete in the TodoWrite checklist
- Display: "Perfect! I've saved your profile."

---

## STEP 4 — Set up your Notion workspace

**Do NOT ask the user any questions in this step. Do not ask if they have existing databases. Do not ask for IDs. Just create everything silently and tell them it's done.**

Tell the user: "Last step — I'm going to set up your Notion workspace now. This is where all your call follow-ups, call prep docs, and research will live. I'll create everything automatically — you don't need to do anything."

Then silently execute:
1. Create a Notion page titled "Sales Co-Pilot — [Their Name]" as the parent hub
2. Under that page, create a "Call Follow-Ups" database with properties: Name (title), Customer (select), Date (date), Status (select: Draft/Sent/In Progress), Attendees (rich text)
3. Under that page, create a "Customer Call Prep" database with properties: Name (title), Account (select), Date (date), Priority (select: High/Medium/Low), Notes (rich text)
4. Write the page ID and database collection:// URLs to context/output_config.md

Tell the user: "Your Notion workspace is ready. All follow-ups and call prep will go there automatically."
Mark step 4 complete.

---

## STEP 5 — Complete Setup

Silently write a completion marker to `/context/.setup_complete` with the current date (from the system).

Display the completion message:
"🎉 You're all set! Here's what you can do right now:

- Say **'prep me for my calls today'** to get your daily briefing
- Say **'triage my inbox'** to sort through your emails
- Say **'call prep for [customer name]'** before any customer call
- After a call, say **'run call companion'** and I'll write up a follow-up for you"

Mark step 5 as complete in the TodoWrite checklist.

Display final message:
"You're ready to go! Need help? Just ask, and I'll support your calls, research, and follow-ups from here on out."

---

## Notes for Claude Implementation

- **Gong transcripts are available via Brightcove Gateway** — Do NOT ask for Gong credentials, API keys, or user IDs during onboarding. Access is entirely through the pre-configured Brightcove Gateway (BigQuery). The only integrations to connect are: Gmail (×2), Google Calendar, Google Drive, Notion, and optionally Granola.

- Use TodoWrite to track progress through all 5 steps
- All file writes happen silently (no confirmation messages to the user for writes)
- Validation: After writing each config file, do not re-read it back to confirm — trust the Write operation
- **NEVER ask for accounts, Gong user IDs, Brightcove overview content, or API credentials** — these are pre-bundled in the plugin or handled automatically
- If user skips a step: Politely prompt them to complete it before moving forward
- Keep the user experience warm and conversational — avoid technical jargon
- At the end, provide a quick reference of what they can ask for next
