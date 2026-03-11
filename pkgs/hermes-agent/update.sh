#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git nix common-updater-scripts
# shellcheck shell=bash

set -euo pipefail

url="$(nix-instantiate --eval -E "with import ./. {}; $UPDATE_NIX_ATTR_PATH.src.gitRepoUrl" | tr -d '"')"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

git clone --depth=1 "$url" "$tmpdir"

pushd "$tmpdir" >/dev/null
commit_date="$(git show -s --pretty='format:%cs')"
commit_sha="$(git show -s --pretty='format:%H')"
last_tag=""
depth=100
while ((depth < 10000)); do
  last_tag="$(git describe --tags --abbrev=0 --match '*' 2>/dev/null || true)"
  if [[ -n $last_tag ]]; then
    break
  fi
  git fetch --depth="$depth" --tags
  depth=$((depth * 2))
done
if [[ -z $last_tag ]]; then
  git fetch --tags
  last_tag="$(git describe --tags --abbrev=0 --match '*' 2>/dev/null || echo 0)"
fi
[[ $last_tag =~ ^[[:digit:]] ]] || last_tag=0
popd >/dev/null

update-source-version \
  "$UPDATE_NIX_ATTR_PATH" \
  "$last_tag-unstable-$commit_date" \
  --rev="$commit_sha" \
  --ignore-same-version
