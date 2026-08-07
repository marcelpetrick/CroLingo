# GitHub Actions billing and usage

This document records the billing constraints relevant to CroLingo as of
2026-08-08. GitHub can change plans and prices, so confirm current values in
the linked official documentation before making a spending decision.

## Current repository situation

`marcelpetrick/CroLingo` is a public repository owned by a personal account,
so that the project and its releases are openly visible. Its workflows use
standard GitHub-hosted Ubuntu runners, and **standard hosted runners are free
for public repositories**. Workflow time in this repository therefore does not
consume the owner's included Actions minutes and cannot produce a hosted-runner
bill.

The included GitHub Free allowances still bound anything that is not a standard
runner in a public repository:

- 2,000 GitHub Actions minutes per month for private repositories;
- 500 MB of shared Actions artifact and GitHub Packages storage; and
- 10 GB of Actions cache storage per repository.

Minutes reset at the start of each billing cycle. Storage is measured over
time, so artifact size and retention both matter. Failed and cancelled jobs
consume the minutes they ran before stopping.

Charges would return if CroLingo were ever made private again, or if a workflow
were moved to a larger runner class. Self-hosted runner execution does not
consume hosted-runner minutes either, although the owner remains responsible for
the machine and its security.

Making the repository public also means every workflow run, log, and release
artifact is world-readable. Never place a keystore, password, or token in the
repository or in workflow output; CroLingo keeps signing material outside Git
for exactly this reason.

## Where to see current usage

For the personal account that owns CroLingo:

1. Sign in to GitHub as the repository owner.
2. Open <https://github.com/settings/billing>.
3. Select the **Usage** or **Metered usage** view.
4. Filter the product to **Actions** and choose the current billing period.
5. Group by repository to isolate `marcelpetrick/CroLingo`, if that option is
   available.

The same area shows budgets, payment configuration, and usage trends. Usage
data may not update immediately after a workflow completes. Individual run
duration is also visible on the run page under the repository's **Actions**
tab, but that duration is not a substitute for the account billing view.

## Will GitHub charge automatically?

Not for CroLingo's current workflows, because standard hosted runners are free
while the repository is public. The rules below apply to private repositories,
larger runner classes, and any future change of visibility.

If the account has no valid payment method or paid Actions usage is not
enabled, GitHub blocks further hosted-runner usage after the included quota is
exhausted. If paid usage is enabled, excess usage can be charged to the account.
The documented baseline price for a standard two-core Linux runner is currently
USD 0.006 per minute.

Configure a budget with **Stop usage when budget limit is reached** if the
desired maximum spend is zero. Enable included-usage alerts as well; GitHub can
notify account owners at 90% and 100% of the included allowance.

## CroLingo estimate and controls

A complete CroLingo Quality or Release job currently takes roughly 15 to 20
hosted-runner minutes. Those minutes are free while the repository is public.
If CroLingo were private, the same rate would permit about 100 to 130 complete
jobs per month within 2,000 minutes, or approximately 50 to 65 Quality-and-
Release pairs. This is only a planning estimate; the billing view is
authoritative.

These habits keep runs fast and would keep a private repository inside its
allowance:

- run `./localPipeline.sh --noRun` locally before pushing;
- push coherent, already verified commits instead of using CI as an iterative
  debugger;
- dispatch releases only for builds that will actually be tested;
- avoid rerunning successful jobs without a reason;
- retain only useful diagnostic and build artifacts; and
- shorten temporary artifact retention if storage approaches its allowance.

GitHub Releases are the durable download location for published CroLingo APK
and Linux bundles. Temporary Quality artifacts should not be treated as an
archive.

## Official references

- [GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions)
- [Included product usage](https://docs.github.com/en/billing/reference/product-usage-included)
- [Viewing metered usage](https://docs.github.com/en/billing/managing-billing-for-your-products/managing-billing-for-git-large-file-storage/viewing-your-git-large-file-storage-usage)
- [Budgets and alerts](https://docs.github.com/en/billing/concepts/budgets-and-alerts)
