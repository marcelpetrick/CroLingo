# CroLingo implementation plan

Execution status and the prioritized next steps are maintained in
`02_roadmap.md`.

## Outcome

CroLingo will be a polished, offline-first Flutter application that teaches Croatian to German-speaking families. Android is the distribution target; Linux is a native development and desktop companion using the same phone interface.

The first usable milestone is one human-reviewed starter unit of about five lessons. It implements vocabulary matching, typed translation in both directions, fill-in-the-blank, sentence construction, strict grading, unlimited retries, XP, sequential progression, crowns, streaks, local statistics, concept mastery, and spaced review.

The text-learning loop is proven. Phase two adds optional system-provided
Croatian playback without microphone access or network services. Native-speaker
recordings, listening exercises, learner recordings, sample comparison, and
pronunciation grading remain deferred.

## Fixed decisions

- Name: CroLingo
- Dart package: `crolingo`
- Android application ID: `it.marcelpetrick.crolingo`
- Platforms: Android API 24–36 and Linux x64
- Reference devices: Huawei Mate 20 HMA-L29/EMUI 12 and Xiaomi/Poco/Android 16
- Audience: family/all ages
- License: GPL-3.0
- Storage: offline, app-private SQLite
- Course content: bundled, validated JSON
- Linux viewport: centered, fixed, non-resizable 412×915 logical pixels
- Android layout: responsive phone portrait layout with safe areas and font scaling
- Version source: only `pubspec.yaml`, starting at `0.0.0+1`, changed in every commit
- Git: atomic conventional local commits; no unsolicited pushes. The manual
  development-release workflow may tag a commit only after its full gate passes.

## Delivery loops

Current status: loops 1 through 5 are complete, including durable SQLite
attempts/checkpoints, sequential unlocking, and all text exercise families.
Streak statistics, recent-mistake and recently-learned replay, deterministic
FSRS due dates, and fine-grained concept mastery from loop 6 are implemented. Automated
320-pixel/200%-text accessibility checks are active; extended
assistive-technology review and physical-device checks remain. The complete
local profile reports start date, XP, lessons, vocabulary, study days, and
current/longest streaks.

Phase two is active. Both translation directions are present for every existing
concept. Accessible Android/Linux playback controls are implemented; path
rendering and sequential unlocking now derive from ordered course data across
unit boundaries. The dashboard starts or resumes the actual first incomplete
lesson. A second five-lesson unit adds farewells, courtesy, first meetings, and
origin phrases; its automated content gates pass and human Croatian/German
review remains required. Expansion toward A1 continues through small
human-reviewable everyday units.

### 1. Foundation and guardrails

- Install and pin Flutter 3.44.7 with Java 21 and Android API 36.
- Bootstrap only Android and Linux.
- Add self-bootstrap scripts that reuse compatible system SDKs or install pinned tooling into ignored `.tooling/`.
- Add a complete local pipeline, tracked Git hooks, strict analyzer configuration, framework-specific linting, coverage gates, content validation, security scans, Android lint, and clean Android/Linux builds.
- Run the same pipeline in GitHub Actions for pushes, pull requests, and manual checks.
- Preserve bootstrap diagnostics as workflow artifacts even when setup fails,
  and keep all workflow actions pinned to Node 24-compatible revisions.
- Use the pipeline's low-disk build mode on hosted runners so verified APK and
  Linux outputs survive while disposable intermediates are reclaimed before
  the AAB build.

### 2. Product and visual foundation

- Replace the generated sample with a feature-oriented architecture and application shell.
- Implement the Croatian design system: Adriatic blue primary, restrained Croatian red/white checker accents, bright surfaces, accessible state colors, rounded pebble-like controls, Fredoka display type, and Atkinson Hyperlegible body type.
- Use an original geometric crow mascot and Adriatic-journey path; do not copy Duolingo assets, green, fonts, exact screens, terminology, rewards, or mascot treatment.
- Implement Home, Path, Review, and More navigation. More contains Vocabulary, Grammar, Profile, and Settings.

### 3. Content and persistence

- Define typed course, unit, lesson, task, vocabulary, grammar, answer, and learning-concept models.
- Validate JSON structure and semantics: unique IDs, references, order, translations, accepted answers, known distractors, introductions, and at least three meaningful exposures for each new concept.
- Use Drift/SQLite for profile, settings, progress, attempts, mastery, review logs, study days, and crowns, with tested forward migrations.
- Create one reviewed five-lesson starter unit covering greetings and self-introduction, with no more than approximately two new concepts per early lesson.

### 4. Learning engine

- Persist every attempt and resume interrupted lessons.
- Require eventual correctness with unlimited retries.
- Show the submitted answer, an accepted correction, and a concise explanation.
- Unlock the next lesson only after completion; keep completed lessons replayable.
- Award `max(2, 10 - 2 × prior incorrect attempts)` XP per task plus 10 XP for lesson completion.
- Persist a gold crown when a unit is completed.

### 5. Exercises

- Vocabulary pair matching with independently shuffled columns.
- German-to-Croatian and Croatian-to-German typed translation.
- Fill-in-the-blank tasks for vocabulary and grammar.
- Sentence construction from shuffled word or phrase tiles.
- Randomization must be injectable, deterministic in tests, and unable to introduce unseen material or impossible tasks.

### 6. Mastery, review, streaks, and statistics

