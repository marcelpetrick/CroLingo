# CroLingo development roadmap

This is the prioritized execution view of the broader
[implementation plan](01_plan.md). It records what is complete, what comes
next, and which checks require a person or external system. Product decisions
remain in the plan and [adopted-default register](03_questions.md).

## Current baseline

Phase one is complete: CroLingo has an offline text-learning loop, durable
progress, ordered lessons, review scheduling, mastery, statistics, Android and
Linux builds, and mandatory local/online quality gates. Phase two is active.
System-provided Croatian playback and cross-unit progression are implemented;
native recordings and pronunciation assessment remain deferred.

Session checkpoint on 2026-08-07:

- Remote Quality run
  [31199047430](https://github.com/marcelpetrick/CroLingo/actions/runs/31199047430)
  passed for pushed commit `619afd5` (`0.0.32+33`), including verified build
  uploads.
- Development release run
  [31200380595](https://github.com/marcelpetrick/CroLingo/actions/runs/31200380595)
  passed for the same commit. It created prerelease
  [v0.0.32](https://github.com/marcelpetrick/CroLingo/releases/tag/v0.0.32)
  and published checksummed ARM64, ARM32, x86_64, universal APK, AAB, and Linux
  x64 artifacts. The remote tag resolves to `619afd5`.
- Local commit `65ebe76` documents GitHub Actions billing and advances the
  version to `0.0.33+34`. It passed the complete local pipeline and remains for
  the owner to push.

## Ordered work

1. **Restore verified development delivery.** Complete. Quality is proven on the hosted
   runner with hidden report uploads, low-disk build sequencing, guarded SDK
   cleanup, and verified build artifact upload. Development release run
   `31200380595` passed and published all expected artifacts as prerelease
   `v0.0.32`.
2. **Make Home resume real course progress.** Complete. Home derives its
   primary action from ordered course data and durable checkpoints, including
   continuation across unit boundaries.
3. **Add the second course unit.** Implementation complete. Farewells,
   courtesy, first-meeting, and origin phrases are validated JSON with both
   recall directions, mastery tags, explanations, tests, and two new concepts
   per lesson. Croatian/German human review remains an external checkpoint.
4. **Maintain the 95% coverage floor.** Complete and enforced for authored
   Dart code. New behavior must add tests without reducing this threshold.
5. **Expand the A1 path.** Add small reviewed units for family and people,
   numbers and age, food and drinks, home, everyday actions, shopping, and
   travel/directions. Reuse known material in most exercises.
6. **Complete learner controls.** Add concise grammar references and local
   settings for supported accessibility and playback preferences without
   weakening the offline or minimal-permission baseline.
7. **Harden content authoring.** Version the course schema, produce
   deterministic validated content packs, and support an optional separate
   authoring repository that exports reviewed snapshots. Do not add runtime
   downloads yet.
8. **Finish device and accessibility qualification.** Verify TalkBack,
   keyboard traversal, contrast, reduced motion, 200% text, interruption
   recovery, upgrades, and airplane-mode operation on Linux and both reference
   phones.
9. **Add production delivery.** Configure an external Android signing key and
   protected CI secrets, then publish production-signed artifacts. Development
   prereleases stay clearly marked until this is complete.
10. **Integrate recorded media later.** When native-speaker recordings arrive,
   implement the manifest, preparation, validation, licensing, and fallback
   contract from [the authoring guide](04_content_and_audio_authoring.md).
   Listening, learner recording, model-sample comparison, and pronunciation
   scoring require separate product decisions and privacy review.

## Immediate release checkpoint

Download the ARM64 APK from prerelease `v0.0.32`, verify it against
`SHA256SUMS.txt`, install it on both reference phones, and record the results of
the physical-device checklist in the release notes or an issue.

The owner can push the local documentation commits when work resumes. A later
Development release should only be dispatched when that newer version is
intended for device testing.

The remote workflow, physical devices, human language review, and future
production signing material are external checkpoints. They must never be
reported as complete based only on local automated tests.

## Definition of done for each roadmap item

- The change is split into a conventional, atomic, version-bumped commit.
- `./localPipeline.sh --noRun` passes before the commit.
- New behavior and content have focused automated tests.
- Android and Linux remain offline-capable, buildable, and behaviorally
  equivalent within their documented viewport differences.
- Any required human or external verification is recorded honestly rather
  than inferred.
