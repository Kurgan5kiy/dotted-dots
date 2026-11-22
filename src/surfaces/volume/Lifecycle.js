.pragma library

function next(phase) {
    var phases = ["emerging", "tracing", "constructing", "interactive"];
    var index = phases.indexOf(phase);
    return index >= 0 && index < 3 ? phases[index + 1] : phase;
}
function delay(phase, timing, reduced) {
    if (reduced) return phase === "emerging" || phase === "retracting" ? 100 : 0;
    return ({ emerging: timing.emergeMs, tracing: timing.traceMs,
        constructing: timing.constructMs, retracting: timing.retractMs })[phase] || 0;
}
function edge(state, event) {
    if (event === "leave") return "armed";
    if (event === "enter" && state === "armed") return "dwelling";
    if (event === "elapsed" && state === "dwelling") return "latched";
    return state;
}
