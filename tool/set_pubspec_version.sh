#!/usr/bin/env bash
# Aura — stamp the released semantic-release version into pubspec.yaml.
#
# Invoked by @semantic-release/exec during each release (prepareCmd) so the
# Flutter app version, the git tag, the GitHub Release and the CHANGELOG all
# carry the same number. pubspec.yaml is in @semantic-release/git's assets, so
# the change this makes is committed as part of the release commit.
#
#   tool/set_pubspec_version.sh 1.16.0   ->   version: 1.16.0+11600
#
# The +build code is derived from the version (major*10000 + minor*100 + patch)
# so it always increases with the version — what Android versionCode / iOS
# CFBundleVersion require for store uploads.
set -euo pipefail

version="${1:?usage: set_pubspec_version.sh <X.Y.Z>}"

# Drop any pre-release / build suffix before computing the numeric build code.
core="${version%%[-+]*}"
IFS='.' read -r major minor patch <<< "$core"
build=$(( 10#${major:-0} * 10000 + 10#${minor:-0} * 100 + 10#${patch:-0} ))

# Rewrite only the top-level version line.
sed -i -E "s/^version: .*/version: ${version}+${build}/" pubspec.yaml

echo "pubspec.yaml -> version: ${version}+${build}"
