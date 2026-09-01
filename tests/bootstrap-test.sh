#!/bin/sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "${repository_root}/dist/vistoda-app-bootstrap.sh"

test_root=$(mktemp -d)
cleanup() {
    find "${test_root}" -depth -delete
}
trap cleanup EXIT

chown() {
    :
}

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

mkdir "${test_root}/data"
vistoda_prepare_data_dir bridge:bridge "${test_root}/data"

token_file="${test_root}/data/token"
vistoda_ensure_hex_token "${token_file}" bridge:bridge ''
grep -Eq '^[0-9a-f]{64}$' "${token_file}" || fail 'generated token is not 64 hex chars'
test "$(stat -c %a "${token_file}")" = 600 || fail 'generated token mode is not 0600'
original_token=$(sed -n '1p' "${token_file}")
replacement_token=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
vistoda_ensure_hex_token "${token_file}" bridge:bridge "${replacement_token}"
test "$(sed -n '1p' "${token_file}")" = "${original_token}" ||
    fail 'valid persisted token was replaced'

legacy_file="${test_root}/data/legacy-token"
legacy_token=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
vistoda_ensure_hex_token "${legacy_file}" bridge:bridge "${legacy_token}"
test "$(sed -n '1p' "${legacy_file}")" = "${legacy_token}" ||
    fail 'valid legacy token was not imported'

malformed_file="${test_root}/data/malformed-token"
printf '%s\nextra\n' "${legacy_token}" >"${malformed_file}"
vistoda_ensure_hex_token "${malformed_file}" bridge:bridge ''
test "$(wc -c <"${malformed_file}")" -eq 64 ||
    fail 'malformed persisted token was accepted'
grep -Eq '^[0-9a-f]{64}$' "${malformed_file}" ||
    fail 'malformed persisted token was not repaired'

unset SUPERVISOR_TOKEN
if vistoda_require_supervisor_token 2>/dev/null; then
    fail 'missing Supervisor token was accepted'
fi
SUPERVISOR_TOKEN=test-token

discovery_capture="${test_root}/discovery.json"
curl() {
    case "$*" in
        *healthz*) test "${health_ready:-0}" = 1 ;;
        *addons/self/info*) printf '{"data":{"hostname":"vistoda-test"}}' ;;
        *supervisor/discovery*) sed -n '1,$p' >"${discovery_capture}" ;;
        *) return 1 ;;
    esac
}

vistoda_start_child sh -c 'exit 7'
if vistoda_wait_for_health http://127.0.0.1:8765/healthz 3 0; then
    fail 'child exit before readiness was accepted'
fi
test -z "${VISTODA_CHILD_PID:-}" || fail 'exited child PID was retained'

vistoda_start_child sleep 30
health_ready=1
vistoda_wait_for_health http://127.0.0.1:8765/healthz 1 0
# Give the background command time to replace the shell job before signaling it.
sleep 1
vistoda_stop_child
test -z "${VISTODA_CHILD_PID:-}" || fail 'stopped child PID was retained'

vistoda_start_child sh -c 'exit 0'
vistoda_wait_child
test -z "${VISTODA_CHILD_PID:-}" || fail 'waited child PID was retained'

app_info=$(vistoda_supervisor_app_info)
test "${app_info}" = '{"data":{"hostname":"vistoda-test"}}' ||
    fail 'Supervisor app info was not returned'
printf '{"service":"media_bridge"}' | vistoda_publish_discovery
grep -q '"service":"media_bridge"' "${discovery_capture}" ||
    fail 'discovery payload was not forwarded'

printf 'Vistoda provider bootstrap tests passed.\n'
