# Bar UX Requirements Checklist: Configurable Dot Bar

**Purpose**: Review requirement quality for the four-edge configurable bar.
**Created**: 2026-11-24
**Feature**: [spec.md](../spec.md)
**Review Ownership**: Reviewer-owned. `[x]` means requirements quality was reviewed; it does not mean implementation passed.

## Completeness

- [ ] CHK001 Are all four orientations and both visibility modes specified independently? [Completeness, Spec §FR-001–002]
- [ ] CHK002 Are all five widgets' information and actions defined, including unavailable state? [Completeness, Spec §FR-003, §FR-005–006]
- [ ] CHK003 Are all-output and named-output selection, hotplug and disconnected names specified? [Completeness, Spec §FR-010]
- [ ] CHK004 Are configuration version, migration, invalid entries and file ownership defined consistently? [Completeness, Spec §FR-008]

## Clarity and consistency

- [ ] CHK005 Is the boundary between a soft feathered bar and a hard rectangular panel clear? [Clarity, Spec §FR-004]
- [ ] CHK006 Is shared-edge input ownership between bar and volume trigger unambiguous for every orientation and mode? [Consistency, Spec §FR-009–010]
- [ ] CHK007 Are overflow priority and keyboard access defined without silently hiding widgets? [Clarity, Spec §Edge Cases]
- [ ] CHK008 Are workspace scope and activation behavior explicit per output? [Clarity, Spec §US2]

## Acceptance and accessibility

- [ ] CHK009 Can readable text, stable targets and background evidence be objectively assessed? [Measurability, Spec §SC-001, §SC-004]
- [ ] CHK010 Are auto-hide delays, menu holds, focus behavior and reduced motion measurable? [Measurability, Spec §US3, §SC-003]
- [ ] CHK011 Are keyboard equivalents specified for workspace, volume, tray, overflow and reveal actions? [Coverage, Spec §FR-006–007]
- [ ] CHK012 Is physical two-output evidence explicitly distinguished from logical-scale tests? [Coverage, Spec §SC-005]

## Notes

- Leave markers unchecked until reviewer evaluation. `$speckit-implement` reads marker state and must not modify it.
