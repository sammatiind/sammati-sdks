#!/usr/bin/env bash
#
# Publishes the Sammati Android SDK (io.sammati:sdk-android) into this repo's
# maven/ folder. Run on a machine WITH the Android toolchain (JDK 17 + Gradle —
# Android Studio provides both).
#
#   MONO=/path/to/synapsedatalabs ./scripts/publish-android.sh
#
# Note: packages/sdk-android is a bare library module with no standalone gradle
# project. It is built THROUGH apps/mobile-demo-android, whose settings.gradle.kts
# already includes :sdk-android by path. The MavenPublication is defined in
# packages/sdk-android/build.gradle.kts.
#
set -euo pipefail
MONO="${MONO:-/Users/vinod/myprojects/synapsedatalabs}"
DIST="$(cd "$(dirname "$0")/.." && pwd)"
PROJ="$MONO/apps/mobile-demo-android"

# Choose a gradle: the project wrapper if present, else a system gradle.
# (Java is only needed for the build path, not the copy-only fallback.)
if [ -x "$PROJ/gradlew" ]; then
  GRADLE="$PROJ/gradlew"
elif command -v gradle >/dev/null 2>&1; then
  GRADLE="gradle"
else
  cat <<'MSG'
ERROR: no Gradle found (apps/mobile-demo-android has no gradlew, and `gradle`
is not on PATH). Two ways forward:

  A) brew install gradle    # then re-run this script

  B) Android Studio (no CLI gradle needed):
     1. Open apps/mobile-demo-android in Android Studio, let it sync.
     2. Gradle panel → sdk-android → Tasks → publishing → publishToMavenLocal
        (or run `./gradlew :sdk-android:publishToMavenLocal` in AS's Terminal).
     3. Re-run THIS script — it will just copy the artifacts from ~/.m2.
MSG
  # If the artifacts are already in ~/.m2 (e.g. you did step B), still try to copy.
  [ -d "$HOME/.m2/repository/io/sammati" ] || exit 1
  echo "==> Found io.sammati in ~/.m2 — copying without re-publishing."
  mkdir -p "$DIST/maven"; rsync -a "$HOME/.m2/repository/io/sammati/" "$DIST/maven/io/sammati/"
  echo "==> Done. Maven tree under $DIST/maven/io/sammati/"; exit 0
fi

command -v java >/dev/null 2>&1 || {
  echo "ERROR: no JDK on PATH for the build. Use Android Studio's Terminal, or: brew install openjdk@17"
  exit 1
}
echo "==> Publishing :sdk-android to local Maven (~/.m2) via $PROJ"
( cd "$PROJ" && "$GRADLE" :sdk-android:publishToMavenLocal )

echo "==> Copying io/sammati artifacts into $DIST/maven"
mkdir -p "$DIST/maven"
rsync -a "$HOME/.m2/repository/io/sammati/" "$DIST/maven/io/sammati/"
echo "==> Done. Maven tree under $DIST/maven/io/sammati/"
