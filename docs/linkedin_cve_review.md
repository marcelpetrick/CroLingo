# LinkedIn post: SBOM and CVE review from a team-lead perspective

Prepared on 13 August 2026. The CRA section is an engineering summary, not
legal advice; product scope and conformity strategy require a product-specific
legal assessment.

## Suggested post

**A vulnerability scanner reporting zero findings is not interesting by
itself. Proving that the security control can detect a known bad dependency
is.**

For CroLingo, our offline-first Flutter application for Android and Linux, we
built software supply-chain checks into the same pipeline developers run
locally and GitHub runs for every quality and release build.

The current evaluation does the following:

- resolves the actual dependency state instead of relying on a manually
  maintained spreadsheet;
- combines 138 locked Dart/Pub packages with 53 resolved Android/Maven
  packages;
- generates two standards-based software bills of materials: CycloneDX 1.7
  and SPDX 2.3 JSON;
- validates both documents before any security conclusion is accepted;
- preserves Package URLs for unambiguous ecosystem, package, and version
  matching;
- scans both SBOM formats with two independent open-source tools: Trivy and
  OSV-Scanner;
- compares CycloneDX and SPDX inventories and findings, failing if the two
  formats disagree;
- blocks the pipeline on Trivy High/Critical findings, every OSV advisory, or
  an operational scanner failure;
- supports current online data and repository-local offline databases;
- produces machine-readable evidence plus one offline, responsive HTML
  dashboard for human review;
- records the application version, full commit, evaluation time, scan mode,
  scanner policy, and whether local source changes were present.

The most useful test was deliberately negative. We injected two known
vulnerable components into isolated generated SBOMs—not into the application:

- `org.apache.commons:commons-text 1.9` was detected by Trivy as
  `CVE-2022-42889` (Critical) and by OSV as `GHSA-599f-7c49-w659`;
- `jose 0.3.5` was detected by OSV as `GHSA-vm9r-h74p-hg97`, while the current
  Trivy data did not match it.

That second result is exactly why independent data sources matter. A green
result from one tool is useful evidence, but it is not proof of safety. The
negative control demonstrated that the pipeline fails closed, both SBOM
representations lead to equivalent findings, and the dashboard changes from
green to **Action required**.

On 13 August 2026, we regenerated clean SBOMs from CroLingo's real dependency
graph and queried current Trivy and OSV data. Both formats agreed, and neither
scanner found a known policy-matching vulnerability in the identified Pub and
Maven components.

## Why this matters for engineering leadership

An SBOM is not a decorative compliance attachment. It is a versioned answer to
four operational questions:

1. What did we actually ship?
2. Which exact versions and transitive components are involved?
3. Can we reassess yesterday's release when a vulnerability is disclosed
   tomorrow?
4. Can we produce reviewable evidence without reconstructing the build under
   incident pressure?

The leadership decision is not merely which scanner to buy. It is whether the
team has an owned, repeatable process connecting dependency resolution, SBOM
generation, validation, vulnerability intelligence, release gating,
remediation, and retained evidence.

Useful safeguards from this implementation include:

- checksum-pinned scanner binaries rather than mutable downloads;
- the same root commands locally and in GitHub Actions;
- mandatory checks on pushes and releases;
- no suppressed vulnerabilities or hidden allowlist at project start;
- atomic replacement of generated evidence so a failed run cannot look
  successful;
- explicit wording that “no known match” is not equivalent to “secure”;
- a negative control that tests detection instead of trusting a zero counter.

## Is the EU Cyber Resilience Act active?

Yes—but “active” needs a precise answer.

The Cyber Resilience Act, Regulation (EU) 2024/2847, entered into force on
10 December 2024. Its application is phased:

- provisions concerning notification of conformity assessment bodies have
  applied since 11 June 2026;
- Article 14 reporting obligations for actively exploited vulnerabilities and
  severe security incidents apply from 11 September 2026;
- the main obligations apply from 11 December 2027.

