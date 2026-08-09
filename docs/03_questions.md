# Critical questions and assumed defaults

This register prevents noncritical uncertainty from blocking implementation. Each entry states the adopted best-practice default. A later explicit decision may replace a default through an atomic documented change.

## Product and content

- **How much content is required first?** One polished unit of approximately five lessons; expand toward A1 after the complete loop is proven.
- **Who is the primary learner?** German-speaking families and beginners of all ages; friendly but not childish.
- **Who approves language content?** Automated validation plus human review by a competent Croatian/German speaker before content is marked release-ready.
- **How strict is grading?** Normalize Unicode NFC and whitespace only. Preserve spelling, German capitalization, Croatian diacritics, grammar, and explicit accepted variants.
- **How many new concepts?** Approximately two per early lesson, each with at least three meaningful tagged exposures.

## Platforms and devices

- **What Android range is supported?** API 24 minimum, API 36 target, ARM64 physical devices, ARM32 compatibility APK, and x64 emulator.
- **What if EMUI 12 reports an unexpected Android API?** Measure it with ADB. API 24 or newer remains supported; older is recorded as unsupported rather than weakening Flutter's supported floor.
- **Does Huawei require Google services?** No. Core functionality has no Google Play Services or network dependency.
- **How does desktop differ?** Only window hosting and keyboard focus differ; product behavior and phone navigation remain shared.

## Architecture

- **State management?** Riverpod with framework linting and injectable dependencies.
- **Navigation?** `go_router` with Home, Path, Review, and More routes.
- **Persistence?** Drift/SQLite in app-private storage, repositories at the boundary, and forward-only tested migrations.
- **Course representation?** Bundled JSON validated structurally and semantically, then parsed into typed immutable models.
- **Can curriculum authoring be separated from application development?** Yes.
  JSON remains the canonical app format; the auxiliary Flutter Content Studio
  lives at `tools/content_studio/` in this monorepo and exports deterministic
  validated snapshots. Do not add XML or unreviewed runtime downloads.
- **Spaced repetition?** FSRS behind a replaceable interface using default parameters and 90% desired retention until enough learner history exists for justified tuning.
- **Time handling?** Persist UTC; calculate learning days in Europe/Berlin.
- **How is pronunciation played before recordings exist?** Use replaceable,
  device-local system TTS with Croatian locale `hr-HR`; fail accessibly when a
  Croatian voice or Linux speech service is unavailable, and never add network
  or microphone permissions.

## Content Studio

- **Who uses and approves it initially?** One trusted native speaker may author,
  record, review, approve, and export; keep an audit record without implementing
  accounts or multi-user roles.
- **Where does it live?** As a separate Flutter desktop application under
  `tools/content_studio/`, sharing this repository's single SemVer source and
  quality rules without being compiled into the learner app.
- **How is it distributed?** As a portable Windows ZIP and checksummed Linux
  bundle. A path-filtered editor workflow checks both platforms on relevant
  pushes, while the root pipeline remains the mandatory integration gate.
- **What audio is recorded first?** Croatian vocabulary with one canonical
  speaker and an ordinary headset microphone. Preserve raw WAV takes, report
  measurable quality problems, and allow improved replacements under the same
  utterance IDs.
- **What can learners select?** Independently for Croatian and German:
  Automatic, native recording, device voice, or off. German uses device TTS
  until approved German recordings exist; the schema supports more speakers and
  styles later.
- **How is content delivered?** Approved content and converted audio are bundled
  with the app and validated by the root pipeline. Runtime downloads remain
  deferred.

## Design

- **How should CroLingo relate to other learning products?** Use only general
  learning-UX principles. Keep original colors, type, crow, path, components,
  wording, rewards, sounds, and illustrations.
- **Dark mode?** Superseded. The learner picks one of five appearances in settings: Adria-Blau (default), Neon-Violett, Mitternacht, Minze, and Hoher Kontrast. Colours live in an `AppPalette` theme extension, never as literals in a widget, and every reader-facing pair is asserted against WCAG contrast floors by a test. The high-contrast appearance is held to AAA because it exists for low vision.
- **Orientation?** Portrait-first on Android; Linux fixed portrait. Landscape is not an MVP acceptance requirement.

## Security and delivery

- **Does the text MVP need permissions?** No sensitive permissions and no release network permission.
- **Should local learning data be encrypted?** App sandboxing and device encryption are sufficient for non-sensitive learning progress; do not add key-management complexity until sensitive data exists.
- **Can an old phone be made risk-free?** No application can repair an unpatched OS. Minimize CroLingo's permissions, data, dependencies, exports, and network surface.
- **How are releases signed?** Since `0.0.43`, with one stable external Android
  key held in protected local storage and GitHub Actions secrets; keystores and
  passwords are never committed. The workflow verifies the public certificate
  fingerprint before publishing.
- **What about APKs from before stable signing?** Their ephemeral CI keys cannot
  be recovered, so users must uninstall one final time before installing the
  first stable-signed APK. Every later stable-signed upgrade retains Android's
  app-private progress database.

## Development process

- **What may be committed?** Only an atomic, conventional, version-bumped change that passes the complete local pipeline and leaves all targets buildable.
- **What if a guardrail appears overly strict?** Fix the code or document a narrow justified suppression. Do not globally weaken checks merely to pass.
- **Why is the coverage floor 98% and not higher?** A handful of lines cannot be reached from a headless test: the `audioplayers` player boundary needs the real platform plugin, and the speech adapter's platform detection depends on the host operating system. Chasing the remainder would mean mocking the framework rather than testing behaviour. 98% keeps roughly a dozen lines of headroom above the measured value, so an ordinary change does not turn the gate red for no reason.
- **What about warnings CroLingo cannot fix?** Warnings from the pinned Flutter toolchain, the Flutter Gradle template, or a bundled third-party plugin are named in the pipeline's closing warning review with the reason they are accepted. Do not silence them, do not patch dependency sources in this repository, and remove an entry once an upstream release retires it. Anything the review cannot account for is reported as unreviewed and needs a human decision.
- **What should be downloaded into the repository?** Only source-owned assets. SDKs, tools, caches, external repositories, generated reports, builds, and secrets belong in ignored locations.
- **What happens when tooling is missing?** `scripts/bootstrap.sh` installs pinned user-local tooling where practical and otherwise prints the exact system prerequisite. `localPipeline.sh` runs that script itself when a pinned tool is absent, so a fresh clone or a `git clean -xfd` repairs itself instead of requiring a remembered manual step. If bootstrap cannot complete the environment, the pipeline stops before the first real gate rather than reporting a cascade of missing-command failures, and it never silently skips a mandatory gate.
