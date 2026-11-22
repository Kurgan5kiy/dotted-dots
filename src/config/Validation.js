.pragma library

function defaults() {
    return {
        schemaVersion: 1,
        field: { width: 180, height: 540, spacing: 18, dotRadius: 1.5, feather: 96,
            backdropOpacity: 1, backdropColor: "#181818" },
        placement: { anchor: "right-center", output: "", margin: 0 },
        edge: { enabled: true, dwellMs: 200, width: 1 },
        motion: { reduced: false },
        timing: { emergeMs: 650, traceMs: 350, constructMs: 100, retractMs: 250, levelMs: 180, idleMs: 2000 },
        volume: { stepPercent: 5, maxPercent: 100 },
        triggers: { externalAudioChanges: true },
        typography: { family: "FiraCode Nerd Font", pixelSize: 22, weight: 300, italic: false }
    };
}

function object(value) { return value !== null && typeof value === "object" && !Array.isArray(value); }
function number(value, min, max, integer) {
    return typeof value === "number" && isFinite(value) && value >= min && value <= max
        && (!integer || Math.floor(value) === value);
}

function validate(input) {
    var result = defaults();
    var warnings = [];
    if (!object(input) || input.schemaVersion !== 1)
        return { values: result, warnings: ["Invalid configuration or unsupported schemaVersion; using defaults"] };
    var limits = {
        "field.width": [160, 800], "field.height": [300, 600], "field.spacing": [8, 48],
        "field.dotRadius": [0.5, 4], "field.feather": [16, 120], "field.backdropOpacity": [0, 1],
        "placement.margin": [0, 128], "edge.dwellMs": [50, 1000, true], "edge.width": [1, 4],
        "timing.emergeMs": [0, 1000, true], "timing.traceMs": [0, 1000, true],
        "timing.constructMs": [0, 1000, true], "timing.retractMs": [0, 1000, true],
        "timing.idleMs": [250, 10000, true], "volume.stepPercent": [1, 25, true],
        "volume.maxPercent": [1, 100, true], "timing.levelMs": [0, 1000, true],
        "typography.pixelSize": [14, 32], "typography.weight": [100, 500, true]
    };
    Object.keys(input).forEach(function(group) {
        if (!Object.prototype.hasOwnProperty.call(result, group)) {
            warnings.push("Unknown configuration field: " + group);
            return;
        }
        if (group === "schemaVersion") return;
        if (!object(input[group])) { warnings.push("Invalid configuration group: " + group); return; }
        Object.keys(input[group]).forEach(function(key) {
            var path = group + "." + key;
            if (!Object.prototype.hasOwnProperty.call(result[group], key)) {
                warnings.push("Unknown configuration field: " + path); return;
            }
            var value = input[group][key];
            var valid;
            if (limits[path]) {
                var range = limits[path];
                valid = number(value, range[0], range[1], range[2]);
            } else if (path === "placement.anchor") {
                valid = ["right-center", "left-center", "top-center", "bottom-center", "center"].indexOf(value) !== -1;
            } else if (path === "field.backdropColor") {
                valid = typeof value === "string" && /^#[0-9a-fA-F]{6}$/.test(value);
            } else valid = typeof value === typeof result[group][key];
            if (valid) result[group][key] = value;
            else warnings.push("Invalid configuration field: " + path);
        });
    });
    var f = result.field;
    if (f.dotRadius * 2 >= f.spacing || f.feather >= Math.min(f.width, f.height / 2)
            || Math.floor(f.width / f.spacing) < 5 || Math.floor(f.height / f.spacing) < 12
            || Math.ceil(f.width / f.spacing) * Math.ceil(f.height / f.spacing) > 2048) {
        result.field = defaults().field;
        warnings.push("Incompatible field geometry; using field defaults");
    }
    return { values: result, warnings: warnings };
}

function parse(text) {
    try { return validate(JSON.parse(text)); }
    catch (error) { return { values: defaults(), warnings: ["Malformed configuration; using defaults"] }; }
}
