#!/bin/sh
# Verify the actually published jsc release using the public pkg surface.
set -eu

[ "$#" -eq 1 ] || { printf '%s\n' 'usage: sh tests/install-live.sh <m-checkout>' >&2; exit 2; }
source_root=$1
work=$(mktemp -d "${TMPDIR:-/tmp}/jsc-install-live.XXXXXXXX") || exit 3
trap 'command -p -- rm -rf -- "$work"' 0
trap 'exit 130' HUP INT TERM

command -p -- mkdir -- "$work/runtime"
command -p -- cp -R -- "$source_root/." "$work/runtime/"
root=$work/runtime
command -p -- rm -rf -- "$root/.git"
[ -x "$root/m" ] || exit 4
[ ! -e "$root/bin/sys/jsc" ] || exit 5
[ ! -e "$root/lib/sys/js/jsc.lib.js" ] || exit 6

"$root/m" osarch update
"$root/m" state-path user sys jsc cache > "$work/state.txt"
[ -s "$work/state.txt" ] || exit 7
[ ! -e "$root/pkg/jsc@v0.1.0" ] || exit 8

# Use the current authoritative catalog and public repository adapter.
"$root/m" pkg install jsc@v0.1.0 || exit 9
[ -x "$root/pkg/jsc@v0.1.0/root/bin/jsc" ] || exit 10
[ -f "$root/pkg/jsc@v0.1.0/root/lib/jsc.lib.js" ] || exit 11
[ -f "$root/pkg/jsc@v0.1.0/root/res/manual/jsc" ] || exit 12
[ -f "$root/pkg/jsc@v0.1.0/root/res/manual/jsc.lib.js" ] || exit 13
[ ! -e "$root/lib/sys/js/jsc.lib.js" ] || exit 14
[ -L "$root/bin/ext/jsc" ] || exit 15
[ "$("$root/m" pkg default jsc)" = "jsc@v0.1.0" ] || exit 16

node_concrete=$("$root/m" pkg default nodejs)
case "$node_concrete" in nodejs@v26*) : ;; *) exit 17 ;; esac
[ -d "$root/pkg/$node_concrete/root" ] || exit 18

command -p -- mkdir -- "$work/project"
printf '%s\n' 'const answer = 42;' > "$work/project/value.js"
cat > "$work/project/modules-js.json" <<'EOF_JS'
{"modules":[{"name":"demo","modules":[{"file":"value.js","exports":"answer"}]}]}
EOF_JS
"$root/m" jsc "$work/project/modules-js.json" "$work/project/result.js" || exit 19
[ -s "$work/project/result.js" ] || exit 20
[ -s "$work/project/result.js.gz" ] || [ -s "$work/project/result.min.js.gz" ] || exit 21

EXPECTED_NODE_ROOT="$root/pkg/$node_concrete/root"
export EXPECTED_NODE_ROOT
"$root/m" node -e '
const fs = require("node:fs"), path = require("node:path");
const actual = fs.realpathSync(process.execPath);
const expected = fs.realpathSync(process.env.EXPECTED_NODE_ROOT);
if (!actual.startsWith(expected + path.sep)) process.exit(51);
const output = require(process.argv[1]);
if (output.answer !== 42) process.exit(52);
' "$work/project/result.js" || exit 22

printf '.demo { color: red; }\n' > "$work/project/style.css"
printf '%s\n' '{"modules":[{"file":"style.css"}]}' > "$work/project/modules-css.json"
"$root/m" jsc "$work/project/modules-css.json" > "$work/project/stdout.css" || exit 23
[ -s "$work/project/stdout.css" ] || exit 24
"$root/m" jsc "$work/project/modules-css.json" "$work/project/result.css" || exit 25
[ -s "$work/project/result.css.gz" ] || [ -s "$work/project/result.min.css.gz" ] || exit 26

printf '%s\n' '{"modules":[{"file":"../escape.js"}]}' > "$work/project/invalid.json"
if "$root/m" jsc "$work/project/invalid.json" > "$work/invalid-output" 2> "$work/invalid-errors"
then
  printf '%s\n' 'FAIL: jsc accepted forbidden source path' >&2
  exit 27
fi
[ -s "$work/invalid-errors" ] || exit 28

printf '%s\n' 'PASS: public pkg install jsc@v0.1.0, managed Node, real JS/CSS compilation'