The CRA covers hardware and software products with digital elements made
available on the EU market. “Free of charge” does not automatically mean out of
scope when a product is supplied in the course of a commercial activity.
Conversely, products not supplied in the course of commercial activity are not
subject to the CRA. Free and open-source software also has specific rules and
roles. Teams must establish the product's actual scope and economic-operator
role instead of guessing from the repository license.

For development organizations in scope, the CRA moves cybersecurity from a
best-effort engineering quality to a lifecycle product responsibility. The
Commission's summary highlights, among other things:

- a cybersecurity risk assessment that informs planning, design, development,
  production, delivery, and maintenance;
- due diligence for integrated third-party components;
- technical documentation that can support conformity and market-surveillance
  review;
- a declared support period and effective vulnerability handling during that
  period;
- post-market reporting of actively exploited vulnerabilities and severe
  security incidents;
- conformity assessment, an EU declaration of conformity, user information,
  and CE marking before an in-scope product is placed on the market.

An SBOM helps with component transparency, vulnerability response, and
evidence, but it does not by itself establish CRA conformity. It needs to sit
inside the wider secure-development and product-governance system.

## What a development team leader should establish now

1. **Scope and accountability:** identify products, releases, manufacturer or
   other economic-operator roles, responsible owners, and escalation paths.
2. **Product risk assessment:** connect foreseeable use, attack surfaces,
   security requirements, architecture decisions, and accepted residual risks.
3. **Dependency evidence:** generate validated SBOMs from resolved build state,
   preserve PURLs and transitive components, and bind evidence to the released
   commit and artifact.
4. **Continuous vulnerability handling:** monitor current and past releases,
   triage findings, assess reachability, patch safely, and communicate fixes.
5. **Reporting readiness:** define who decides that an issue is actively
   exploited or a severe incident, who contacts the relevant CSIRT/ENISA, and
   how the reporting clock is met even outside office hours.
6. **Release controls:** make security checks fail closed, protect signing
   identity, retain test results, and prevent stale evidence from being
   attached to a release.
7. **Support-period planning:** budget engineering capacity for updates and
   vulnerability handling after initial delivery, not only feature work before
   launch.
8. **Conformity evidence:** maintain technical documentation as a living output
   of development rather than a document assembled immediately before an
   audit.
9. **Practised response:** run negative controls and tabletop exercises. A
   process first exercised during a real disclosure is not a mature process.
10. **Honest communication:** state coverage and blind spots precisely. Native
    binaries, runtime services, unsafe product logic, and unknown
    vulnerabilities may require controls beyond an ecosystem SBOM scan.

For a team lead, the central shift is this: security evidence must be produced
by the delivery system continuously, while accountability for interpreting and
acting on that evidence remains human.

## Five leadership closing lines

Choose one; using all five in one post would sound less credible.

1. **My responsibility as engineering lead is not to promise zero risk; it is
   to make risk visible, decisions reviewable, and remediation repeatable.**
2. **I consider a security gate trustworthy only after we have proved its
   failure path with known-bad inputs.**
3. **I want every release decision backed by evidence tied to the exact source,
   dependency graph, and artifact—not by confidence inherited from the last
   green build.**
4. **Leadership in secure development means giving teams automated guardrails
   and retaining clear human ownership when those guardrails raise an alarm.**
5. **The standard I set is simple: know what we ship, know how we verify it,
   and know who acts when the evidence changes.**

## Suggested hashtags

`#CyberSecurity` `#SoftwareSupplyChain` `#SBOM` `#CycloneDX` `#SPDX`
`#DevSecOps` `#CyberResilienceAct` `#CRA` `#EngineeringLeadership`
`#SecureByDesign`

## Official references

- [Regulation (EU) 2024/2847, official text](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32024R2847)
- [European Commission summary of the CRA](https://digital-strategy.ec.europa.eu/en/policies/cra-summary)
- [European Commission CRA implementation timeline](https://digital-strategy.ec.europa.eu/en/factpages/cyber-resilience-act-implementation)
- [Commission guidance announcement, 27 July 2026](https://digital-strategy.ec.europa.eu/en/library/commission-publishes-new-guidance-support-timely-cyber-resilience-act-implementation)
