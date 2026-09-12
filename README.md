# lib-vistoda-provider-kit

`lib-vistoda-provider-kit` is the canonical repository for the versioned
bootstrap library shared by
Vistoda Home Assistant provider apps. It is intentionally smaller than a
runtime framework: providers keep ownership of their configuration, process
command, ports, health contract, discovery schema and provider credentials.

New contributors should read the Vistoda family
[contribution guide](https://github.com/luigibarretta/vistoda-home-assistant/blob/main/CONTRIBUTING.md)
before changing a consumer or the vendored bootstrap contract.

The kit owns only behavior that Ring, EZVIZ and Blink must implement
identically:

- fail-closed Supervisor token validation;
- persisted 64-hex workload-token creation and legacy import;
- restored-secret ownership and `0600` normalization;
- managed child signal/exit lifecycle;
- bounded health readiness waits;
- Supervisor app-info lookup and discovery publication.

Consumers vendor `dist/vistoda-app-bootstrap.sh`, record the exact canonical
commit and compare the vendored file byte-for-byte in CI. Floating branches and
runtime network downloads are not supported.

## Usage

Copy the library into the provider image and source it before provider-specific
setup:

```dockerfile
COPY packaging/home-assistant/vistoda-app-bootstrap.sh \
    /usr/local/lib/vistoda-app-bootstrap
```

```sh
. /usr/local/lib/vistoda-app-bootstrap

vistoda_require_supervisor_token
vistoda_prepare_data_dir bridge:bridge /data
vistoda_ensure_hex_token /data/api-token bridge:bridge ''
vistoda_start_child gosu bridge:bridge provider serve
vistoda_wait_for_health http://127.0.0.1:8765/healthz
jq -n '...' | vistoda_publish_discovery
vistoda_wait_child
```

See [the consumer contract](docs/consumer-contract.md) before adding behavior.

## Development

The library targets Debian `dash` and BusyBox `ash` and has no non-base shell
dependency beyond commands already present in the Vistoda app images.

```bash
sh -n dist/vistoda-app-bootstrap.sh tests/bootstrap-test.sh
tests/bootstrap-test.sh
```

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

Maintained by [Luigi Barretta](https://github.com/luigibarretta). You can
[support Vistoda on Ko-fi](https://ko-fi.com/luigibarretta). The shared
[disclaimer](https://github.com/luigibarretta/vistoda-home-assistant/blob/main/DISCLAIMER.md)
applies to Vistoda’s provider interoperability claims.
