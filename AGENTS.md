# Repository Instructions

## Objective

Build Dot Shell: an original, modular, wallpaper-first Linux desktop shell for
Niri using Quickshell and QML.

Before proposing or implementing product behavior, read:

- `docs/product-vision.md`
- `docs/interaction-model.md`
- `docs/target-platforms.md`
- `docs/architecture.md`
- `.specify/memory/constitution.md`, when present
- all artifacts for the active feature under `specs/`

## Spec-driven workflow

Substantial features require reviewed Spec Kit artifacts before implementation.
Use one bounded feature at a time. Do not silently expand the active feature to
adjacent shell surfaces.

Follow this production path:

1. `$speckit-specify`
2. `$speckit-clarify`
3. `$speckit-plan`
4. `$speckit-checklist`
5. `$speckit-tasks`
6. `$speckit-analyze`
7. `$speckit-implement`
8. `$speckit-converge`

If implementation reveals a requirement conflict or missing product decision,
return to the appropriate artifact instead of inventing behavior in code.

Do not manually modify installed Spec Kit skills or managed infrastructure.

## Product boundaries

The eDEX-UI reference concerns atmosphere only. Do not reproduce its dashboard,
terminal-centric layout, or functionality. Do not copy Caelestia's appearance.

The two required dot concepts are:

1. a borderless, feathered field summoned over any wallpaper;
2. animations aligned with dots embedded in a compatible wallpaper.

Do not replace the summoned field with a translucent rectangular card. The dots
themselves define the temporary surface, and their opacity approaches zero at
the field boundary.

## Architecture

- Separate system services, Niri adapters, visual components, animation logic,
  configuration, and IPC.
- Prefer reusable QML components and explicit states over duplicated animation
  code.
- Keep Niri-specific behavior behind adapters where practical.
- Do not introduce native C++ until QML/Quickshell is demonstrably insufficient
  and the approved plan records why.
- Keep the public CLI and IPC contracts versioned and documented.

## Quality

- Format and lint QML with the commands established by the implementation plan.
- Add automated tests for non-visual logic.
- Provide reproducible visual evidence for animation work.
- Test bright, dark, colorful, and visually busy wallpapers.
- Test multi-monitor, scale-factor, and reduced-motion behavior when relevant.
- Avoid unbounded animations, polling loops, and unnecessary full-screen redraws.
- Document new configuration and IPC options.
- Do not leave disabled code or unexplained TODO comments.

## Git workflow

- Branch from current `main`.
- Branch names are `feature/NN-kebab-case` or `fix/NN-kebab-case`.
- Write commit messages as one to three complete sentences. Each sentence MUST
  start with a capital letter and end with a period. Do not use Conventional
  Commit prefixes.
- Keep branches short-lived and rebase before review when necessary.
- Pull requests into `main` use squash merge.
- Never commit directly to a `release/YYYY.N` branch.
- Release-only changes land in `main` first, then the squash commit is
  cherry-picked to the active release branch.
- Never rewrite `main` or a published release branch.

## Safety

Do not modify the user's Niri configuration, system packages, login manager,
or global Quickshell installation unless explicitly requested.

Never commit secrets or private/license-unclear reference artwork. Private
references belong under `assets/references/private/`, which is ignored.

## Verification

Before declaring work complete:

1. Run the checks required by the active plan and repository CI.
2. Report exactly what was tested.
3. State untested compositor-, hardware-, or visual-dependent behavior.
4. Compare the result against the active specification and tasks.
5. Run convergence until it reports `Converged` for implemented features.
