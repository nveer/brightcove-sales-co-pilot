# /migrate-history — One-Time Private DB Migration

## Purpose
Migrates a rep's existing call follow-up history from their private "Call Follow-Ups" Notion database into the shared Active Customers DB. Run once after installing the updated Goose plugin. Safe to re-run — duplicate detection prevents double entries.

## When to Run
- After installing the updated Goose plugin for the first time
- Only needs to be run once per rep

---

## Workflow

### Step 1: Locate the Rep's Private Database
- Search Notion for "Call Follow-Ups" (type = database)
- Look for one owned by or nested under "Sales Co-Pilot — [Rep Name]"
- **If not found:** Tell the user: *"No private Call Follow-Ups database found — nothing to migrate. You're all set!"* and stop.
- **If found:** Confirm with the user before proceeding:
  > "I found your private Call Follow-Ups database with [X] entries. I'll migrate these into the shared Active Customers database. This won't delete your private records — they'll stay as-is and just get tagged as migrated. Ready to proceed?"

### Step 2: Fetch All Entries from Private DB
- Use `notion-fetch` on the private database to retrieve all pages
- For each entry, capture:
  - **Page title** (customer + date)
  - **Customer name** (from the Customer select field)
  - **Date**
  - **Full page content**
  - **Attendees**
  - **Status**

### Step 3: Migrate Each Entry
For each entry in the private database:

1. **Match customer** — Search the shared Active Customers DB (`collection://6850738f-64b9-424c-a0a3-ed2b5bff1866`) for the customer by name
2. **If customer found:**
   - Fetch the existing customer page
   - APPEND the historical entry at the bottom under a collapsible `## Migrated History` section
   - Attribution header:
     > **Migrated from:** [Rep Name]'s private database | **Original date:** [Date] | **Source:** Call Follow-Ups
3. **If customer not found:**
   - Create a new customer row in the shared Active Customers DB
   - Write the historical entry as the initial content with the same attribution header
4. **Duplicate check before each write** — Search for an existing entry with the same customer + date. If found, skip and log as "already exists"

### Step 4: Tag Migrated Entries in Private DB
- For each successfully migrated entry in the private database, add a comment:
  > "Migrated to shared Active Customers DB on [today's date]"
- Do **NOT** delete or modify the original content — private records stay intact

### Step 5: Summary Report
When migration is complete, tell the user:

```
✅ Migration complete!
- [X] entries migrated to the shared Active Customers database
- [X] entries skipped (already existed)
- [X] new customer rows created

Your private database is untouched — entries have been tagged as migrated.
You're all set. Going forward, all call companion output will go directly to the shared database.
```

If any entries failed, list them clearly so the user can handle them manually.

---

## Important Rules
- **NEVER** delete or overwrite content in the private database
- **NEVER** replace existing content in the shared Active Customers DB — append only
- Always run duplicate check before writing to avoid double entries
- If the shared Active Customers DB is inaccessible, stop and warn: *"The shared Active Customers database isn't accessible. Please check your Notion permissions and try again."*
- Migrate in **chronological order** (oldest first) so history reads naturally
- If the private DB has more than 50 entries, process in **batches of 20** and show progress between batches
