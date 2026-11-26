# Research: Configurable Dot Bar

## Output and input

**Decision**: One bar per selected connected output. Always-visible reserves space; auto-hide exposes a slim reveal strip. **Rationale**: Matches all-monitor default and isolates hotplug lifetime. **Alternative**: One global bar cannot show per-output workspaces; full-screen reveal input intercepts applications.

## Widgets and style

**Decision**: Five built-in widgets with configurable groups/order, existing volume action and reusable dot/feather primitives. **Rationale**: Bounded first slice with consistent style. **Alternative**: Arbitrary plugins require an unstable new public API.

## Overflow and shared edges

**Decision**: Compact accessible overflow menu; bar input owns its strip and volume sensing stays independently reachable. **Rationale**: Stable targets with exclusive input ownership. **Alternative**: Shrinking widgets until unreadable.

## Availability

**Decision**: Event-driven confirmed service state; hide battery widget when no battery exists. **Rationale**: Missing hardware should not disrupt other widgets. **Alternative**: Recurring CLI polling adds work.
