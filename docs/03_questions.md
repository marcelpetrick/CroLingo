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
  JSON remains the canonical app format; a separate repository or editor may
  export deterministic validated snapshots. Do not add XML or unreviewed
  runtime downloads.
- **Spaced repetition?** FSRS behind a replaceable interface using default parameters and 90% desired retention until enough learner history exists for justified tuning.
- **Time handling?** Persist UTC; calculate learning days in Europe/Berlin.
- **How is pronunciation played before recordings exist?** Use replaceable,
  device-local system TTS with Croatian locale `hr-HR`; fail accessibly when a
  Croatian voice or Linux speech service is unavailable, and never add network
  or microphone permissions.

## Design

- **How should CroLingo relate to other learning products?** Use only general
  learning-UX principles. Keep original colors, type, crow, path, components,
  wording, rewards, sounds, and illustrations.
- **Dark mode?** Token-ready but deferred until the light theme is complete and accessible.
- **Orientation?** Portrait-first on Android; Linux fixed portrait. Landscape is not an MVP acceptance requirement.

## Security and delivery

- **Does the text MVP need permissions?** No sensitive permissions and no release network permission.
- **Should local learning data be encrypted?** App sandboxing and device encryption are sufficient for non-sensitive learning progress; do not add key-management complexity until sensitive data exists.
- **Can an old phone be made risk-free?** No application can repair an unpatched OS. Minimize CroLingo's permissions, data, dependencies, exports, and network surface.
- **How are releases signed?** With external local/CI secrets; never with committed keystores or passwords.
- **What is distributed before signing exists?** Manually triggered GitHub
  prereleases may distribute verified development-signed APKs, an AAB, Linux
  bundle, and checksums. They are explicitly non-production; production
  publication waits for signing material.

## Development process

- **What may be committed?** Only an atomic, conventional, version-bumped change that passes the complete local pipeline and leaves all targets buildable.
- **What if a guardrail appears overly strict?** Fix the code or document a narrow justified suppression. Do not globally weaken checks merely to pass.
- **What should be downloaded into the repository?** Only source-owned assets. SDKs, tools, caches, external repositories, generated reports, builds, and secrets belong in ignored locations.
- **What happens when tooling is missing?** `scripts/bootstrap.sh` installs pinned user-local tooling where practical and otherwise prints the exact system prerequisite; `localPipeline.sh` fails clearly rather than silently skipping a mandatory gate.
