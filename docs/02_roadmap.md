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

Session checkpoint on 2026-08-09:

- Every earlier checkpoint recorded here has been superseded. The `v0.0.32`
  entries described a prerelease published before the release workflow began
  publishing normal latest releases, and before the stable Android signing
  identity existed.
- Releases now publish as full GitHub releases, signed with the stable
  external identity and verified against the committed certificate
  fingerprint.
- Record a new checkpoint only with the run identifier, the tag, and the
  version it published, so a stale entry stays obvious.

## Ordered work

1. **Restore verified delivery.** Complete. Quality is proven on the hosted
   runner with hidden report uploads, low-disk build sequencing, guarded SDK
   cleanup, and verified build artifact upload. The release workflow publishes
   a normal latest GitHub release rather than a prerelease.
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
6. **Complete learner controls.** Largely done. Settings persist the
   answer-feedback sound preference, one of five appearances including a
   high-contrast option held to WCAG AAA, and a developer switch that opens
   locked lessons. Concise grammar references remain open, and must not weaken
   the offline or minimal-permission baseline.
7. **Harden content authoring.** Version the course schema, produce
   deterministic validated content packs, and support an optional separate
   authoring repository that exports reviewed snapshots. Implement the staged
   [Content Studio design](editor.md); do not add runtime downloads yet.
8. **Finish device and accessibility qualification.** Verify TalkBack,
   keyboard traversal, contrast, reduced motion, 200% text, interruption
   recovery, upgrades, and airplane-mode operation on Linux and both reference
   phones. `integration_test/` is the harness for the automatable part; run it
   with `scripts/run_integration_tests.sh <serial>` on each phone. Contrast is
   already asserted per appearance by an automated test. The rest still needs a
   person and must not be inferred from a green pipeline.
9. **Add stable signed delivery.** Complete. The external Android key is backed
   up outside Git and installed as protected CI secrets. Releases verify the
   committed public certificate fingerprint before publication, enabling
   in-place upgrades that retain app-private progress.
10. **Integrate recorded media later.** When native-speaker recordings arrive,
   implement the manifest, preparation, validation, licensing, and fallback
   contract from [the authoring guide](04_content_and_audio_authoring.md).
   Listening, learner recording, model-sample comparison, and pronunciation
   scoring require separate product decisions and privacy review.

## Immediate release checkpoint

Download the ARM64 APK from the latest published release, verify it against
`SHA256SUMS.txt`, install it on both reference phones, and record the results of
the physical-device checklist in the release notes or an issue.

Push before dispatching a release, and dispatch one only when that version is
actually going onto a device for testing.

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
