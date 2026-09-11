# Changelog

## 0.1.1 - 2026-09-11

- Preserve the provider PID during wait and forward TERM/INT until it exits.
- Stop providers on bootstrap failure, with a bounded shutdown grace period.
- Remove Supervisor authority from the provider environment.
- Bound Supervisor connection, request and retry times.
- Verify lifecycle and credential isolation with executable shell tests.

## 0.1.0 - 2026-09-01

- Add shared workload-token creation and restored-secret normalization.
- Add managed child signal handling and bounded health readiness.
- Add Supervisor app-info and discovery publication helpers.
- Define the SHA-pinned, byte-verified provider consumer contract.
