# /email_triage — Inbox Triage & Response Drafting

## Purpose
Scan Gmail inbox, categorize emails by action needed, archive noise, draft responses to answerable questions, and produce a summary. Goal: reduce inbox to only emails that require hands-on work.

## When to Run
- Morning routine (pair with /daily_prep)
- End of day cleanup
- Anytime user says "triage my email", "clean up my inbox", "help with email"

## Input
- Optional: time window override (default: two-pass scan below)
- Optional: specific focus ("just this week", "last 24 hours", "unread only")

## Tools Required
- **Gmail Write connector** — send, archive, batch modify, labels, read, search. ⚠️ Known limitation: `send_email`/`draft_email` do not support `threadId`/`inReplyTo`. Replies to existing threads must be sent manually from Gmail to preserve threading until the threading fix is confirmed.
- **Gmail Registry connector** *(pending connection test)* — `read_thread` (gets Message-ID header for `inReplyTo`), `create_draft` (may support `threadId` for threaded drafts). Connect alongside the primary Gmail connector to enable reply threading. When connected, workflow: (1) `read_thread` → extract Message-ID, (2) `create_draft` with threadId → send from Gmail.
- **WebFetch / WebSearch** — for Brightcove doc research
- **Brightcove support docs** — https://support.brightcove.com/ (source of truth)

## Workflow

### Step 1: Scan Inbox (Two-Pass Default)
**Default scan is two-pass** — runs both passes every triage session:
- **Pass 1:** `is:unread in:inbox newer_than:1d` (last 24 hours)
- **Pass 2:** `is:unread in:inbox older_than:1d newer_than:3d` (previous 2 days)
- Merge results and deduplicate by `threadId` before categorization
- If user specifies a custom window, use that instead of the two-pass default

1. Search using the two-pass approach above (or specified window)
2. Page through ALL results — don't stop at page 1
3. Capture: ID, threadId, from, to, subject, date, snippet, labels

### Step 1b: Group by Thread / Case
Group emails by threadId and support case number before categorizing:
1. **Thread grouping** — Multiple emails with same threadId = one conversation. Read once, act once.
2. **Support case grouping** — Emails with same case number = one group, even across different threadIds
3. **Evaluation rule** — Read the LATEST message in each group. If latest triggers a flag, keep ALL. If safe to archive, archive ALL.

### Step 2: Categorize Every Email Group

| Category | Icon | Rule | Action |
|----------|------|------|--------|
| **Customer Question** | 🔵 | External sender asking a direct question | Draft response |
| **Support CC** | 🟡 | From support system or support case thread | Apply Support Filter (Step 3) |
| **Calendar Invite** | ⚪ | Subject contains "Invitation:" or "Updated invitation:" | Skip (user handles) |
| **Internal FYI** | ⚫ | From internal domain, CC'd not TO'd, informational | Archive candidate |
| **Promo / Automated** | 🔴 | Newsletters, 2FA resets, marketing | Archive |
| **Needs Work** | 🟢 | Requires creating something, running a trial, building a demo | Leave in inbox |
| **Escalation** | 🔴🔴 | Customer frustration, urgent language, deadline pressure | Flag + alert user |

### Step 3: Support Email Filter (CRITICAL)
Before archiving ANY support case email, check all three:

