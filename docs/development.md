# Development Guide

## Prerequisites

- Git
- Python 3.11 or newer
- `uv`
- Codex CLI
- GitHub Spec Kit (`specify-cli`)
- Quickshell and Niri when implementation begins

The summoned-volume-OSD feature initially validates Quickshell 0.3.2 with Qt
6.12 and Niri 26.04. Earlier 0.3.1 API research does not imply tested support
for that version. On Arch-based systems, install with
`sudo pacman -S --needed quickshell` and verify with `qs --version`.
Qt's formatter, linter and test runner may be under `/usr/lib/qt6/bin`.

The current bar preview uses the same Quickshell/Niri environment. Run
`scripts/check-qml.sh`, `tests/test-cli.sh`, `tests/test-package.sh`, and
`tests/test-installed-runtime.sh` before review. The bar's remaining live
acceptance checks are tracked in
[`specs/002-configurable-dot-bar/tasks.md`](../specs/002-configurable-dot-bar/tasks.md);
software-rendered captures do not replace Niri checks on each edge and scale.

Install and verify Spec Kit:

```sh
uv tool install specify-cli
specify version
specify self check
```

Initialize Codex integration from the repository root:

```sh
./scripts/bootstrap-spec-kit.sh
```

The committed constitution is preserved by Spec Kit initialization. The script
installs `specify-cli` with `uv` if it is not already available, then installs
the Codex integration in place.

Codex skills are installed under `.agents/skills/` and invoked with a dollar
prefix, for example `$speckit-specify`.

## Constitution prompt

Run `$speckit-constitution` once with the principles in
`docs/spec-kit-bootstrap.md`, review the resulting constitution, and commit it.

## Per-feature flow

For production features:

```text
$speckit-specify
$speckit-clarify
$speckit-plan
$speckit-checklist
$speckit-tasks
$speckit-analyze
$speckit-implement
$speckit-converge
```

Invoke and review each stage separately. Do not paste the whole sequence as one
request. Commit reviewable artifact milestones.

## Suggested feature sequence

1. Quickshell/Niri runtime bootstrap
2. Summoned dot-field primitive
3. Feathering and adaptive contrast
4. Path/node animation engine
5. Volume OSD vertical slice
6. Compatible-wallpaper metadata
7. Embedded-lattice renderer
8. Bar foundation and module contract
9. Workspace integration
10. Launcher, notifications, settings, widgets, and lock surface as separate specs
