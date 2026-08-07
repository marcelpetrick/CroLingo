# CroLingo agent agreement

- Read `docs/00_product_spec.md`, `docs/01_plan.md`, and `docs/03_questions.md` before changing product behavior. Newer documents override conflicts in the original specification.
- CroLingo is an offline-first Flutter app for Android and Linux. Keep behavior equivalent; Linux uses a fixed 412×915 phone viewport, while Android is responsive.
- System-provided Croatian TTS playback is in scope behind a replaceable Android/Linux adapter. Native recordings, listening exercises, learner recording, and pronunciation assessment remain deferred.
- Keep presentation, application/domain logic, persistence, content, and platform adapters separated. Dependencies must support Android and Linux.
- Treat bundled course JSON as authored product data: validate it in the pipeline, use stable IDs, and test every parser and grading rule.
- Persist attempts and checkpoints through the progress repository; store timestamps in UTC and derive local calendar dates only at the boundary.
- Classify every exercise with an explicit mastery dimension; derive mastery from persisted attempt history so content, scheduling, and analytics share stable exercise IDs.
- Treat generated TTS as optional enhancement: keep the learning flow usable without a voice, use `hr-HR`, expose accessible playback state, and add no microphone or network permission.
- Keep core screens overflow-free at 320 logical pixels and 200% text scaling; preserve semantic labels and non-color feedback.
- Use minimal permissions, app-private storage, no release networking, no telemetry, and no committed secrets or signing material.
- Keep the complete Gradle wrapper tracked and executable; update it only with
  Gradle's wrapper task and update the pinned pipeline checksum in the same
  atomic commit.
- Run `./localPipeline.sh --noRun` before every commit. Do not weaken a guardrail just to pass it.
- Every commit must be atomic, conventional, locally committed, usable, buildable, and must bump the single `pubspec.yaml` version. Never create tags or push unless explicitly requested.
- Update this file only for durable working rules; keep product uncertainties and chosen defaults in `docs/03_questions.md`.
