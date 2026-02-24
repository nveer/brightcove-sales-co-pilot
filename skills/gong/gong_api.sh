#!/usr/bin/env bash
# Gong API helper script
# Usage:
#   bash gong_api.sh search "CompanyName" [months_back] [--all]
#   bash gong_api.sh transcript "CALL_ID_1,CALL_ID_2"
#   bash gong_api.sh details "CALL_ID"
#
# By default, search filters to SE-attended calls only.
# Use --all flag to show all calls (no SE filter).

set -euo pipefail

# Load credentials from .env
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../../scripts/.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "ERROR: .env file not found at $ENV_FILE"
    echo "Expected: scripts/.env with GONG_ACCESS_KEY and GONG_ACCESS_KEY_SECRET"
    echo "Copy scripts/.env.example to scripts/.env and fill in your credentials."
    exit 1
fi

BASE_URL="${GONG_BASE_URL:-https://us-XXXXX.api.gong.io}"
AUTH_TOKEN=$(echo -n "${GONG_ACCESS_KEY}:${GONG_ACCESS_KEY_SECRET}" | base64 -w 0)

# ============================================================
# SE User IDs — IMPORTANT: Replace with your team's actual Gong user IDs
# Ask your Gong admin, or retrieve them via the Gong API once credentialed.
# Format: comma-separated list of numeric user IDs
# ============================================================
SE_IDS="~~your-gong-user-id~~,~~teammate-gong-user-id~~,~~teammate-gong-user-id~~"

COMMAND="${1:-help}"
ARG="${2:-}"
ARG3="${3:-1}"
ARG4="${4:-}"

gong_curl() {
    curl -s -X "$1" "${BASE_URL}$2" \
        -H "Authorization: Basic $AUTH_TOKEN" \
        -H "Content-Type: application/json" \
        ${3:+-d "$3"}
}

