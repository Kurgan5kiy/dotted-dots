<div align="center">

# Dot Shell

**A desktop interface hiding in plain sight.**

Dot Shell is a wallpaper-first Linux shell for **Niri**, built with
**Quickshell**. Interfaces emerge from fields of dots, trace themselves into
existence, become interactive, and dissolve back into the desktop.

[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0--only-8ba4ff.svg)](LICENSE)
[![Window manager: Niri](https://img.shields.io/badge/window%20manager-Niri-bb9af7.svg)](https://github.com/YaLTeR/niri)
[![Built with Quickshell](https://img.shields.io/badge/built%20with-Quickshell-7dcfff.svg)](https://quickshell.org/)

</div>

## The idea

Dot Shell has two visual modes:

- **Summoned field** — on any wallpaper, a borderless field of dots appears
  from nowhere. The dots are strongest around the interaction and feather into
  full transparency at the edges.
- **Embedded field** — a compatible dotted wallpaper provides the dormant
  lattice. Dot Shell awakens its existing dots and draws paths through them,
  making the interface feel as if it was inside the wallpaper all along.

## Status

**Pre-alpha / specification phase.** The repository currently contains the
product definition, agent workflow, release plumbing, installer, and CLI
contract. Shell implementation begins with the first reviewed Spec Kit feature.

## Planned surfaces

- Adaptive bar and Niri workspaces
- Audio, brightness, and media OSDs
- Application launcher
- Notifications and quick settings
- Desktop widgets
- Settings and theme tools
- Lock and session surfaces
- Compatible-wallpaper metadata and tooling

## Install

Once the first release exists:

```sh
curl -fsSL https://raw.githubusercontent.com/Kurgan5kiy/dotted-dots/main/install.sh | sh
```

Piping remote code into a shell is convenient but requires trust. For an
inspect-first installation:

```sh
curl -fsSLO https://raw.githubusercontent.com/Kurgan5kiy/dotted-dots/main/install.sh
less install.sh
sh install.sh
```

The installer downloads the latest release archive, verifies its published
SHA-256 checksum, installs the version under the XDG data directory, and
updates a `current` symlink. It does not modify your Niri configuration.

## CLI preview

```text
dot-shell start
dot-shell stop
dot-shell restart
dot-shell status
dot-shell ipc show
dot-shell ipc call <target> <function> [args...]
dot-shell update
dot-shell version
```

## Development

Development is specification-driven with GitHub Spec Kit and Codex. Read
[AGENTS.md](AGENTS.md), [the product vision](docs/product-vision.md), and
[the development guide](docs/development.md) before starting.

```sh
specify init --here --force --integration codex --script sh
```

Feature work follows:

```text
$speckit-specify → $speckit-clarify → $speckit-plan → $speckit-checklist
→ $speckit-tasks → $speckit-analyze → $speckit-implement
→ $speckit-converge
```

## Contributing

Dot Shell uses trunk-based development. Short-lived `feature/*` and `fix/*`
branches are squash-merged into `main`. See [CONTRIBUTING.md](CONTRIBUTING.md)
for branch names, release fixes, and quality gates.

## License

GPL-3.0-only. See [LICENSE](LICENSE).
