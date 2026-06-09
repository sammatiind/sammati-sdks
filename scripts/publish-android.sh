#!/usr/bin/env bash
#
# Publishes the Sammati Android SDK (io.sammati:sdk-android) into this repo's
# maven/ folder. Run this on a machine WITH the Android toolchain (JDK 17 +
# the Android SDK) — e.g. anywhere Android Studio is installed.
#
#   MONO=/path/to/synapsedatalabs ./scripts/publish-android.sh
#
# PREREQUISITE (one-time, in the monorepo): packages/sdk-android must define a
# Maven publication. If `./gradlew publishToMavenLocal` produces nothing, add
# this to packages/sdk-android/build.gradle.kts and commit it via a PR:
#
#   afterEvaluate {
#     publishing {
#       publications {
#         create<MavenPublication>("release") {
#           from(components["release"])
#           groupId = "io.sammati"; artifactId = "sdk-android"; version = "0.1.0"
#         }
#       }
#     }
#   }
#
set -euo pipefail
MONO="${MONO:-/Users/vinod/myprojects/synapsedatalabs}"
DIST="$(cd "$(dirname "$0")/.." && pwd)"

command -v java >/dev/null || { echo "ERROR: no JDK on PATH. Install JDK 17 (e.g. brew install openjdk@17)."; exit 1; }

echo "==> Publishing sdk-android to local Maven (~/.m2)"
( cd "$MONO/packages/sdk-android" && ./gradlew :sdk-android:publishToMavenLocal )

echo "==> Copying io/sammati artifacts into $DIST/maven"
mkdir -p "$DIST/maven"
rsync -a "$HOME/.m2/repository/io/sammati/" "$DIST/maven/io/sammati/"
echo "==> Done. Maven tree under $DIST/maven/io/sammati/"
