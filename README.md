# CroLingo

CroLingo is a friendly, offline-first app for German-speaking beginners who
want to learn Croatian. It combines a short Adriatic-themed learning path with
matching, translation, fill-in-the-blank, and sentence-building exercises.
Answers are checked locally, mistakes receive a useful explanation, and every
exercise can be retried without a limit.

The app is built once with Flutter and runs on:

- Android 7.0/API 24 through Android 16/API 36;
- older ARM64 phones such as the Huawei Mate 20;
- current ARM64 phones such as Xiaomi/Poco devices;
- Linux x64 in a fixed 412×915 phone-shaped desktop window.

The first milestone is deliberately text-only. Native-speaker audio and any
learner-recording or pronunciation comparison will be designed after the core
learning loop has been evaluated.

## Author

CroLingo was created by **Marcel Petrick**. Contributions remain attributed
through Git history.

## What works today

- Croatian visual identity with an original crow mascot;
- shared Android and Linux navigation;
- a validated, bundled five-lesson starter course;
- strict offline grading with Croatian characters preserved;
- matching, two-way translation, gaps, and sentence tiles;
- immediate correction, explanations, unlimited retries, and XP;
- durable local progress, lesson resume/unlocking, streaks, recent mistakes, and
  replay of recently learned lessons;
- a local vocabulary view with mastery for recognition, both recall directions,
  sentence production, and grammar application;
- reproducible Android APK/AAB and native Linux builds;
- strict analysis, linting, tests, coverage, security scans, and CI.
- automated narrow-phone and 200% text-scaling layout checks.

FSRS-based due-date scheduling drives recommended reviews with 90% desired
retention. Fine-grained concept mastery is derived from durable answer history
without collecting personal data. The current status and sequence live in
[the implementation plan](docs/01_plan.md).

## Bootstrap a fresh clone

Linux development requires Git, `curl`, `unzip`, `xz`, CMake, Ninja, Clang,
GTK 3 development headers, Java 21, and an Android SDK. With those system
prerequisites available, the repository installs its pinned Flutter and quality
tools into the ignored `.tooling/` directory:

```bash
./scripts/bootstrap.sh
```

The script is safe to rerun. It verifies downloads by checksum, reuses a
compatible Android SDK, installs missing pinned SDK components, fetches locked
Dart packages, and activates the tracked Git hooks. Nothing is installed into
the repository's tracked source tree.

Check the resulting environment with:

```bash
./scripts/flutterw doctor -v
./scripts/flutterw devices
```

## Run CroLingo

Start the native Linux development app:

```bash
./scripts/flutterw run -d linux
```

For Android, enable developer options and USB debugging on the phone, connect
it by USB, accept the computer's debugging key, then run:

```bash
adb devices
./scripts/flutterw run -d <device-id>
```

Inside the app, choose **Lernweg**, open the blue first lesson, complete each
exercise, read the feedback, and use **Weiter**. Course content and grading do
not need a network connection.

## Check every change

Run the same mandatory gate used by the local pre-commit hook and GitHub
Actions:

```bash
./localPipeline.sh --noRun
```

Omit `--noRun` to launch the finished Linux bundle after all checks. The
pipeline validates repository policy, version progression, dependencies,
course content, formatting, static analysis, Flutter-specific linting, shell
and workflow files, Markdown, tests, coverage, Android lint, secrets,
vulnerabilities, clean builds, and final APK permissions.

Every commit must be conventional and atomic, bump the single version in
`pubspec.yaml`, and leave both platforms buildable. The project does not use
Git tags for versioning.

## Build distributable artifacts

Build the native Linux bundle:

```bash
./scripts/flutterw build linux --release
```

Build a universal APK, smaller per-architecture APKs, and the Play-compatible
Android App Bundle:

```bash
./scripts/flutterw build apk --release
./scripts/flutterw build apk --release --split-per-abi
./scripts/flutterw build appbundle --release
```

Outputs are written below `build/` and intentionally ignored by Git. Flutter's
development release APK uses a development signing setup; public distribution
must use a private release key stored outside this repository. Never commit a
keystore, password, service-account file, or generated artifact.

To install a local APK on a connected test phone:

```bash
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

For a repeatable compatibility report, and optionally a safe development
install/launch, use:

```bash
./scripts/check_android_device.sh --serial <device-id>
./scripts/check_android_device.sh --serial <device-id> --install
```

Both reference phones are ARM64. The pipeline also produces `armeabi-v7a` and
`x86_64` variants plus a universal APK.

## Project map

```text
assets/content/   validated offline Croatian course
docs/             specification, implementation plan, and open decisions
lib/app/          routing, shell, and app composition
lib/data/         asset and persistence adapters
lib/domain/       course and learning rules
lib/features/     screens and exercise presentation
scripts/          reproducible bootstrap and Flutter wrapper
test/             domain and end-to-end widget tests
```

Start with these documents before changing product behavior:

- [Product specification](docs/00_product_spec.md)
- [Implementation plan](docs/01_plan.md)
- [Questions and adopted defaults](docs/03_questions.md)
- [AI agent working agreement](AGENTS.md)

## Privacy and security

The text-first app requests no sensitive runtime permissions, has no release
network permission, analytics, ads, accounts, or telemetry, and disables
cleartext traffic and Android backup. Learning data stays in app-private local
storage. An outdated phone's operating-system vulnerabilities cannot be fixed
by an app; CroLingo limits its own attack surface and stores no secrets.

## License

CroLingo is free software licensed under the
[GNU General Public License version 3](LICENSE).
