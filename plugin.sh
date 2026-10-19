#!/bin/sh
here="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
sys="$(uname -s)"
case "$sys" in
MINGW* | MSYS* | CYGWIN*) rel="x86_64-pc-windows-msvc/gray-lens.exe" ;;
Darwin*)
    case "$(uname -m)" in
    arm64) rel="aarch64-apple-darwin/gray-lens" ;;
    *) rel="x86_64-apple-darwin/gray-lens" ;;
    esac ;;
*)
    case "$(uname -m)" in
    aarch64 | arm64) rel="aarch64-unknown-linux-musl/gray-lens" ;;
    *) rel="x86_64-unknown-linux-musl/gray-lens" ;;
    esac ;;
esac
if [ -x "$here/$rel" ]; then exec "$here/$rel" "$@"; fi
for cand in "$here/target/release/gray-lens.exe" "$here/target/release/gray-lens" "$here/target/debug/gray-lens.exe" "$here/target/debug/gray-lens"; do
    if [ -x "$cand" ]; then exec "$cand" "$@"; fi
done
echo "gray-lens binary not found in $here" >&2
exit 1
