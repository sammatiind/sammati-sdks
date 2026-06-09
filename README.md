# Sammati SDKs — public distribution

Built, installable artifacts for the Sammati mobile & server SDKs. **Source is
not here** — it lives in the private monorepo and is published into this repo as
artifacts only. Customers consume the SDKs from this repo; they never get access
to Sammati source.

| SDK | Coordinate | Status here |
|---|---|---|
| `@sammati/react-native` | npm tarball | ✅ `npm/sammati-react-native-0.1.0.tgz` |
| `@sammati/capacitor` | npm tarball | ✅ `npm/sammati-capacitor-0.1.0.tgz` |
| `@sammati/sdk-node` | npm tarball | ⚠️ needs a `tsc` build first (current tarball ships no source) |
| iOS `Sammati` | CocoaPods | ✅ `cocoapods/Sammati.podspec` + source zip |
| Android `io.sammati:sdk-android` | Maven | ⛔ run `scripts/publish-android.sh` on a machine with a JDK |

## How customers install

### React Native / Capacitor / Node (npm)

Install straight from the tarball URL — no registry, no token:

```bash
npm install https://raw.githubusercontent.com/sammatiind/sammati-sdks/main/npm/sammati-react-native-0.1.0.tgz
# or @sammati/capacitor, @sammati/sdk-node tarballs
```

### iOS (CocoaPods) — bare native apps

```ruby
# Podfile
pod 'Sammati', :podspec => 'https://raw.githubusercontent.com/sammatiind/sammati-sdks/main/cocoapods/Sammati.podspec'
```

> **RN/Capacitor on iOS:** their bridge declares `s.dependency 'Sammati'`, which
> CocoaPods resolves by *name* from a spec source — a direct `:podspec =>` URL
> can't satisfy a transitive dependency. This needs a CocoaPods **spec repo**
> (root-layout) or a Podfile path override. Tracked as an open item — see
> "Known gaps" below.

### Android (Maven)

Once `maven/` is populated (via `scripts/publish-android.sh`) and served over
HTTPS (GitHub Pages or raw.githubusercontent):

```kotlin
// settings.gradle.kts or build.gradle.kts repositories {}
maven { url = uri("https://raw.githubusercontent.com/sammatiind/sammati-sdks/main/maven") }
// app dependencies {}
implementation("io.sammati:sdk-android:0.1.0")
```

## Rebuilding the artifacts

```bash
MONO=/path/to/synapsedatalabs ./scripts/build-artifacts.sh   # JS + iOS (no JDK needed)
MONO=/path/to/synapsedatalabs ./scripts/publish-android.sh   # Android (needs JDK 17)
```

## Known gaps (before this is fully GA across all customers)

1. **`sdk-node`** ships no source — add a `tsc` build (`dist/`) and point
   `main`/`types` at it in the monorepo, then re-pack.
2. **Android publication** isn't wired in `packages/sdk-android/build.gradle.kts`
   — add the `MavenPublication` block (see `scripts/publish-android.sh` header)
   and run with a JDK.
3. **CocoaPods transitive `Sammati`** for RN/Capacitor needs a spec-repo or
   path override — decide the mechanism.
4. **npm tarball URLs pin exact versions** (no `^` ranges). Acceptable for
   controlled distribution; switch to the npm registry if semver ranges matter.
5. Consider **GitHub Pages** for `maven/` (raw.githubusercontent is rate-limited
   and uncached) and **GitHub Releases** for the tarballs/zip (keeps the repo
   small) once the flow is proven.