1. **Name Callout** — Does the email body mention you by name (not just CC'd)? If YES → do NOT archive. Flag.
2. **Customer Frustration** — "still waiting", "when will", "urgent", "frustrated", multiple follow-ups? If YES → do NOT archive.
3. **Stalled/Circular** — Support apologizing for delays, case age >14 days, same question repeated? If YES → do NOT archive.

**If NONE triggered** → safe to archive.

### Step 4: Archive in Batches
1. Collect all archive-safe email IDs (include every message in the group)
2. Present list to user with counts by category
3. Wait for approval before archiving
4. Use `batch_modify_emails` with `removeLabelIds: ["INBOX", "UNREAD"]`
5. Archive in batches of 50 max

### Step 5: Draft Responses
For **Customer Question** emails:

1. **Read the FULL thread** — not just the latest message. Non-negotiable.
2. **Check what was already said** — Never repeat, contradict, or re-explain things already covered
3. **Research the answer:**
   - https://support.brightcove.com/ (source of truth)
   - sdks.support.brightcove.com for SDK questions
   - apis.support.brightcove.com for API questions
   - studio.support.brightcove.com for product/Studio questions
4. **Draft the reply:**
   - Warm, concise, makes complex things simple
   - No scolding language ("as I mentioned", "I already covered this")
   - Use helpful callbacks ("For reference, those docs are in the earlier thread")
   - **Never offer a call by default** — Brightcove is a self-serve platform. Default closing is "Let me know if you have any questions." Only offer a call if: (a) the customer is clearly frustrated/upset, OR (b) they have asked the same question multiple times and the issue remains unresolved
   - Plain URL links (not markdown — email clients don't render it)
5. **Reply-to-all on existing threads (MANDATORY):**
   - ALWAYS use reply-to-all when responding to an existing thread — never create a new email
   - Pass `threadId` AND `inReplyTo` (the message ID of the latest message in the thread) to `send_email` / `draft_email`
   - Populate `to:` with the original sender + all original `to:` recipients (minus yourself)
   - Populate `cc:` with all original `cc:` recipients (minus yourself)
   - **Only create a new email** if there is NO existing thread (truly first-touch outreach with no prior conversation)
   - **PRE-SEND THREADING CHECKLIST (BLOCK SEND IF ANY MISSING):**
     Before calling `send_email` or `draft_email` for a reply, verify ALL four fields are populated. If ANY are missing, STOP and extract them from the thread before proceeding:
     ```
     ☐ threadId: [extracted from gmail_read_thread response]
     ☐ inReplyTo: [message ID of the LATEST message in the thread — NOT the threadId]
     ☐ to: [original sender + all TO recipients, minus yourself]
     ☐ cc: [all CC recipients, minus yourself]
     ```
     **CRITICAL:** `inReplyTo` must be the `messageId` of the last message in the thread (looks like `<CAxxxxxxx@mail.gmail.com>`), NOT the `threadId`. Without this, Gmail starts a new thread even if `threadId` is correct. Extract it from the `Message-ID` header of the latest message returned by `gmail_read_thread`.
6. **Show draft before sending** — ALWAYS. Never auto-send. Present each draft with a 1–2 sentence "what they said" context summary (the last thing the customer wrote) so the user knows exactly what they're responding to without having to recall the thread.
   - **After ANY edit is requested** — show the fully updated draft again and wait for explicit send approval ("send it", "yes", "go ahead") before sending. Never auto-send after making edits. Edit request ≠ send approval.
   - **Multi-draft review doc (MANDATORY when 2+ drafts)** — When 2 or more drafts are ready in the same triage session, do NOT present them inline in chat. Create a `draft-review-YYYY-MM-DD.md` file in `/outputs/` with all drafts side by side. Each entry: 2–3 sentence context summary, subject line, recipient/CC list, draft ID, and full body. User approves by saying "send A", "send B", or "send both".
7. **Auto-archive after send** — Immediately after any draft is sent, archive the source thread by calling `batch_modify_emails` with `removeLabelIds: ["INBOX", "UNREAD"]` on all message IDs in that thread. This is default behavior — do not wait for the user to say "archive it."

### Step 6: Produce Summary File
Save to `outputs/email-triage-[YYYY-MM-DD].md`:

```markdown
# Email Triage — [Date]

## Stats
- Emails scanned: [X]
- Archived: [X]
- Drafts ready: [X]
- Left in inbox: [X]

## 📝 Drafts (Review & Approve)
### [Contact] @ [Company] — [Topic]
> [Draft text]

## ⚠️ Flagged Support Cases
- **Case [number]** — [Customer]: [reason flagged]

## 📌 Left in Inbox (Require Work)
- **[Contact] @ [Company]** — [what needs to be done]
```

### Step 7: Interactive Review Loop
1. User reviews drafts one by one
2. For each: approve → send, edit → revise, skip
3. After any edit, re-show the full revised draft and wait for explicit send approval before sending
4. Only send when user explicitly says "send it" / "perfect" / "go ahead"
5. After sending, immediately auto-archive the thread (Step 5.7 above)
6. Update summary file with SENT status after each send

## Constraints
- **Never auto-send emails.** Always get explicit approval.
- Never fabricate documentation URLs.
- Always read full threads before drafting.
- Angry customer emails → do NOT draft. Flag as escalation.
