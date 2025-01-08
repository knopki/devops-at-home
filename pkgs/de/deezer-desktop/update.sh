#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix common-updater-scripts gnugrep gnused
# shellcheck shell=bash

set -euo pipefail

SYSTEMS=$(nix-instantiate --eval -E "with import ./. {}; builtins.concatStringsSep \" \" $UPDATE_NIX_PNAME.meta.platforms" | tr -d '"')
GH_PREFIX="https://github.com/aunetx/deezer-linux"

LATEST_TAG=$(list-git-tags --url="$GH_PREFIX" | grep -E '^v[0-9\.-]+$' | sort --reverse --version-sort | head -n 1)
LATEST_FULL_VERSION=$(echo "$LATEST_TAG" | cut -b 2-)
LATEST_SHORT_VERSION=$(echo "$LATEST_FULL_VERSION" | cut -d - -f 1)

if [[ $LATEST_FULL_VERSION == "$UPDATE_NIX_OLD_VERSION" ]]; then
  echo "already latest version $LATEST_FULL_VERSION"
  exit 0
fi
echo "updating $UPDATE_NIX_OLD_VERSION -> $LATEST_FULL_VERSION"

for system in $SYSTEMS; do
  if [[ $system == "x86_64-linux" ]]; then
    SUFFIX="$LATEST_SHORT_VERSION-x86_64.AppImage"
  fi
  if [[ $system == "aarch64-linux" ]]; then
    SUFFIX="$LATEST_SHORT_VERSION-arm64.AppImage"
  fi
  url="$GH_PREFIX/releases/download/$LATEST_TAG/deezer-desktop-$SUFFIX"
  prefetch=$(nix-prefetch-url "$url")
  hash=$(nix hash convert --hash-algo sha256 --to sri "$prefetch")
  update-source-version "$UPDATE_NIX_PNAME" "$LATEST_FULL_VERSION" "$hash" "$url" \
    --system="$system" --ignore-same-version
done
