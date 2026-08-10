# CroLingo pipeline facts for a LinkedIn post

Snapshot updated on 10 August 2026 at CroLingo `0.0.69+70`. Counts that naturally
grow with the project are dated rather than presented as permanent claims.

## Project snapshot

- **129 automated tests pass.** They cover domain rules, persistence and
  migrations, content parsing, platform adapters, widgets, navigation, and
  accessibility behavior. A broad suite makes regressions visible close to the
  change that introduced them instead of during a manual release test.
- **98.23% authored Dart line coverage: 1,497 of 1,524 lines.** The mandatory
  floor is 98%; the pipeline fails below it. Coverage is not treated as proof
  of correctness, but as evidence that new behavior has executable tests and
  that untested areas stay visible.
- **30 unit and widget test source files plus a real-target integration suite.**
  Platform channels for audio, speech, and the on-disk database are tested on a
  Linux desktop or connected Android device because hosted runners do not have
  representative displays and audio hardware. Automation is explicit about
  what it can and cannot verify.
- **21 named pipeline stages form one commit gate.** A concise final table says
  which stage passed, failed, or was deliberately skipped. Failed-run logs are
  retained, so a red result is diagnostic rather than merely negative.
- **Two deployment targets are built from one Flutter codebase:** Android and
  native Linux desktop. Building both on every complete run catches accidental
  use of a package or API that supports only one platform.

## The same gate locally and remotely

- **One script is the source of truth:** `./localPipeline.sh --noRun` runs on a
  developer machine and inside GitHub Actions. CI does not maintain a weaker,
  separately reimplemented checklist, reducing “works locally” differences.
- **A Git pre-commit hook runs the complete gate.** A change is checked before
  it becomes local history, which shortens the feedback loop and keeps broken
  commits out of the normal workflow.
- **The pipeline is self-bootstrapping.** If pinned user-local tools are absent,
  it runs `scripts/bootstrap.sh`; if system prerequisites are missing, it stops
  early with a useful explanation instead of producing a cascade of misleading
  command-not-found errors.
- **An exclusive worktree lock prevents two pipelines from corrupting shared
  build state.** A concurrent run fails immediately and explains how to use a
  separate Git worktree. Automation also has to be safe under concurrency.
- **Exit codes, `pipefail`, and recorded logs determine success.** The scripts
  do not infer success from output text or a trailing command in a pipe. This
  avoids a subtle class of false-green pipelines.
- **Expensive builds run only after the quality gates pass.** A formatting,
  analysis, test, content, or security failure skips clean packaging, saving
  developer time and hosted-runner minutes.
- **Linux launch is an optional local smoke check.** Omitting `--noRun` starts
  the built application briefly after all other checks pass. CI stays headless,
  while a developer can include a real executable launch in the same command.

## Static and structural checks

- **Formatting is enforced, not suggested.** `dart format` fails on drift in
  application, test, integration, and tool code, keeping reviews focused on
  behavior rather than whitespace.
- **Strict Dart analysis treats informational diagnostics as failures.** The
  project uses Very Good Analysis plus strict casts, strict inference, strict
  raw types, discarded-future checks, and unawaited-future checks. These catch
  type and asynchronous errors before they become runtime defects.
- **Android Lint checks the native Android layer.** Flutter analysis alone
  cannot validate manifests, resources, Gradle integration, or Android-specific
  correctness.
- **ShellCheck validates every repository-owned shell script at style
  severity.** Build and release scripts are production code: a quoting or error
  propagation bug there can invalidate every later check.
- **Actionlint and Zizmor inspect GitHub workflows.** Syntax, expression, and
  workflow-security mistakes are caught before the remote job is trusted.
- **Markdownlint checks project documentation.** Build, release, authoring, and
  operational instructions are part of the product and must remain readable.
- **Generated Drift sources must be reproducible.** The pipeline regenerates
  them and fails if Git differs, preventing stale database code from compiling
  against a newer schema definition.
