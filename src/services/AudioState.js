.pragma library

function request(kind, value, snapshot, pending, step, cap) {
    if (!snapshot.available) return { status: "rejected", error: "unavailable" };
    var percent = pending && pending.percent !== null ? pending.percent : snapshot.percent;
    var muted = pending && pending.muted !== null ? pending.muted : snapshot.muted;
    if (kind === "toggleMute") return {status: "accepted", percent: null, muted: !muted};
    if (kind === "increase" && percent >= cap) return {status: "accepted", noop: true};
    if (kind === "setPercent" && (typeof value !== "number" || !isFinite(value)
        || Math.floor(value) !== value || value < 0 || value > cap))
        return {status: "rejected", error: "invalid_argument"};
    var target = kind === "increase" ? Math.min(cap, percent + step)
        : kind === "decrease" ? Math.max(0, Math.min(cap, percent - step)) : value;
    return {status: "accepted", percent: target, muted: null};
}
function confirmed(snapshot, pending) {
    return snapshot.available && pending && snapshot.sinkId === pending.sinkId
        && (pending.percent === null || Math.abs(snapshot.percent - pending.percent) <= 0.5)
        && (pending.muted === null || snapshot.muted === pending.muted);
}
function changed(previous, current) {
    return previous.available && current.available && previous.sinkId === current.sinkId
        && (previous.percent !== current.percent || previous.muted !== current.muted);
}