- Track recognition, both recall directions, sentence production, and grammar application.
- Put FSRS behind a replaceable `ReviewScheduler`, initially using default parameters and 90% desired retention.
- Map first-attempt correct to Good, one prior error to Hard, and two or more prior errors to Again.
- Provide Due/Recommended, Recent Mistakes, and Recently Learned review modes.
- Use UTC timestamps and Europe/Berlin calendar dates for current/longest streaks.
- Show start date, XP, completed lessons, streaks, and learned vocabulary locally.

### 7. Hardening and delivery

- Verify keyboard, screen-reader, contrast, non-color feedback, 200% text scaling, and reduced motion.
- Test API 24, Android 14, Android 16, the two physical phones, and Linux.
- Build universal and split APKs, an Android App Bundle, and a Linux release bundle.
- Use a manual signing workflow with secrets outside Git. Quality workflows
  never publish or tag; the explicitly dispatched development-release workflow
  publishes clearly marked debug-signed prereleases until signing exists.

### 8. Phase two: course depth and playback

- Give every starter concept an explicit German-to-Croatian and
  Croatian-to-German recall exercise before introducing more vocabulary.
- Add a reusable Croatian playback control to vocabulary and exercise strings.
- Use Android's installed text-to-speech engine and a Linux local speech
  service behind one replaceable adapter; never require network or microphone
  permissions.
- Announce playback state and unavailable voices accessibly, and remain fully
  usable when no Croatian voice is installed.
- Keep generated speech clearly distinct from future native-speaker recordings.

### 9. Phase two: A1 expansion

- Add compact units in order: farewells and courtesy, family and people,
  numbers and age, food and drinks, home, everyday actions, shopping, and
  travel/directions.
- Introduce roughly two genuinely new concepts in each early lesson and reuse
  prior concepts in most exercises.
- Require the same semantic content validation, mastery tags, both recall
  directions, tests, and human Croatian/German review for every unit.
- Keep one bundled offline course and sequential cross-unit progression until
  the content model has enough evidence to justify optional paths.
- Keep authored material independent from Dart code and use deterministic,
  schema-versioned JSON packs. A separate authoring repository may export an
  approved snapshot, but runtime downloads remain deferred.

## Design tokens

| Role | Color |
| --- | --- |
| Adriatic primary | `#1769D2` |
| Primary pressed | `#1052A8` |
| Croatian accent | `#E53935` |
| Accent depth | `#B9252B` |
| Background | `#F5F8FC` |
| Surface | `#FFFFFF` |
| Selected surface | `#E8F1FC` |
| Correct | `#2DAA63` |
| Incorrect | `#C92A35` |
| Crown | `#F4B942` |
| Primary text/crow | `#26343D` |
| Secondary text | `#536475` |
| Border | `#D9E2EC` |

Correctness always combines color with icon, label, and shape. Touch targets are at least 48 logical pixels and body text is at least 16 logical pixels.

## Security baseline

- No sensitive runtime permissions in the text-first release.
- No `INTERNET` permission, analytics, telemetry, advertising identifiers, background services, or shared storage.
- Disable cleartext traffic and Android backup/device transfer.
- Store only learning progress in the application sandbox; exclude answers from release logs.
- Export only the launcher activity required by Android.
- Commit the lockfile, scan dependencies and secrets, inspect final APK permissions, and pin GitHub Actions by immutable revision.
- An old phone's missing OS security patches cannot be repaired by CroLingo; the app limits its own attack surface and stores no secrets.

## Quality definition

A change is committable only when `./localPipeline.sh --noRun` succeeds: environment and repository policy, locked dependencies, generated-source consistency, formatting, strict analysis, custom/framework linting, shell/workflow/docs checks, content validation, tests, coverage, Android lint, secret/dependency scans, clean Linux build, APK builds, AAB build, and artifact/manifest inspection.

Every new behavior includes tests. Authored Dart code targets at least 85% line coverage; grading, progression, streak, review, migrations, and validation target at least 95%. Threshold reductions require explicit approval.

## MVP acceptance

- The reviewed starter unit works fully offline on Android and Linux.
- All four text exercise families, both translation directions, strict grading, feedback, retries, persistence, progression, XP, crowns, reviews, streaks, and statistics work end to end.
- Both physical phones install, launch, upgrade, persist, and recover after process termination.
- Linux renders at 412×915; Android adapts without overflow from 320–480 logical pixels and at 200% text scale.
- The complete local and online pipelines pass and reproducibly produce Linux, APK, split APK, and AAB artifacts.

## Deferred scope

Native-speaker audio, listening exercises, microphone access, learner
recordings, sample comparison, pronunciation grading, backend, accounts,
synchronization, social features, monetization, web, iOS, and production-signed
releases are not part of phase two. System-provided TTS playback and manually
dispatched development prereleases are included.
The future recording and course-authoring contract is documented in
`04_content_and_audio_authoring.md`; raw recordings are not bundled or played
until its manifest, preparation, validation, and fallback work is implemented.

## Physical-device checklist

Run `scripts/check_android_device.sh --serial ID --install` on each reference
phone, then verify first launch, all exercise controls, process restart/resume,
lesson unlock, streak/XP persistence, 200% system text, TalkBack focus order,
upgrade with `adb install -r`, airplane-mode operation, and app-data removal on
uninstall. Record the actual Android API, ABI, and security-patch date; do not
infer them from the vendor UI label.
