# Release Process

## Branching

Create `release/YYYY.N` from the desired commit on `main`. The annual sequence
starts at `1` and increases for each release.

All stabilization changes land in `main` first through normal squash-merged
feature or fix pull requests. Cherry-pick the resulting squash commit onto the
active release branch.

## Tagging

Use annotated tags shaped as `vYYYY.N.PATCH`:

```sh
git switch release/2026.1
git tag -s v2026.1.0 -m "Dot Shell 2026.1.0"
git push origin v2026.1.0
```

Pushing the tag triggers `.github/workflows/release.yml`. It validates the
repository, builds a versioned installation archive, creates SHA-256 checksums,
and publishes a GitHub release.

## Hotfix example

```sh
git switch main
git pull --ff-only
git switch -c fix/07-correct-output-selection
# open PR and squash merge to main
git switch release/2026.1
git cherry-pick <squash-commit-on-main>
git push origin release/2026.1
```
