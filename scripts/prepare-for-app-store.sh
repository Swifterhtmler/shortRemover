#!/bin/bash
# ITMS-91109: Remove com.apple.quarantine from resources before archiving.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

for dir in \
  "$ROOT/ShortRemover/Resources" \
  "$ROOT/ShortRemover/Assets.xcassets" \
  "$ROOT/ShortRemover Extension/Resources"
do
  if [ -d "$dir" ]; then
    echo "Clearing extended attributes in: $dir"
    xattr -cr "$dir"
  fi
done

echo "Done. Archive in Xcode (Product → Archive), then upload."
