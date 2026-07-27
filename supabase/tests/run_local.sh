#!/usr/bin/env bash
# Run the RLS negative tests against a plain Postgres — no Docker, no Supabase
# CLI. Applies the shim, then every migration in order, then every test file.
#
#   ./supabase/tests/run_local.sh                 # uses a local server on 5432
#   PGHOST=/tmp PGPORT=5433 ./supabase/tests/run_local.sh
#
# `supabase test db` (which needs Docker) remains the higher-fidelity run: it
# uses the REAL auth schema and Supabase's own grants rather than this shim.
# CI runs this one because it is fast and hermetic; run the Docker one before
# a release.
set -euo pipefail

cd "$(dirname "$0")/../.."

PGUSER="${PGUSER:-postgres}"
DB="${DB:-rls_negative_tests}"
PSQL=(psql -X -q -v ON_ERROR_STOP=1 -U "$PGUSER")

echo "==> Creating $DB"
"${PSQL[@]}" -d postgres -c "drop database if exists $DB;" \
                         -c "create database $DB;"

echo "==> Loading Supabase shim"
"${PSQL[@]}" -d "$DB" -f supabase/tests/00_supabase_shim.sql >/dev/null

echo "==> Applying migrations"
for migration in supabase/migrations/*.sql; do
  echo "    $(basename "$migration")"
  "${PSQL[@]}" -d "$DB" -f "$migration" >/dev/null
done

failed=0
for suite in supabase/tests/rls_*_test.sql; do
  echo "==> $(basename "$suite")"
  # Each suite is a transaction that rolls back, so order does not matter.
  output="$(psql -X -q -t -U "$PGUSER" -d "$DB" -f "$suite" 2>&1)"
  echo "$output" | grep -E '^\s*(ok|not ok) ' | sed 's/^ */    /' || true

  if echo "$output" | grep -qE '^\s*not ok |ERROR:'; then
    echo "    FAILED:"
    echo "$output" | grep -E '^\s*not ok |ERROR:' | sed 's/^ */      /'
    failed=1
  fi
done

"${PSQL[@]}" -d postgres -c "drop database if exists $DB;" >/dev/null

if [ "$failed" -ne 0 ]; then
  echo "RLS negative tests FAILED"
  exit 1
fi
echo "All RLS negative tests passed."
