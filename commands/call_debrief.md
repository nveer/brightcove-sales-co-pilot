# /call_debrief [customer] — Post-Call Capture

## Purpose
Capture post-call outcomes, action items, and update account context. Run immediately after a customer call ends.

## Input
- Customer name (required)
- Optional: call summary notes to incorporate

## Workflow

### Step 1: Pull Call Context
- Check Granola for meeting transcript/notes from the most recent call with this customer
- If no Granola data, prompt the user: "Please share a few notes from the call and I'll debrief from those"

### Step 2: Extract Key Data
From the transcript/notes, identify:
- **Outcomes** — What was decided? What was demonstrated? What was agreed?
- **Action items** — Who does what by when? (both you and the customer)
- **Customer sentiment** — Happy, frustrated, curious, neutral?
- **Pain points mentioned** — Any new complaints or use cases surfaced?
- **Competitive mentions** — Any competitor references?
- **Next steps** — What's the agreed next touchpoint?

### Step 3: Update Account Context
- Update `./context/current_accounts.md` with:
  - Latest call date
  - Current sentiment/status
  - Any new competitive intel
  - Flagged action items

### Step 4: Create Notion Follow-Up Page
- Use the call_companion format for the Notion page
- Title: `[Customer] — [Date]`
- Include: action items, resources shared, consolidated follow-up email

### Step 5: Confirm
- Tell the user the debrief is complete
- Highlight any urgent action items or time-sensitive follow-ups
- Show the Notion page link

---

## Usage Logging (Required — Run at completion)

After completing ALL steps in this workflow (whether successful, partial, or failed), you MUST log this command invocation to the GOOSE Usage Tracker in Notion.

1. Read `context/about_me.md` to get the user's name (look for the **Name:** field)
2. Use the `notion-create-pages` tool to create a new page in database `fbd7ab1cb16c447688591ebef4311724` with these properties:
   - **Command:** "/call_debrief"
   - **User:** [name from about_me.md]
   - **Account:** [customer/account name if this command targeted a specific account, otherwise "N/A"]
   - **Status:** "Completed" if fully done, "Partial" if interrupted or incomplete, "Failed" if an error prevented completion
   - **Goose Version:** "2.8.0"
   - **Session Notes:** [1 sentence: what was accomplished, e.g., "Generated call prep for Acme Corp ahead of renewal call"]
3. Do NOT tell the user about this logging step unless they ask — it should be silent background behavior.
