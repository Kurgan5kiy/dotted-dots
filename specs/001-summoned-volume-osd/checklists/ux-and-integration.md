# UX and Integration Checklist: Summoned Volume OSD

**Purpose**: Review requirements quality before implementation.
**Created**: 2026-11-22
**Feature**: [spec.md](../spec.md)
**Review Ownership**: Reviewer-owned. An `[x]` means the requirement-quality criterion is satisfied, not that code is complete. Generated items remain unchecked.

## Completeness and clarity

- [ ] CHK001 Are all summon sources and their enabled/disabled conditions defined consistently? [Completeness, Spec FR-001, FR-017–019]
- [ ] CHK002 Are opaque-center and feathered-boundary requirements compatible across governing documents? [Consistency, Spec FR-003, Constitution I]
- [ ] CHK003 Are hover, drag, idle and edge-rearm transitions unambiguous? [Clarity, Spec FR-007–008, FR-017]
- [ ] CHK004 Are mute's colour and non-colour distinctions specified? [Clarity, Spec FR-002]
- [ ] CHK005 Are configurable defaults, limits and invalid-value handling defined? [Completeness, Spec FR-011, contracts/configuration.md]
- [ ] CHK006 Are focus preservation and unbound-by-default keyboard invocation documented? [Coverage, Spec FR-006, FR-018]

## Integration and failure coverage

- [ ] CHK007 Are request acceptance, confirmation and failure distinguished in audio actions? [Clarity, Spec FR-013, FR-019, contracts/actions.md]
- [ ] CHK008 Is behavior for audio state above the configured adjustment limit defined? [Gap, Spec FR-001–002]
- [ ] CHK009 Are sensor input ownership and adjacent-display crossing tradeoffs explicit? [Coverage, Plan Input design]
- [ ] CHK010 Are output loss, unavailable audio, no outputs and recovery addressed? [Coverage, Spec Edge Cases]
- [ ] CHK011 Are repeated commands, external changes and sink switches during pending writes covered? [Coverage, contracts/actions.md]
- [ ] CHK012 Are compositor-binding installation boundaries explicit? [Consistency, Spec Assumptions, Constitution Safety]

## Acceptance quality

- [ ] CHK013 Are latency targets defined separately for automatic and binding-driven summoning? [Gap, Spec SC-002]
- [ ] CHK014 Are readability criteria more precise than subjective visual approval? [Measurability, Spec SC-004]
- [ ] CHK015 Are reduced-motion, scale-factor and multi-output evidence requirements defined? [Coverage, Spec SC-005–007]
- [ ] CHK016 Are governance review and live feasibility prerequisites recorded without implying completion? [Consistency, Plan Constitution Check]

## Notes

Standard-depth review focused on interaction and integration. `$speckit-implement` reads checklist state as a gate and does not change its markers. Unchecked items require reviewer evaluation; they are not automatically failed requirements.
