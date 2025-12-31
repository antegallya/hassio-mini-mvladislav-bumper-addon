#!/usr/bin/env bash
set -e

# Load add-on config options as environment variables
if [ -f /data/options.json ]; then
  eval "$(
    python3 - <<'EOF'
import json, shlex
with open("/data/options.json") as f:
    data = json.load(f)
for k, v in data.items():
    if isinstance(v, (dict, list)):
        v = json.dumps(v)
    print(f"export {k.upper()}={shlex.quote(str(v))}")
EOF
  )"
fi

exec "$@"