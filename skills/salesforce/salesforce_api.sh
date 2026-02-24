#!/bin/bash
# Salesforce API Integration for SE Command Center
# Usage: bash salesforce_api.sh <command> [args]
#
# Commands:
#   auth              - Test authentication, print instance URL
#   account <name>    - Get account details by name (fuzzy match)
#   products <acct_id> - Get account products (last 12 months start dates)
#   opps <acct_id>    - Get opportunities (last 12 months)
#   brightcove <acct_id> - Get Brightcove Account info (Publisher Status = Approved)
#   full <name>       - Full account pull: details + products + opps + brightcove
#   search <term>     - Search accounts by name
#
# Setup: Copy scripts/.env.example to scripts/.env and fill in credentials.
# Salesforce requires a Connected App — request via IT ticket.

set -euo pipefail

# Load credentials from .env
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../../scripts/.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "ERROR: .env file not found at $ENV_FILE"
    echo "Please copy scripts/.env.example to scripts/.env and fill in your credentials."
    exit 1
fi

# Authenticate and get access token
authenticate() {
    local auth_response
    auth_response=$(curl -s -X POST "$SF_TOKEN_URL" \
        -d "grant_type=password" \
        -d "client_id=${SF_CONSUMER_KEY}" \
        -d "client_secret=${SF_CONSUMER_SECRET}" \
        -d "username=${SF_USERNAME}" \
        -d "password=${SF_PASSWORD}${SF_SECURITY_TOKEN}")

    ACCESS_TOKEN=$(echo "$auth_response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('access_token',''))" 2>/dev/null)
    INSTANCE_URL=$(echo "$auth_response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('instance_url',''))" 2>/dev/null)

    if [ -z "$ACCESS_TOKEN" ]; then
        echo "ERROR: Authentication failed"
        echo "$auth_response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d, indent=2))" 2>/dev/null || echo "$auth_response"
        exit 1
    fi
}

# Run a SOQL query
sf_query() {
    local query="$1"
    local encoded_query
    encoded_query=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")

    curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "${INSTANCE_URL}/services/data/v65.0/query/?q=${encoded_query}"
}

# Run a SOQL query with proper encoding (for complex queries)
sf_query_safe() {
    local query="$1"
    python3 << PYEOF
import urllib.parse, urllib.request, json, os

token = os.environ.get('SF_ACCESS_TOKEN', '')
instance = os.environ.get('SF_INSTANCE', '')
query = """$query"""

encoded = urllib.parse.quote(query)
url = f"{instance}/services/data/v65.0/query/?q={encoded}"

req = urllib.request.Request(url)
req.add_header('Authorization', f'Bearer {token}')
req.add_header('Content-Type', 'application/json')

try:
    resp = urllib.request.urlopen(req)
    data = json.loads(resp.read().decode())
    print(json.dumps(data, indent=2))
except urllib.error.HTTPError as e:
    print(f"ERROR {e.code}: {e.read().decode()}")
PYEOF
}

# Export for Python subprocesses
export_auth() {
    export SF_ACCESS_TOKEN="$ACCESS_TOKEN"
    export SF_INSTANCE="$INSTANCE_URL"
}

CMD="${1:-help}"

