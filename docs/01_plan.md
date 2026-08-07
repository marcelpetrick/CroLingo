# CroLingo implementation plan

## Outcome

CroLingo will be a polished, offline-first Flutter application that teaches Croatian to German-speaking families. Android is the distribution target; Linux is a native development and desktop companion using the same phone interface.

The first usable milestone is one human-reviewed starter unit of about five lessons. It implements vocabulary matching, typed translation in both directions, fill-in-the-blank, sentence construction, strict grading, unlimited retries, XP, sequential progression, crowns, streaks, local statistics, concept mastery, and spaced review.

Listening, native audio, TTS, learner recordings, sample comparison, and pronunciation grading are deferred until the text-learning loop is proven.

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
- Git: atomic conventional local commits; no tags or unsolicited pushes

## Delivery loops

Current status: loops 1 through 5 are complete, including durable SQLite
attempts/checkpoints, sequential unlocking, and all text exercise families.
Streak statistics and recent-mistake replay from loop 6 are implemented; concept
mastery, FSRS due dates, accessibility hardening, and physical-device checks
remain.

### 1. Foundation and guardrails

- Install and pin Flutter 3.44.7 with Java 21 and Android API 36.
- Bootstrap only Android and Linux.
- Add self-bootstrap scripts that reuse compatible system SDKs or install pinned tooling into ignored `.tooling/`.
- Add a complete local pipeline, tracked Git hooks, strict analyzer configuration, framework-specific linting, coverage gates, content validation, security scans, Android lint, and clean Android/Linux builds.
- Run the same pipeline in GitHub Actions for pushes, pull requests, and manual checks.

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
- Use a manual signing workflow with secrets outside Git. Quality workflows never publish or tag.

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

Native audio, listening, TTS, microphone access, learner recordings, sample comparison, pronunciation grading, backend, accounts, synchronization, social features, monetization, web, iOS, Git tags, and GitHub Releases are not part of this milestone.
