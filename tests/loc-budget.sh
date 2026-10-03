#!/bin/sh
# Enforce the Vistoda 250-line budget on every maintained file.
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
maximum=250
failed=0

for file in $(find "$root" -type f -not -path '*/.git/*' \
  \( -name '*.sh' -o -name '*.md' -o -name '*.yml' -o -name '*.yaml' \) | sort); do
  lines=$(wc -l <"$file")
  if [ "$lines" -gt "$maximum" ]; then
    echo "${file#"$root"/}: $lines > $maximum" >&2
    failed=1
  fi
done

exit "$failed"