- **Repository policy rejects common secret and machine-local filenames.** It
  also requires critical project, release, Gradle-wrapper, and lock files and
  checks whitespace errors across the working tree.
- **Every commit follows a conventional subject and advances one SemVer source.**
  The hooks enforce the subject form, while the pipeline validates monotonically
  increasing `pubspec.yaml` version and Android build number. Releases therefore
  have an auditable identity without version copies drifting apart.

## Dependency and supply-chain controls

- **Flutter is pinned to 3.44.9 and Java to 21.** Android platform 36, build
  tools 36.0.0, NDK 28.2.13676358, and Gradle 9.1.0 are also explicit. A stable,
  repeatable toolchain prevents an unannounced upstream update from changing a
  supposedly identical build.
- **Downloaded tooling is versioned and SHA-256 verified.** Current pins include
  Actionlint 1.7.12, Gitleaks 8.30.1, OSV-Scanner 2.5.0, Zizmor 1.29.0,
  ShellCheck 0.11.0, markdownlint-cli2 0.22.0, Syft 1.50.0, CycloneDX CLI
  0.33.1, CycloneDX Gradle Plugin 3.3.0, and SPDX tools-python 0.8.5.
  Reproducibility includes the
  tools that judge the code, not only the application dependencies.
- **The Gradle wrapper JAR and distribution URL are verified.** The wrapper JAR
  has a pinned SHA-256 digest and must still point to Gradle 9.1.0. This detects
  accidental or malicious replacement of an executable build component.
- **Dart dependencies use the committed lockfile.** `flutter pub get
  --enforce-lockfile` must succeed and may not modify `pubspec.lock`, so local,
  CI, and release builds resolve the same dependency graph.
- **GitHub Actions are pinned to full commit SHAs.** Readable version comments
  remain beside the hashes. Tags are convenient but mutable; immutable action
  revisions reduce supply-chain ambiguity.
- **Dependabot checks two ecosystems every week:** Dart/Flutter packages and
  GitHub Actions. Automation opens reviewable update proposals without silently
  changing production inputs.
- **A five-minute weekly upstream-watch workflow tracks a known Flutter
  analyzer blocker.** Its unusual red result means the blocker moved and a
  planned upgrade became possible. This replaces a maintenance reminder that a
  person would eventually forget.
- **Known upstream warnings are classified and counted.** New warnings remain
  visible for human judgment instead of being buried in accepted third-party
  noise or globally suppressed.

## Content, security, and privacy gates

- **Course JSON receives structural and semantic validation.** The validator
  checks stable IDs, references, exercise/type combinations, accepted answers,
  concept exposure, mastery dimensions, and both German-to-Croatian and
  Croatian-to-German recall. Content is executable product behavior even when
  it is not Dart code.
- **Gitleaks scans the Git history, not only the current files.** Removing a
  secret in a later commit does not remove it from history, so history-aware
  scanning matters.
- **OSV-Scanner checks the resolved dependency tree for known
  vulnerabilities.** This complements static analysis: correct application
  code can still inherit a vulnerable component.
- **Two validated SBOM formats are generated on every complete run.** One
  resolved inventory combines locked Dart/Pub packages with the Android
  release classpath, then produces CycloneDX 1.7 and SPDX 2.3 JSON. Official
  validators fail the gate on malformed documents, and deliberately corrupted
  fixtures prove the rejection path.
- **Release APK permissions are inspected after compilation.** The pipeline
  rejects Internet, microphone, camera, location, contacts, and broad external
  storage permissions. Verifying the final binary catches permissions added by
  manifests or dependencies rather than trusting source intent.
- **GitHub quality jobs have read-only repository permission.** Checkout also
  disables credential persistence. The release job receives write permission
  only because its final step must create the tag and GitHub Release.
- **Signing material exists only as protected GitHub secrets.** The release
  workflow writes the temporary keystore with restrictive permissions and
  never uploads or commits it.
- **The signed ARM64 APK certificate is compared with a committed public
  SHA-256 fingerprint.** This protects upgrade continuity: an APK signed by an
  unexpected identity cannot become an official CroLingo release.