search_calls() {
    local company="$1"
    local months_back="${2:-1}"
    local show_all="${3:-}"
    local from_date
    from_date=$(date -u -d "$months_back months ago" +%Y-%m-%dT00:00:00Z 2>/dev/null || date -u -v-${months_back}m +%Y-%m-%dT00:00:00Z 2>/dev/null)
    local to_date
    to_date=$(date -u +%Y-%m-%dT23:59:59Z)

    # Step 1: Pull all calls in date range (paginated)
    local tmp_all="/tmp/gong_all_calls.json"
    echo "[]" > "$tmp_all"
    local cursor=""
    local page=0

    while true; do
        local url="/v2/calls?fromDateTime=${from_date}&toDateTime=${to_date}"
        [ -n "$cursor" ] && url="${url}&cursor=${cursor}"

        local response
        response=$(gong_curl GET "$url")

        echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
new_calls = data.get('calls', [])
existing = json.load(open('$tmp_all'))
existing.extend(new_calls)
json.dump(existing, open('$tmp_all', 'w'))
" 2>/dev/null

        cursor=$(echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
cursor = data.get('records', {}).get('cursor', '')
print(cursor)
" 2>/dev/null || echo "")

        page=$((page + 1))
        [ -z "$cursor" ] && break
        [ $page -ge 10 ] && break
    done

    # Step 2: Filter by company name
    python3 -c "
import json, sys
calls = json.load(open('$tmp_all'))
company = sys.argv[1].lower()
matches = [c for c in calls if company in c.get('title', '').lower()]
json.dump(matches, open('/tmp/gong_company_matches.json', 'w'))
print(f'Found {len(matches)} calls matching \"{sys.argv[1]}\"', file=sys.stderr)
" "$company" 2>&1 >&2

    # If --all flag, skip SE filtering
    if [ "$show_all" = "--all" ]; then
        python3 -c "
import json
matches = json.load(open('/tmp/gong_company_matches.json'))
matches.sort(key=lambda c: c.get('started', ''), reverse=True)
for c in matches:
    dur = c.get('duration', 0) // 60
    print(f\"ID: {c['id']}\")
    print(f\"  Title: {c.get('title', 'N/A')}\")
    print(f\"  Date: {c.get('started', c.get('scheduled', 'N/A'))}\")
    print(f\"  Duration: {dur}m\")
    print(f\"  URL: {c.get('url', 'N/A')}\")
    print(f\"  SE Filter: OFF (showing all calls)\")
    print()
print(f'Total matches: {len(matches)}')
"
        return
    fi

    # Step 3: Get participant data for matching calls via /v2/calls/extensive
    GONG_SEARCH_COMPANY="$company" GONG_AUTH_TOKEN="$AUTH_TOKEN" GONG_API_BASE="$BASE_URL" SE_IDS="$SE_IDS" python3 << 'PYEOF'
import json, subprocess, sys, os

matches = json.load(open('/tmp/gong_company_matches.json'))
if not matches:
    print("No calls found matching that company name.")
    sys.exit(0)

se_ids = set(os.environ.get('SE_IDS', '').split(','))

auth_token = os.environ.get('GONG_AUTH_TOKEN', '')
base_url = os.environ.get('GONG_API_BASE', '')

# Batch call IDs (extensive endpoint supports multiple)
call_ids = [c['id'] for c in matches]

# Process in batches of 50
se_calls = []
for i in range(0, len(call_ids), 50):
    batch = call_ids[i:i+50]
    body = json.dumps({
        "filter": {"callIds": batch},
        "contentSelector": {"exposedFields": {"parties": True}}
    })
    result = subprocess.run(
        ["curl", "-s", "-X", "POST", f"{base_url}/v2/calls/extensive",
         "-H", f"Authorization: Basic {auth_token}",
         "-H", "Content-Type: application/json",
         "-d", body],
        capture_output=True, text=True
    )
    try:
        data = json.loads(result.stdout)
    except:
        continue

    for call in data.get('calls', []):
        call_id = call.get('metaData', {}).get('id', '')
        parties = call.get('parties', [])
        party_user_ids = [str(p.get('userId', '')) for p in parties]
        matched_ses = [uid for uid in party_user_ids if uid in se_ids]
        if matched_ses:
            meta = call.get('metaData', {})
            se_calls.append({
                'id': call_id,
                'title': meta.get('title', 'N/A'),
                'started': meta.get('started', meta.get('scheduled', 'N/A')),
                'duration': meta.get('duration', 0),
                'url': meta.get('url', 'N/A'),
                'ses': matched_ses
            })

# Sort by date descending
se_calls.sort(key=lambda c: c.get('started', ''), reverse=True)

for c in se_calls:
    dur = c['duration'] // 60 if isinstance(c['duration'], (int, float)) else 0
    se_list = ', '.join(c['ses'])
    print(f"ID: {c['id']}")
    print(f"  Title: {c['title']}")
    print(f"  Date: {c['started']}")
    print(f"  Duration: {dur}m")
    print(f"  URL: {c['url']}")
    print(f"  SEs on call: {se_list}")
    print()

company_name = os.environ.get('GONG_SEARCH_COMPANY', '?')
print(f"SE-attended calls: {len(se_calls)} (out of {len(matches)} total matching \"{company_name}\")")
PYEOF
}

get_transcript() {
    local call_ids_str="$1"
    IFS=',' read -ra IDS <<< "$call_ids_str"

    local ids_json="["
    for i in "${!IDS[@]}"; do
        [ $i -gt 0 ] && ids_json+=","
        ids_json+="\"${IDS[$i]}\""
    done
    ids_json+="]"

    local body="{\"filter\": {\"callIds\": $ids_json}}"
    local response
    response=$(gong_curl POST "/v2/calls/transcript" "$body")

    echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
transcripts = data.get('callTranscripts', [])
for t in transcripts:
    call_id = t.get('callId', 'unknown')
    print(f'=== Call: {call_id} ===')
    for seg in t.get('transcript', []):
        speaker = seg.get('speakerName', seg.get('speakerId', 'Unknown'))
        topic = seg.get('topic', '')
        if topic:
            print(f'\n--- Topic: {topic} ---')
        sentences = seg.get('sentences', [])
        text = ' '.join(s.get('text', '') for s in sentences)
        if text.strip():
            print(f'{speaker}: {text}')
    print()
"
}

get_details() {
    local call_id="$1"
    local response
    response=$(gong_curl GET "/v2/calls/$call_id")
    echo "$response" | python3 -m json.tool
}

case "$COMMAND" in
    search)
        [ -z "$ARG" ] && { echo "Usage: gong_api.sh search <company_name> [months_back] [--all]"; exit 1; }
        search_calls "$ARG" "$ARG3" "$ARG4"
        ;;
    transcript)
        [ -z "$ARG" ] && { echo "Usage: gong_api.sh transcript <call_id1,call_id2,...>"; exit 1; }
        get_transcript "$ARG"
        ;;
    details)
        [ -z "$ARG" ] && { echo "Usage: gong_api.sh details <call_id>"; exit 1; }
        get_details "$ARG"
        ;;
    *)
        echo "Gong API Helper"
        echo "Usage:"
        echo "  gong_api.sh search <company_name> [months_back] [--all]  Search calls by company (SE-filtered by default)"
        echo "  gong_api.sh transcript <id1,id2,...>                      Get call transcripts"
        echo "  gong_api.sh details <call_id>                             Get call details"
        echo ""
        echo "Flags:"
        echo "  --all    Show all matching calls, not just SE-attended ones"
        ;;
esac
