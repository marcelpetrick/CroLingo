# CroLingo agent agreement

- Read `docs/00_product_spec.md`, `docs/01_plan.md`, `docs/02_roadmap.md`,
  `docs/03_questions.md`, and `docs/05_architecture.md` before changing product
  behavior. Newer documents override conflicts in the original specification.
- CroLingo is an offline-first Flutter app for Android and Linux. Keep behavior equivalent; Linux uses a fixed 412×915 phone viewport, while Android is responsive.
- System-provided Croatian TTS playback is in scope behind a replaceable Android/Linux adapter. Native recordings, listening exercises, learner recording, and pronunciation assessment remain deferred.
- Keep presentation, application/domain logic, persistence, content, and platform adapters separated. Dependencies must support Android and Linux.
- Treat bundled course JSON as authored product data: validate it in the pipeline, use stable IDs, and test every parser and grading rule.
- Keep the Content Studio authoring database, runtime content store, and learner
  progress database as separate lifecycles. Exchange only deterministic,
  schema-versioned approved packs linked by permanent IDs; never edit shipped
  IDs or put raw recordings and author drafts in the learner database.
- Require explicit German-to-Croatian and Croatian-to-German recall for every
  concept. Reverse recall measures meaning retrieval and remains distinct from
  Croatian spelling practice.
- Persist attempts and checkpoints through the progress repository; store timestamps in UTC and derive local calendar dates only at the boundary.
- Classify every exercise with an explicit mastery dimension; derive mastery from persisted attempt history so content, scheduling, and analytics share stable exercise IDs.
- Treat generated TTS as optional enhancement: keep the learning flow usable without a voice, use `hr-HR`, expose accessible playback state, and add no microphone or network permission.
- Keep core screens overflow-free at 320 logical pixels and 200% text scaling; preserve semantic labels and non-color feedback.
- Keep the active language direction visible with Croatian/German flag cues and
  written language names; flags are decorative reinforcement, never the only
  accessible signal.
- Treat `designIdeas/` as reviewed concept material, not runtime assets. Keep
  visual work original, record its generation brief, and add selected assets to
  application bundles only through a separately tested product decision.
- Use minimal permissions, app-private storage, no release networking, no
  telemetry, and no committed secrets or private signing material. Never rotate
  the stable Android signing identity without an explicit migration plan;
  verify its committed public certificate fingerprint on every release.
- Keep the complete Gradle wrapper tracked and executable; update it only with
  Gradle's wrapper task and update the pinned pipeline checksum in the same
  atomic commit.
- Run `./localPipeline.sh --noRun` before every commit. Do not weaken a guardrail just to pass it.
- Keep authored Dart line coverage at or above 98% with behavior-focused tests;
  do not exclude authored files or lower the threshold to accommodate a change.
  Declaration-only code that no runtime path can reach, such as the Drift table
  getters the generator consumes, is marked with `coverage:ignore` and explains
  itself; never use that marker to hide untested logic.
- Every commit must be atomic, conventional, locally committed, usable,
  buildable, and must bump the single `pubspec.yaml` version. In a shared
  worktree, stage only explicitly owned files, never commit another agent's
  index or worktree changes, and wait for overlapping work to commit before
  advancing the shared version from the new `HEAD`. Never create tags or push
  unless explicitly requested.
- Write a conventional subject of at most 72 characters, then a blank line,
  then a body. The subject says what changed; the body says why it changed and
  what a reader must know. Cover the motivation, the approach taken, any
  behaviour or data change, and anything deliberately left out. Wrap the body
  at 72 characters. Prefer prose over a file list, because the diff already
  lists the files. A commit whose reason is not obvious from its subject alone
  is not finished.
- Only the manually dispatched release workflow may create a tag, and only
  after the complete pipeline and stable signing verification succeed; it
  publishes a normal latest release rather than a prerelease. Local agents
  still never tag or push unless separately requested.
- Update this file only for durable working rules; keep product uncertainties and chosen defaults in `docs/03_questions.md`.
