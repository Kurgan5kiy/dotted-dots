.pragma library

function shouldFlash(workspaceId, activatedId, activatedAtMs, nowMs) {
    const elapsed = nowMs - activatedAtMs;
    return workspaceId === activatedId && elapsed >= 0 && elapsed < 900;
}