case "$CMD" in
    auth)
        authenticate
        echo "✓ Authenticated successfully"
        echo "  Instance: $INSTANCE_URL"
        echo "  Token: ${ACCESS_TOKEN:0:20}..."
        ;;

    account)
        ACCOUNT_NAME="${2:?Usage: salesforce_api.sh account <name>}"
        authenticate
        export_auth

        # Search for account with key fields
        sf_query_safe "SELECT Id, Name, Website, Account_Stage__c, OwnerId, Owner.Name, \
Customer_Tier__c, Billing_Customer_ID__c, Description, \
BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, \
acc360_contract_renewal_date__c, acc360_contract_term_end_date__c, \
Account_Total_ACV__c, Account_Total_ARR__c, acc360_tenure_in_years__c, \
acc360_n_bcov_users__c, acc360_n_bcov_users_active_90d__c, acc360_bcov_last_login__c, \
LinkedIn_URL__c, Phone, Fax, Email_Domain_Name__c \
FROM Account WHERE Name LIKE '%${ACCOUNT_NAME}%' LIMIT 5"
        ;;

    products)
        ACCOUNT_ID="${2:?Usage: salesforce_api.sh products <account_id>}"
        authenticate
        export_auth

        # Get account products with start dates in last 12 months
        TWELVE_MONTHS_AGO=$(date -d "-12 months" +%Y-%m-%d 2>/dev/null || date -v-12m +%Y-%m-%d)
        sf_query_safe "SELECT Id, Name, Product_Name__c, Product_Customer_Price__c, \
Quantity__c, Start_Date__c, End_Date__c, Product_Description__c \
FROM Account_Product__c \
WHERE Account__c = '${ACCOUNT_ID}' \
AND Start_Date__c >= ${TWELVE_MONTHS_AGO} \
ORDER BY Start_Date__c DESC"
        ;;

    opps)
        ACCOUNT_ID="${2:?Usage: salesforce_api.sh opps <account_id>}"
        authenticate
        export_auth

        # Get opportunities from last 12 months
        TWELVE_MONTHS_AGO=$(date -d "-12 months" +%Y-%m-%d 2>/dev/null || date -v-12m +%Y-%m-%d)
        sf_query_safe "SELECT Id, Name, StageName, Amount, ACV__c, \
CloseDate, Type, Description \
FROM Opportunity \
WHERE AccountId = '${ACCOUNT_ID}' \
AND CreatedDate >= ${TWELVE_MONTHS_AGO}T00:00:00Z \
ORDER BY CloseDate DESC"
        ;;

    brightcove)
        ACCOUNT_ID="${2:?Usage: salesforce_api.sh brightcove <account_id>}"
        authenticate
        export_auth

        # Get Brightcove Account records where Publisher Status = Approved
        sf_query_safe "SELECT Id, Name, Brightcove_Account_Id__c, Publisher_Status__c, \
Is_Trial_Account__c \
FROM Brightcove_Account__c \
WHERE Account__c = '${ACCOUNT_ID}' \
AND Publisher_Status__c = 'APPROVED'"
        ;;

    search)
        SEARCH_TERM="${2:?Usage: salesforce_api.sh search <term>}"
        authenticate
        export_auth

        sf_query_safe "SELECT Id, Name, Account_Stage__c, Owner.Name, \
Customer_Tier__c, Account_Total_ACV__c, Phone \
FROM Account WHERE Name LIKE '%${SEARCH_TERM}%' \
ORDER BY Account_Total_ACV__c DESC NULLS LAST LIMIT 20"
        ;;

    full)
        ACCOUNT_NAME="${2:?Usage: salesforce_api.sh full <name>}"
        authenticate
        export_auth

        echo "=========================================="
        echo "FULL ACCOUNT PULL: $ACCOUNT_NAME"
        echo "=========================================="

        # Step 1: Find the account
        echo ""
        echo "--- ACCOUNT DETAILS ---"
        ACCT_JSON=$(sf_query_safe "SELECT Id, Name, Website, Account_Stage__c, Owner.Name, \
Customer_Tier__c, Billing_Customer_ID__c, Description, \
BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, \
acc360_contract_renewal_date__c, acc360_contract_term_end_date__c, \
Account_Total_ACV__c, Account_Total_ARR__c, acc360_tenure_in_years__c, \
acc360_n_bcov_users__c, acc360_n_bcov_users_active_90d__c, acc360_bcov_last_login__c, \
Phone, Email_Domain_Name__c \
FROM Account WHERE Name LIKE '%${ACCOUNT_NAME}%' LIMIT 1")
        echo "$ACCT_JSON"

        # Extract account ID
        ACCT_ID=$(echo "$ACCT_JSON" | python3 -c "
import sys, json
data = json.load(sys.stdin)
records = data.get('records', [])
if records:
    print(records[0]['Id'])
else:
    print('')
" 2>/dev/null)

        if [ -z "$ACCT_ID" ]; then
            echo "ERROR: No account found matching '$ACCOUNT_NAME'"
            exit 1
        fi

        echo ""
        echo "--- BRIGHTCOVE ACCOUNTS (Approved only) ---"
        sf_query_safe "SELECT Id, Name, Brightcove_Account_Id__c, Publisher_Status__c \
FROM Brightcove_Account__c \
WHERE Account__c = '${ACCT_ID}' AND Publisher_Status__c = 'APPROVED'"

        echo ""
        echo "--- ACCOUNT PRODUCTS (last 12 months) ---"
        TWELVE_MONTHS_AGO=$(date -d "-12 months" +%Y-%m-%d 2>/dev/null || date -v-12m +%Y-%m-%d)
        sf_query_safe "SELECT Name, Product_Name__c, Product_Customer_Price__c, \
Quantity__c, Start_Date__c, End_Date__c \
FROM Account_Product__c \
WHERE Account__c = '${ACCT_ID}' \
AND Start_Date__c >= ${TWELVE_MONTHS_AGO} \
ORDER BY Start_Date__c DESC"

        echo ""
        echo "--- OPPORTUNITIES (last 12 months) ---"
        sf_query_safe "SELECT Name, StageName, ACV__c, Amount, CloseDate, Type \
FROM Opportunity \
WHERE AccountId = '${ACCT_ID}' \
AND CreatedDate >= ${TWELVE_MONTHS_AGO}T00:00:00Z \
ORDER BY CloseDate DESC"

        echo ""
        echo "--- SALESFORCE LINK ---"
        echo "${INSTANCE_URL}/lightning/r/Account/${ACCT_ID}/view"
        ;;

    help|*)
        echo "Salesforce API Tool for SE Command Center"
        echo ""
        echo "Usage: bash salesforce_api.sh <command> [args]"
        echo ""
        echo "Commands:"
        echo "  auth                - Test authentication"
        echo "  account <name>      - Get account details by name"
        echo "  products <acct_id>  - Get account products (last 12 months)"
        echo "  opps <acct_id>      - Get opportunities (last 12 months)"
        echo "  brightcove <acct_id>- Get Brightcove Account info (Approved only)"
        echo "  search <term>       - Search accounts by name"
        echo "  full <name>         - Full account pull (all data)"
        echo ""
        echo "Brightcove Salesforce field reference:"
        echo "  - Account_Stage__c: Customer/Prospect"
        echo "  - Customer_Tier__c: Tier 1/2/3"
        echo "  - Billing_Customer_ID__c: Brightcove billing ID"
        echo "  - Account_Product__c: Custom object for products"
        echo "  - Brightcove_Account__c: Custom object for BC accounts"
        echo "  - Publisher_Status__c: APPROVED / LOCKED_TRIAL_EXPIRED"
        ;;
esac
