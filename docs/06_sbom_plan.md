# SBOM implementation plan

This plan defines how CroLingo will publish one truthful software inventory in
both CycloneDX and SPDX representations. It was written before implementation;
the implementation must be reviewed against it and the coverage limits below
must remain visible.

Implementation status: complete. `scripts/generate_sbom.sh` is the shared
implementation behind the root `generateSBOM.sh`, Quality, and Release entry
points described below.

## Decisions and rationale

- Pin [Syft 1.51.0](https://github.com/anchore/syft/releases/tag/v1.51.0)
  by release checksum. Syft has maintained catalogers for Dart
  `pubspec.lock` files and can emit a resolved inventory without a hand-written
  package list. It also converts the final merged inventory to SPDX while
  retaining its packages and relationships.
- Pin the official [CycloneDX Gradle Plugin
  3.3.0](https://plugins.gradle.org/plugin/org.cyclonedx.bom/3.3.0). It resolves
  the Android Gradle configurations, including transitive Maven artifacts that
  a source-directory scan cannot reliably infer. It will be applied through a
  repository-owned Gradle initialization script so SBOM infrastructure does
  not alter the application build plugins.
- Pin the official [CycloneDX CLI
  0.33.1](https://github.com/CycloneDX/cyclonedx-cli/releases/tag/v0.33.1)
  by release checksum. It will merge the Dart and Android inventories,
  normalize them to CycloneDX 1.7 JSON, and validate the CycloneDX document.
- Validate SPDX with the official SPDX tools-python 0.8.5 semantic validator.
  Its installation must be isolated below ignored `.tooling/`, fully pinned,
  and reproducible from a checked-in requirements lock rather than modifying
  the system Python environment.
- Generate CycloneDX 1.7, the current stable CycloneDX specification. Generate
  SPDX 2.3 JSON. SPDX 3.0.1 is the current specification, but the current
  stable Syft/CycloneDX conversion and official SPDX Python validation path
  exposes mature software-SBOM interoperability at SPDX 2.3. The pipeline must
  never mislabel this output as SPDX 3.0.1; support can move forward when the
  generator, converter, validator, and intended ingestion tools support it
  end-to-end.

The two public documents are two serializations of the same merged component
inventory. Independent generation would risk a CycloneDX file describing Dart
and Android while an unrelated SPDX scan silently describes a different set.
Intermediate source inventories are diagnostic only and are not release
assets.

The implementation deliberately does not use CycloneDX CLI for the SPDX
conversion: version 0.33.1 drops merged packages and relationships and its
result is rejected by the official SPDX validator. Syft's conversion preserves
them and passes that validator. A later tool upgrade must re-prove this choice
rather than assuming the limitation still exists.

## Dependency coverage

The Dart inventory will scan the resolved `pubspec.lock`, not merely declared
top-level dependencies from `pubspec.yaml`. It therefore contains locked
direct, development, and transitive Pub packages. Pub's lockfile is a flat
resolved inventory, so complete dependency-to-dependency edges cannot be
reconstructed reliably and will not be fabricated.

The Android inventory will ask Gradle to resolve the release classpaths and
will include direct and transitive Maven/Gradle components exposed by those
configurations, including Flutter plugins with Android artifacts. Build-only,
test-only, host SDK, operating-system packages, and the Android platform itself
are not shipped application components and will be excluded. Native libraries
bundled by dependencies are represented through their owning resolved package
where tooling provides no trustworthy standalone package identity.

No dependency component is maintained manually. The only project metadata
supplied by CroLingo will be the application name, version read from
`pubspec.yaml`, package identity, and GPL-3.0-only application license. These
describe CroLingo itself rather than inventing facts about dependencies. The
small `jq` enrichments in `scripts/generate_sbom.sh` also make CroLingo the SPDX
document's described application and connect it to every dynamically
discovered package; they contain no package names or versions.

Syft also derives heuristic CPE candidates from package names. Those are not
authoritative identifiers, so the generator deliberately removes them and
keeps the reliable Pub/Maven package URLs. Validation asserts that a guessed
CPE cannot leak into either public format.

## Outputs and local behavior

One repository script will generate and validate:

- `build/sbom/CroLingo.cdx.json` — CycloneDX 1.7 JSON;
- `build/sbom/CroLingo.spdx.json` — SPDX 2.3 JSON.

The local command is `./generateSBOM.sh`. It resolves fresh source inventories
into a temporary directory, merges them, validates both final documents,
verifies CroLingo metadata and representative Pub and Android components, and
only then replaces `build/sbom/`. A failed run must leave no apparently
successful new public files. `build/` remains ignored.

`localPipeline.sh` runs SBOM generation and validation after the clean builds,
then scans both representations with Trivy and OSV-Scanner. The project has no
optional-stage mechanism and the SBOM is a release requirement, so there is no
opt-out that could accidentally produce a release without it.

## GitHub Actions and releases

The existing Quality workflow already runs the complete local pipeline on
push, pull request, and manual dispatch. Its successful run artifact will add
the two validated files from `build/sbom/`; the workflow keeps read-only
repository permissions.

The manually dispatched Release workflow will generate the files from the
exact checked-out commit as part of the same complete pipeline that builds and
signs the APK/AAB. `scripts/package_release.sh` will copy them to versioned
release assets:

- `CroLingo-<version>.cdx.json`;
- `CroLingo-<version>.spdx.json`.

They will be included in `SHA256SUMS.txt` and attached by the existing single
`gh release create` operation. Missing or invalid SBOMs will stop packaging
before the workflow can create a tag or release. No new workflow permission is
needed: Quality stays `contents: read`, while only the existing Release job
retains `contents: write` for its final publication step.

## Validation and maintenance

Generation will check JSON syntax with `jq`, validate CycloneDX 1.7 with the
official CycloneDX CLI, and parse plus semantically validate SPDX 2.3 with
official SPDX tools-python. Focused script tests will corrupt each format and
prove validation fails, inspect component counts and package URLs, and ensure
both ecosystems are present. Existing actionlint, zizmor, shellcheck,
markdownlint, secret scanning, vulnerability scanning, builds, and artifact
inspection remain mandatory.

Pinned binary archives and Python packages will be checksum verified during
bootstrap. Tool versions and checksums are code-reviewed maintenance data;
dependency entries are always discovered dynamically. Dependabot does not
update these non-ecosystem tool pins, so a deliberate maintenance change is
required when an SBOM tool is upgraded.

Before commit, run the focused SBOM tests, the generator, both validators, and
`./localPipeline.sh --noRun`; inspect both generated documents and the complete
diff. Review from Flutter/build, SBOM, GitHub Actions, security, and six-month
maintenance perspectives. Correct every finding and confirm no generated SBOM,
temporary Gradle file, Python environment, or downloaded tool is tracked.
