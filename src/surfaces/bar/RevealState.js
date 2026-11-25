.pragma library

function initial(automatic) { return automatic ? "hidden" : "visible"; }
function enter(phase) {
    return phase === "hidden" ? "revealing" : "visible";
}
function elapsed(phase) { return phase === "revealing" ? "visible" : phase; }
function hold(phase) { return "visible"; }
function release(phase) {
    if (phase === "revealing") return "hidden";
    if (phase === "visible") return "hiding";
    return phase;
}
function dismiss(phase, held) { return held ? "visible" : "hidden"; }
function shown(phase) { return phase === "visible" || phase === "hiding"; }
