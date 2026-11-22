# Contributing to Dot Shell

## Development model

Dot Shell uses trunk-based development. `main` is the integration branch and
must remain releasable. Work happens on short-lived branches and enters `main`
through reviewed pull requests using squash merge.

## Branch names

Use a two-digit sequence scoped to the repository's current work queue:

```text
feature/01-summoned-dot-field
feature/02-volume-osd
fix/03-multimonitor-placement
```

Rules:

- `feature/NN-kebab-case-small-description`
- `fix/NN-kebab-case-small-description`
- lowercase ASCII words separated by hyphens
- begin at `01`; advance monotonically and do not reuse identifiers casually

## Feature workflow

1. Update local `main`.
2. Create a short-lived feature or fix branch.
3. Create and review the Spec Kit artifacts for the bounded change.
4. Implement and verify the approved tasks.
5. Open a pull request against `main`.
6. Squash merge after checks and review pass.
7. Delete the merged branch.

## Releases

Release branches use `release/YYYY.N`, where `N` starts at `1` for the year's
first release and increases without a fixed upper bound:

```text
release/2026.1
release/2026.2
release/2027.1
```

Cut a release branch from the desired commit on `main`. Stabilization happens
without direct commits to the release branch.

If a feature or fix is needed during stabilization:

1. Branch from `main` using the normal naming convention.
2. Open the pull request against `main`.
3. Squash merge it into `main`.
4. Cherry-pick that squash commit onto the current release branch.
5. Resolve and document any divergence.

Release tags use `vYYYY.N.PATCH`, for example `v2026.1.0`. Tags are created
from the release branch and trigger release packaging.

## Pull requests

- Keep the scope aligned with one specification.
- Link the feature specification and tasks.
- Explain user-visible behavior and tradeoffs.
- Include verification evidence.
- Include screenshots or recordings for visual changes.
- Call out untested Niri, display, scaling, or GPU configurations.

## Commit messages

Use Conventional Commit-style subjects where practical:

```text
feat: add summoned dot field
fix: preserve field placement across output changes
docs: clarify compatible wallpaper metadata
chore: update release packaging
```
