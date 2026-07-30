#!/usr/bin/env bash
# Attack the live backend with the same credentials any visitor already has.
#
# WHY THIS EXISTS
# ---------------
# The publishable key ships inside the web bundle. That is by design — it
# grants nothing on its own — but it means "open devtools and read the key" is
# not an attack, it is step zero. Everything after that is a plain HTTPS
# request that no amount of client-side code can prevent.
#
# So the only real question is: with that key, what can someone actually do?
# This script asks the deployed server directly, the way an attacker would,
# instead of asking the Dart code what it intends to allow.
#
# The pgTAP suite (supabase/tests/) proves the policies are correct in a local
# database. This proves they are actually APPLIED to the real project — which
# is a different claim, and the one that fails when a migration was written
# but never run.
#
#   ./supabase/probe_public_api.sh
#   SUPABASE_URL=... SUPABASE_KEY=... ./supabase/probe_public_api.sh
#
# Exit code 0 = nothing exposed. Non-zero = at least one FAIL, read the output.
set -uo pipefail

URL="${SUPABASE_URL:-https://orsqjucexvrefmexztay.supabase.co}"
KEY="${SUPABASE_KEY:-sb_publishable_8MiEskdUG4ySAf-xHTpX6w_1Y8yLXch}"
REST="$URL/rest/v1"

pass=0; fail=0
ok()   { printf '  \033[32mPASS\033[0m  %s\n' "$1"; pass=$((pass+1)); }
bad()  { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fail=$((fail+1)); }
note() { printf '        %s\n' "$1"; }

req() { # req METHOD PATH [BODY] -> "HTTPCODE<TAB>BODY"
  local method="$1" path="$2" body="${3:-}"
  local args=(-s -o /tmp/.probe_body -w '%{http_code}' -X "$method"
              -H "apikey: $KEY" -H "Authorization: Bearer ${TOKEN:-$KEY}"
              -H 'Content-Type: application/json' -m 20)
  [ -n "$body" ] && args+=(-d "$body")
  local code; code="$(curl "${args[@]}" "$REST$path" 2>/dev/null)"
  printf '%s\t%s' "$code" "$(head -c 400 /tmp/.probe_body 2>/dev/null)"
}

# A row count of 0 and a 401/403 are both "nothing leaked". A 200 with rows is
# the thing we are hunting for.
leaked() { # leaked RESPONSE -> true when the body contains at least one row
  local body="${1#*$'\t'}"
  [[ "$body" == \[*  && "$body" != "[]" ]]
}

# A per-request 000 means that one call never completed. Report it as unknown
# rather than folding it into either column.
unknown=0
inconclusive() { printf '  \033[33mSKIP\033[0m  %s (no response)\n' "$1"; unknown=$((unknown+1)); }
blocked() { # blocked RESPONSE CODES... -> 0 when the server refused it
  local code="${1%%$'\t'*}"; shift
  [ "$code" = "000" ] && return 2
  for c in "$@"; do [ "$code" = "$c" ] && return 0; done
  return 1
}

echo
echo "Probing $URL"
echo "as an anonymous visitor holding the bundled publishable key"
echo

# Reachability first. curl reports 000 for "never got a response", and a probe
# that reads a network failure as "the server accepted my malicious write"
# would be worse than no probe at all — it would train you to ignore it.
probe_code="$(curl -s -o /dev/null -w '%{http_code}' -m 20 \
  -H "apikey: $KEY" "$REST/" 2>/dev/null)"
if [ "$probe_code" = "000" ]; then
  echo "  Could not reach $URL at all (no HTTP response)."
  echo "  Check the URL, your network, or any proxy in the way."
  echo "  Nothing was tested — this is NOT a pass and NOT a failure."
  exit 2
fi

# --------------------------------------------------------------- anon session
# The app signs in anonymously on its own, so this is the realistic attacker:
# not the `anon` Postgres role but a real `authenticated` JWT. Policies written
# `to authenticated` are NOT a barrier against them.
TOKEN=""
anon="$(curl -s -m 20 -X POST "$URL/auth/v1/signup" \
  -H "apikey: $KEY" -H 'Content-Type: application/json' -d '{}' 2>/dev/null)"
TOKEN="$(printf '%s' "$anon" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')"

if [ -n "$TOKEN" ]; then
  echo "Anonymous sign-in: enabled — probing as an authenticated anonymous user."
else
  TOKEN="$KEY"
  echo "Anonymous sign-in: unavailable — probing with the publishable key only."
  note "Enable it and re-run: this is the account an attacker actually gets."
fi
echo

# ------------------------------------------------------------ what may be read
echo "Public by design (these SHOULD be readable):"
r="$(req GET '/facilities?select=id&limit=1')"
[[ "${r%%$'\t'*}" == 200 ]] && ok "facilities readable" \
  || bad "facilities NOT readable (${r%%$'\t'*}) — the map will be empty"
r="$(req GET '/alerts?select=id&limit=1')"
[[ "${r%%$'\t'*}" == 200 ]] && ok "alerts readable" \
  || bad "alerts NOT readable (${r%%$'\t'*})"
echo

# ----------------------------------------------------------- what must not be
echo "Must NOT be readable by a stranger:"
for t in submissions sos_signals audit_log user_trust group_members \
         group_pins group_invites group_messages group_key_envelopes; do
  r="$(req GET "/$t?select=*&limit=5")"
  if leaked "$r"; then
    bad "$t LEAKS ROWS"
    note "${r#*$'\t'}"
  else
    ok "$t exposes nothing (${r%%$'\t'*})"
  fi
done
echo

echo "Must NOT be writable:"
# 1. The classic: publish straight to the public map.
r="$(req POST '/facilities' '{"name":"probe","type":"water","status":"good","lat":0,"lng":0}')"
blocked "$r" 401 403 404; case $? in
  0) ok "cannot insert a facility (${r%%$'\t'*})" ;;
  2) inconclusive "insert a facility" ;;
  *) bad "INSERTED A FACILITY (${r%%$'\t'*})"; note "${r#*$'\t'}" ;;
