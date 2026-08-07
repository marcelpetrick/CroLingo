# CroLingo

CroLingo is an offline-first Flutter application that teaches Croatian to
German-speaking beginners. Android is the distribution target; Linux runs the
same interface in a phone-shaped development window.

The first milestone is deliberately text-focused. It includes a predefined
learning path, strict but explanatory grading, unlimited retries, matching,
translation, fill-in-the-blank, sentence construction, XP, streaks, mastery,
and spaced review. Audio and pronunciation work are deferred.

## Requirements and setup

Java 21 and the Android SDK can be reused when already installed. The repository
bootstrap script added in the quality-foundation loop installs pinned user-local
tooling where practical and validates the complete environment.

The pinned application toolchain is Flutter 3.44.7 with Android API 24–36.

## Quality contract

Every commit must bump the single version in `pubspec.yaml`, use a conventional
message, and pass:

```bash
./localPipeline.sh --noRun
```

The pipeline verifies formatting, strict static analysis, tests, coverage,
content, security policy, Android lint, and clean Android/Linux builds. GitHub
Actions invokes the same script.

## Documentation

- [Product specification](docs/00_product_spec.md)
- [Implementation plan](docs/01_plan.md)
- [Questions and assumed defaults](docs/03_questions.md)

## License

CroLingo is licensed under GNU GPL version 3. See `LICENSE`.
