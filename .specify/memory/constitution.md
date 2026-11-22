<!--
Sync Impact Report
- Version: initial → 1.0.0
- Established principles:
  - Original Wallpaper-First Identity
  - Accessible, Stable Interaction
  - Modular Quickshell Architecture
  - Measured Visual Performance
  - Spec-Driven Vertical Slices
  - Verifiable Delivery and Release Discipline
- Templates requiring later Spec Kit initialization: pending managed scaffold
-->

# Dot Shell Constitution

## Core Principles

### I. Original Wallpaper-First Identity

Dot Shell MUST preserve the wallpaper as the primary visual surface and MUST
implement both first-class interaction concepts defined in the product vision:

1. a borderless summoned field whose dot opacity feathers continuously to zero;
2. an embedded field aligned with dots in a compatible wallpaper.

The project MUST NOT copy the layout, interaction model, or functionality of
eDEX-UI, Caelestia, or another shell. Inspiration MAY guide atmosphere, motion,
or perceived responsiveness, but product behavior and visual composition MUST
remain original. A conventional translucent rectangle MUST NOT substitute for
the summoned dot field.

Rationale: the latent dot field is the product's identity, not a decorative
theme that can drift into an ordinary panel system.

### II. Accessible, Stable Interaction

Every user-facing action MUST be keyboard accessible and MUST have predictable
focus and dismissal behavior. Interactive targets MUST stop moving before they
accept input. Major transitions MUST provide reduced-motion behavior. Text and
controls MUST remain readable over bright, dark, colorful, and detailed
wallpapers without unnecessarily obscuring the wallpaper.

Plans for visual features MUST cover normal, hover/focus, active, dismissal,
and failure states. Multi-output placement and scale factors MUST be addressed
when a feature can appear on more than one output.

Rationale: motion should explain the interface, never make it inaccessible or
unstable.

### III. Modular Quickshell Architecture

System services, Niri integration, IPC, configuration, visual primitives,
animation state, and product surfaces MUST have explicit boundaries. Niri-
specific behavior SHOULD remain behind adapters. Visual primitives SHOULD be
reusable without importing platform service details.

QML and Quickshell MUST be preferred. Native C++ or a new runtime dependency
requires a documented need, rejected simpler alternatives, lifecycle and
packaging impact, and approval in the feature plan. Public configuration and
IPC contracts MUST be documented and versioned when compatibility changes.

Rationale: a complete shell will grow quickly; boundaries keep it extensible
without turning early prototypes into permanent coupling.

### IV. Measured Visual Performance

Animations MUST avoid unbounded work, unnecessary polling, and avoidable full-
screen redraws. Expensive surfaces SHOULD load only while needed. Each visual
feature plan MUST define measurable or observable performance acceptance
criteria appropriate to its scope and MUST state its lower-cost or reduced-
motion behavior.

Performance claims MUST be supported by profiling, frame observations, or a
reproducible test on the stated hardware. Unmeasured claims MUST be labeled as
assumptions.

Rationale: the shell's visual identity depends on motion feeling immediate and
quiet, not merely looking complex in a still image.

### V. Spec-Driven Vertical Slices

Substantial product work MUST begin with one bounded user outcome and reviewed
Spec Kit artifacts. The production path is specification, clarification,
technical plan, requirements checklist, tasks, consistency analysis,
implementation, and convergence.

Specifications MUST describe what and why before selecting implementation
details. Plans MUST resolve architecture, dependencies, testing, packaging, and
constitution checks. Tasks MUST be small enough to verify. Implementation MUST
not silently expand into adjacent shell surfaces. Discovered ambiguity or
conflict MUST return to the appropriate artifact instead of being resolved by
unrecorded invention in code.

Rationale: vertical slices produce usable evidence early and keep a large shell
from becoming an infrastructure-only project.

### VI. Verifiable Delivery and Release Discipline

Non-visual logic MUST have automated tests. Animation and adaptive-wallpaper
work MUST include reproducible visual verification across representative
wallpapers. Work MUST report exactly what was tested and disclose unverified
hardware-, Niri-, scale-, output-, or GPU-dependent behavior.

Feature and fix branches MUST be short-lived and squash-merged into `main`.
Release changes MUST land in `main` first, then be cherry-picked to the active
`release/YYYY.N` branch. Published `main`, release branches, and tags MUST NOT
be rewritten. Release artifacts MUST be checksummed, and the installer MUST
verify the checksum before activating a version.

Rationale: honest evidence and an auditable release path matter especially for
a shell that manages persistent user interaction and eventually locking.

## Product and Safety Constraints

- Initial platform scope is Linux, Wayland, Niri, Quickshell, Qt 6, and QML.
- The CLI and installer MUST NOT edit Niri configuration automatically.
- Private or license-unclear reference artwork MUST NOT be committed.
- Secrets, tokens, private logs, and personal wallpaper content MUST NOT enter
  specifications, fixtures, screenshots, or release artifacts.
- Lock-screen work MUST be specified and reviewed as security-sensitive work,
  separate from ordinary decorative surfaces.
- Destructive configuration migrations MUST provide backup, failure, and
  recovery behavior before implementation.

## Development Workflow and Quality Gates

For each production feature:

1. Establish a bounded specification with explicit non-goals.
2. Clarify material ambiguity before committing to architecture.
3. Produce a plan that evaluates every constitutional principle.
4. Generate a requirements-quality checklist and actionable tasks.
5. Analyze cross-artifact consistency; CRITICAL findings block implementation.
6. Implement only approved tasks with proportionate tests and evidence.
7. Run convergence until the implementation is reported as `Converged` or the
   remaining work is explicitly returned to the task list.

Pull requests MUST link their governing artifacts, pass repository checks,
include visual evidence when UI changes, and identify release-branch impact.
Any constitutional exception MUST be explicit in the plan's complexity or
exception section, narrow in scope, and approved before implementation.

## Governance

This constitution supersedes ad-hoc repository conventions when they conflict.
`AGENTS.md` translates it into agent working instructions but cannot weaken it.
Feature specifications and plans MUST include a constitution check.

Amendments require a pull request explaining the reason and impact, updating
dependent documentation where necessary, and changing this document's version:

- MAJOR: removal or incompatible redefinition of a binding principle;
- MINOR: a new principle or materially expanded governance requirement;
- PATCH: clarification without semantic change.

Compliance is reviewed during planning, artifact analysis, pull-request review,
and convergence. Violations are resolved by changing the spec, plan, tasks, or
implementation—not by silently weakening the constitution.

**Version**: 1.0.0 | **Ratified**: 2026-11-22 | **Last Amended**: 2026-11-22