## Clean builds and artifacts

- **Every complete run starts clean before packaging.** It rebuilds the Linux
  release bundle, Android debug APK, universal release APK, three split release
  APKs, and Android App Bundle. Clean builds expose missing generated files and
  dependencies hidden by a developer's cache.
- **Artifacts are inspected for existence, size, identity, SDK levels, ABIs,
  and prohibited permissions.** A successful compiler exit is not enough; the
  pipeline verifies that the expected distributable was actually produced.
- **GitHub's quality workflow uploads development artifacts only after
  success.** It publishes the Linux bundle, APKs, AAB, and diagnostic reports,
  making remote checks reproducible and their outputs available without a
  local Android/Flutter setup.
- **Constrained GitHub runners use a low-disk build mode.** Disposable Android
  intermediates are reclaimed before the AAB build while already verified
  outputs are preserved. The workflow also safely removes unrelated preloaded
  SDKs only when it detects GitHub Actions.

## Release automation

- **Release is manual and fail-closed.** A maintainer chooses the exact commit;
  the workflow then repeats the complete pipeline. No tag or public release is
  created if any prerequisite fails.
- **The release workflow validates the version and rejects an existing tag.**
  A successful run creates exactly `vX.Y.Z` from the single `pubspec.yaml`
  version and targets the selected, verified commit.
- **Six installable/build deliverables and two SBOMs are published:** universal APK, ARM64 APK,
  ARM32 APK, x86-64 APK, Android App Bundle, and deterministic Linux x64
  archive, plus CycloneDX and SPDX JSON. `SHA256SUMS.txt` covers every asset.
- **The Linux archive is reproducible at the packaging layer.** File order,
  timestamp, owner, group, and gzip timestamp are normalized using the commit
  time, reducing meaningless binary differences.
- **GitHub Releases provides one discoverable distribution point.** The action
  generates release notes, marks the verified release as latest, attaches the
  artifacts and checksums, and lets an Android tester download the correct APK
  directly from the phone.
- **Stable signing enables in-place Android upgrades and preserves app-private
  progress.** Automating certificate verification helps prevent a release that
  Android would reject as an update—or that would tempt users to uninstall and
  lose local data.

## Why the automation matters

- **It makes the safe path the easiest path.** One local command performs the
  same checks that GitHub and the release use; contributors do not need to
  remember a long checklist.
- **It moves regression detection left.** Formatting, type, behavior,
  migration, content, permission, security, and packaging regressions are found
  before publication, when the responsible change is still small and clear.
- **It turns expectations into executable policy.** “No network permission,”
  “98% coverage,” “one version,” and “stable signing identity” are verified
  properties rather than documentation that can silently become outdated.
- **It separates confidence from one machine.** A clean Ubuntu GitHub runner
  proves the build does not depend on an untracked local file, warm cache, IDE
  setting, or developer-specific SDK state.
- **It produces evidence.** Summaries, logs, coverage data, dependency scans,
  APK metadata, checksums, signed packages, and immutable workflow revisions
  make a release explainable after the fact.
- **It does not pretend to replace judgment.** Native-speaker review, physical
  device behavior, audio quality, accessibility feel, and expected upstream
  warnings retain explicit human gates. Strong automation identifies the
  smaller set of decisions where human attention is actually valuable.

## Compact post-ready figures

- 129 passing automated tests.
- 98.23% line coverage: 1,497/1,524 authored Dart lines; 98% enforced floor.
- 20 named local pipeline stages.
- 2 supported build targets: Android and Linux.
- 2 weekly Dependabot ecosystems: Dart/Flutter and GitHub Actions.
- 7 pinned auxiliary quality tools, including the Flutter SDK itself.
- 3 security layers: history secret scan, dependency vulnerability scan, and
  final-APK permission inspection.
- 6 release packages plus one SHA-256 checksum manifest.
- 1 script shared by developer machines, GitHub quality checks, and releases.
- 0 tags or public releases when the complete gate fails.
