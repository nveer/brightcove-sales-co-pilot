# /email_triage — Inbox Triage & Response Drafting

## Purpose
Scan Gmail inbox, categorize emails by action needed, archive noise, draft responses to answerable questions, and produce a summary. Goal: reduce inbox to only emails that require hands-on work.

## When to Run
- Morning routine (pair with /daily_prep)
- End of day cleanup
- Anytime user says "triage my email", "clean up my inbox", "help with email"

## Input
- Optional: time window (default: `newer_than:7d`)
- Optional: specific focus ("just this week", "last 24 hours", "unread only")

## Workflow

### Step 1: Scan Inbox
1. Search `is:unread in:inbox newer_than:7d` (or specified window)
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
6. **Show draft before sending** — ALWAYS. Never auto-send. Present each draft with a 1–2 sentence "what they said" context summary (the last thing the customer wrote) so the user knows exactly what they're responding to without having to recall the thread.
   - **After ANY edit is requested** — show the fully updated draft again and wait for explicit send approval ("send it", "yes", "go ahead") before sending. Never auto-send after making edits. Edit request ≠ send approval.
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
