---
description: "DEPRECATED — Salesforce direct API skill. All Salesforce data is now accessed via Brightcove Gateway (BigQuery)."
---

# ⚠️ DEPRECATED — Salesforce Skill

> **This skill is no longer used.** All Salesforce data is now accessed via the Brightcove Gateway (BigQuery MCP).
> Use `brightcove-lumenx-42.external_shared_views` tables: `v_salesforce_account`, `v_salesforce_opportunity`, `v_done_deal_contracts`, `v_raw_salesforce_*`, etc.
> This file is retained only in case Salesforce write-back is ever needed in the future.

# Salesforce Skill — GOOSE [DEPRECATED]

## Overview
~~Queries your Brightcove Salesforce instance for account intelligence. Used in call prep, account summaries, and account context enrichment.~~
**Replaced by Brightcove Gateway (BigQuery). Do not use.**

## Authentication
- OAuth 2.0 Password Flow
- Credentials stored in `scripts/.env` (SF_CONSUMER_KEY, SF_CONSUMER_SECRET, SF_USERNAME, SF_PASSWORD, SF_SECURITY_TOKEN)
- Instance: brightcove2.lightning.force.com
- API Version: v65.0

## Script
`salesforce_api.sh` — Bash + Python script that authenticates and runs SOQL queries.

## Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `auth` | `bash salesforce_api.sh auth` | Test authentication |
| `account` | `bash salesforce_api.sh account "CustomerName"` | Get account details by name |
| `products` | `bash salesforce_api.sh products <acct_id>` | Account products (last 12 months) |
| `opps` | `bash salesforce_api.sh opps <acct_id>` | Opportunities (last 12 months) |
| `brightcove` | `bash salesforce_api.sh brightcove <acct_id>` | Brightcove accounts (Approved only) |
| `search` | `bash salesforce_api.sh search "Name"` | Search accounts by name |
| `full` | `bash salesforce_api.sh full "CustomerName"` | Full pull: details + products + opps + brightcove |

## Key Salesforce Objects & Fields

### Account (standard + custom)
- `Name`, `Website`, `Phone`, `Email_Domain_Name__c`
- `Account_Stage__c`: Customer / Prospect
- `Customer_Tier__c`: Tier 1, 2, 3
- `Owner.Name`: Account Owner (AE/CSM)
- `Billing_Customer_ID__c`: Brightcove billing customer ID
- `Account_Total_ACV__c`, `Account_Total_ARR__c`: Revenue
- `acc360_contract_renewal_date__c`, `acc360_contract_term_end_date__c`: Contract dates
- `acc360_tenure_in_years__c`: How long they've been a customer
- `acc360_n_bcov_users__c`, `acc360_n_bcov_users_active_90d__c`: Platform usage
- `acc360_bcov_last_login__c`: Last login date

### Account_Product__c (custom object)
- `Product_Name__c`, `Product_Customer_Price__c`, `Quantity__c`
- `Start_Date__c`, `End_Date__c`: Product contract period

### Opportunity (standard + custom)
- `Name`, `StageName`, `Amount`, `ACV__c`, `CloseDate`, `Type`

### Brightcove_Account__c (custom object)
- `Brightcove_Account_Id__c`: The Brightcove platform account ID
- `Publisher_Status__c`: APPROVED / LOCKED_TRIAL_EXPIRED / etc.
- Filter: Publisher_Status__c = 'APPROVED' to exclude expired trials

## Usage in Commands
- **/call_prep**: Run `full` for the customer — gets ACV, products, renewal date, Brightcove account status
- **/account_summary**: Use `full` for complete picture alongside Gong data
- **/call_debrief**: Reference account details when logging outcomes
