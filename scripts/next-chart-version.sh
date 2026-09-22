#!/usr/bin/env bash
# Given the app version the chart currently ships, the app version being released, and the
# chart's current version, print "<release-type> <new-chart-version>".
#
# The chart bump mirrors the app bump -- a major app release majors the chart, a minor minors it,
# a patch patches it -- so the chart version signals how significant the release it ships is.
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <current-app-version> <new-app-version> <current-chart-version>" >&2
  exit 2
fi

SEMVER_VERSION="7.8.5"

# npm's own semver package, rather than hand-rolled version arithmetic. Installed into a
# version-keyed cache dir so this behaves identically as an unprivileged devcontainer user and
# as root in CI, with no global-install step needed in either.
LIB_DIR="${TMPDIR:-/tmp}/next-chart-version-semver-${SEMVER_VERSION}"
if [ ! -d "${LIB_DIR}/node_modules/semver" ]; then
  mkdir -p "$LIB_DIR"
  npm install --silent --no-save --no-audit --no-fund \
    --prefix "$LIB_DIR" "semver@${SEMVER_VERSION}" >&2
fi

NODE_PATH="${LIB_DIR}/node_modules" node -e '
  const semver = require("semver");
  const [prev, next, chart] = process.argv.slice(1);
  for (const [label, v] of [["current app", prev], ["new app", next], ["chart", chart]]) {
    if (!semver.valid(v)) {
      console.error(`${label} version is not valid semver: ${v}`);
      process.exit(1);
    }
  }
  // A replayed dispatch -- someone re-running an old tangle release workflow -- would otherwise
  // open a PR that bumps the chart with no app change behind it.
  if (!semver.gt(next, prev)) {
    console.error(`release ${next} is not newer than current appVersion ${prev}`);
    process.exit(1);
  }
  const level = {
    major: "major", premajor: "major",
    minor: "minor", preminor: "minor",
    patch: "patch", prepatch: "patch", prerelease: "patch",
  }[semver.diff(prev, next)];
  console.log(`${level} ${semver.inc(chart, level)}`);
' "$1" "$2" "$3"
