# GitHub Actions billing and usage

This document records the billing constraints relevant to CroLingo as of
27 November 2026. GitHub can change plans and prices, so confirm current values in
the linked official documentation before making a spending decision.

## Current repository situation

`marcelpetrick/CroLingo` is a public repository owned by a personal account,
so that the project and its releases are openly visible. Its workflows use
standard GitHub-hosted Ubuntu runners. **Their compute is free for public
repositories** and does not consume the owner’s included Actions minutes.
Artifact and cache storage follow the separately documented storage policies.

The included GitHub Free allowances still bound anything that is not a standard
runner in a public repository:

- USD 12 of included compute per month for eligible private repository jobs;
- 500 MB of Actions artifact storage under the GitHub Free plan; and
- 10 GB of included Actions cache storage per repository.

The compute allowance resets each billing cycle. Different runner types use
it at different rates. Storage is measured over time, so artifact size and
retention both matter. Billable jobs can consume compute before they fail or
are cancelled.

If CroLingo became private, eligible jobs would draw from the account’s
included compute allowance before incurring compute charges. Larger hosted
runners are billable even in public repositories. The owner supplies and
secures any self-hosted runner.

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
GitHub lists USD 0.006 per minute for billed usage on the standard
two-core x64 Linux runner.

Configure a budget with **Stop usage when budget limit is reached** if the
desired maximum spend is zero. Enable included-usage alerts as well; GitHub can
notify account owners at 90% and 100% of the included allowance.

## CroLingo estimate and controls

Five recent successful Quality runs took about 14 to 27 minutes. Standard
runner compute for those jobs was free. If the repository became private,
the USD 12 allowance would cover 2,000 minutes at the standard two-core x64
Linux rate. That is roughly 74 to 142 runs at the observed durations, before
accounting for other repositories and failed jobs. Consult the account
billing view for measured usage.

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
- [GitHub Actions storage and compute limits](https://docs.github.com/en/actions/reference/limits)
- [Included product usage](https://docs.github.com/en/billing/reference/product-usage-included)
- [Viewing usage](https://docs.github.com/en/billing/how-tos/products/estimate-spending)
- [Actions runner pricing](https://docs.github.com/en/billing/reference/actions-runner-pricing)
- [Budgets and alerts](https://docs.github.com/en/billing/concepts/budgets-and-alerts)
