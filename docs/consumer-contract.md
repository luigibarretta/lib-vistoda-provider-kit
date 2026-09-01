# Consumer contract

## Ownership boundary

The kit owns Supervisor bootstrap and managed child lifecycle only. A provider
repository continues to own:

- provider options and their validation;
- provider credential storage and enrollment;
- generated provider configuration files;
- executable, user, port and health semantics;
- Home Assistant discovery service and payload fields;
- storage migration and product-specific rollback behavior.

New behavior enters this kit only after at least three provider consumers use
the same semantics and tests. Provider-specific branches do not belong here.

## Pinning and updates

1. Vendor `dist/vistoda-app-bootstrap.sh` without local edits.
2. Record the full upstream commit in `dependencies/vistoda-provider-kit.sha`.
3. Check out this repository at that SHA in consumer CI.
4. Compare the canonical and vendored files byte-for-byte.
5. Update the vendored file and commit pin atomically.

The provider image must copy the vendored file. It must never download the
library at image build or app startup.

## Fail-closed behavior

Missing Supervisor credentials, invalid generated tokens, a child that exits
before readiness, a health timeout or a failed discovery request terminates app
startup. Existing valid workload tokens are never rotated during normal boot.