esac

# 2. Self-approve on submit — the payload the app never sends but anyone can.
r="$(req POST '/submissions' '{"client_id":"probe-1","payload":{},"state":"approved"}')"
blocked "$r" 401 403 400; case $? in
  0) ok "cannot submit pre-approved (${r%%$'\t'*})" ;;
  2) inconclusive "submit pre-approved" ;;
  *) bad "ACCEPTED A PRE-APPROVED SUBMISSION (${r%%$'\t'*})"; note "${r#*$'\t'}" ;;
esac

# 3. Broadcast a fake critical alert to every user of the app.
r="$(req POST '/alerts' '{"severity":"critical","body":"probe"}')"
blocked "$r" 401 403; case $? in
  0) ok "cannot broadcast an alert (${r%%$'\t'*})" ;;
  2) inconclusive "broadcast an alert" ;;
  *) bad "BROADCAST AN ALERT (${r%%$'\t'*})"; note "${r#*$'\t'}" ;;
esac

# 4. ADR-36: join an arbitrary group as an active admin. This one WAS possible.
gid="$(curl -s -m 20 -H "apikey: $KEY" -H "Authorization: Bearer $TOKEN" \
  "$REST/groups?select=id&visibility=eq.public&limit=1" 2>/dev/null \
  | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')"
if [ -n "$gid" ]; then
  r="$(req POST '/group_members' \
      "{\"group_id\":\"$gid\",\"role\":\"admin\",\"state\":\"active\"}")"
  blocked "$r" 401 403 404; case $? in
    0) ok "cannot self-join a group as admin (${r%%$'\t'*})" ;;
    2) inconclusive "self-join as admin" ;;
    *) bad "SELF-JOINED GROUP $gid AS ADMIN (${r%%$'\t'*})"
       note "Apply 20260730000007_join_hardening.sql — this is ADR-36." ;;
  esac
else
  note "No public group to test the ADR-36 self-join against — skipped."
fi

# 5. Grant yourself standing.
r="$(req POST '/user_trust' '{"tier":"verifier","approved":99}')"
blocked "$r" 401 403 404; case $? in
  0) ok "cannot grant itself trust (${r%%$'\t'*})" ;;
  2) inconclusive "grant itself trust" ;;
  *) bad "WROTE A TRUST ROW (${r%%$'\t'*})"; note "${r#*$'\t'}" ;;
esac

# 6. Call an admin-only decision function directly, skipping the UI entirely.
r="$(curl -s -o /tmp/.probe_body -w '%{http_code}' -m 20 -X POST \
      "$URL/rest/v1/rpc/approve_submission" \
      -H "apikey: $KEY" -H "Authorization: Bearer $TOKEN" \
      -H 'Content-Type: application/json' \
      -d '{"p_submission_id":"00000000-0000-0000-0000-000000000000"}' 2>/dev/null)"
if [ "$r" = "000" ]; then inconclusive "approve_submission"
elif [ "$r" != 200 ]; then ok "approve_submission refuses a non-admin ($r)"
else bad "approve_submission ACCEPTED a non-admin call"; fi

echo
echo "----------------------------------------------------------------"
printf '  %d passed, %d failed, %d inconclusive\n' "$pass" "$fail" "$unknown"
if [ "$fail" -gt 0 ]; then
  echo
  echo "  Something is exposed. The usual cause is a migration that was"
  echo "  written but never applied — run supabase/status.sql first."
  exit 1
fi
echo "  Nothing exposed to a stranger holding the public key."
