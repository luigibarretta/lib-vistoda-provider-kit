# Contributing

Read the Vistoda family [contribution guide](https://github.com/luigibarretta/vistoda-home-assistant/blob/main/CONTRIBUTING.md)
and the local [consumer contract](docs/consumer-contract.md) first.

This repository owns only the shared Supervisor bootstrap and discovery
helpers. Provider options, process commands, ports and credentials stay in each
provider repository.

Run `sh -n dist/vistoda-app-bootstrap.sh tests/bootstrap-test.sh` and
`tests/bootstrap-test.sh`. Consumers vendor an exact commit and verify the
distributed file byte-for-byte in CI.
