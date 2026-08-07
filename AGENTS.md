# CroLingo agent agreement

- Read `docs/00_product_spec.md`, `docs/01_plan.md`, and `docs/03_questions.md` before changing product behavior. Newer documents override conflicts in the original specification.
- CroLingo is an offline-first Flutter app for Android and Linux. Keep behavior equivalent; Linux uses a fixed 412×915 phone viewport, while Android is responsive.
- The text-first milestone excludes listening, TTS, learner recording, and pronunciation assessment.
- Keep presentation, application/domain logic, persistence, content, and platform adapters separated. Dependencies must support Android and Linux.
- Use minimal permissions, app-private storage, no release networking, no telemetry, and no committed secrets or signing material.
- Run `./localPipeline.sh --noRun` before every commit. Do not weaken a guardrail just to pass it.
- Every commit must be atomic, conventional, locally committed, usable, buildable, and must bump the single `pubspec.yaml` version. Never create tags or push unless explicitly requested.
- Update this file only for durable working rules; keep product uncertainties and chosen defaults in `docs/03_questions.md`.
