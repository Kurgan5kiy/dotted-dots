.pragma library

function next(phase) {
    return phase === "emerging" ? "interactive" : phase;
}
function delay(phase, timing, reduced) {
    if (reduced) return phase === "emerging" || phase === "retracting" ? 100 : 0;
    return ({ emerging: timing.emergeMs, retracting: timing.retractMs })[phase] || 0;
}
function edge(state, event) {
    if (event === "leave") return "armed";
    if (event === "enter" && state === "armed") return "dwelling";
    if (event === "elapsed" && state === "dwelling") return "latched";
    return state;
}
