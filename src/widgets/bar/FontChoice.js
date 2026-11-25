.pragma library

function choose(families) {
    return Array.isArray(families) && families.indexOf("FiraCode Nerd Font Mono") !== -1
        ? "FiraCode Nerd Font Mono" : "monospace";
}
