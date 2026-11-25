.pragma library

function defaults() {
    return {
        schemaVersion: 3,
        bar: { edge: "top", visibility: "always", outputs: "all", thickness: 48, revealMs: 100, hideMs: 500,
            widgets: [
                { type: "workspaces", group: "start", enabled: true, priority: 100 },
                { type: "clock", group: "center", enabled: true, priority: 80 },
                { type: "volume", group: "end", enabled: true, priority: 70 },
                { type: "battery", group: "end", enabled: true, priority: 60 },
                { type: "tray", group: "end", enabled: true, priority: 50 }
            ] },
        field: { width: 180, height: 540, spacing: 18, dotRadius: 1.5, lineWidth: 2, feather: 96,
            backdropOpacity: 1, backdropColor: "#181818" },
        placement: { fallbackOutput: "", margin: 0 },
        edge: { enabled: true, dwellMs: 100, width: 1, side: "right", outputs: ({}) },
        motion: { reduced: false, liquidStrength: 1, liquidMs: 6000,
            followRange: 36, followMs: 120, departureDrift: 32, departureScale: 0.3 },
        timing: { emergeMs: 400, retractMs: 650, levelMs: 180, numberMs: 180, idleMs: 2000 },
        volume: { stepPercent: 5, maxPercent: 100 },
        triggers: { externalAudioChanges: true },
        typography: { family: "Allura", pixelSize: 30, weight: 300, italic: false, travel: 12 }
    };
}

function object(value) { return value !== null && typeof value === "object" && !Array.isArray(value); }
function number(value, min, max, integer) {
    return typeof value === "number" && isFinite(value) && value >= min && value <= max
        && (!integer || Math.floor(value) === value);
}
function outputName(value) { return typeof value === "string" && value.length > 0 && value.length <= 128; }
function copy(value) { return JSON.parse(JSON.stringify(value)); }

function migrateV1(input, warnings) {
    var migrated = copy(input);
    migrated.schemaVersion = 3;
    var oldPlacement = object(input.placement) ? input.placement : ({});
    migrated.placement = {
        fallbackOutput: typeof oldPlacement.output === "string" ? oldPlacement.output : ""
    };
    if (oldPlacement.margin !== undefined)
        migrated.placement.margin = oldPlacement.margin;
    migrated.edge = object(input.edge) ? copy(input.edge) : ({});
    var anchor = oldPlacement.anchor;
    migrated.edge.side = anchor === "left-center" ? "left" : "right";
    migrated.edge.outputs = ({});
    warnings.push("Migrated schemaVersion 1 configuration in memory; the user file was not changed");
    if (anchor && ["left-center", "right-center"].indexOf(anchor) === -1)
        warnings.push("SchemaVersion 1 placement.anchor has no volume-slot equivalent; using right edge");
    return migrated;
}

function validateProfiles(input, fallback, warnings) {
    var accepted = ({});
    if (!object(input)) {
        warnings.push("Invalid configuration field: edge.outputs");
        return accepted;
    }
    var names = Object.keys(input);
    if (names.length > 32) {
        warnings.push("Too many edge.outputs profiles; ignoring profiles after the first 32");
        names = names.slice(0, 32);
    }
    names.forEach(function(name) {
        var profile = input[name];
        if (!outputName(name) || !object(profile)) {
            warnings.push("Invalid edge output profile: " + name);
            return;
        }
        var keys = Object.keys(profile);
        if (keys.length === 1 && keys[0] === "side" && ["left", "right"].indexOf(profile.side) !== -1) {
            accepted[name] = { side: profile.side };
            return;
        }
        if (keys.length === 2 && keys.indexOf("copyOf") !== -1 && keys.indexOf("mirror") !== -1
                && outputName(profile.copyOf) && profile.copyOf !== name && typeof profile.mirror === "boolean") {
            accepted[name] = { copyOf: profile.copyOf, mirror: profile.mirror };
            return;
        }
        warnings.push("Invalid edge output profile: " + name);
    });
    Object.keys(accepted).forEach(function(name) {
        var profile = accepted[name];
        if (profile.copyOf !== undefined) {
            var source = accepted[profile.copyOf];
            if (!source || source.side === undefined) {
                delete accepted[name];
                warnings.push("Unresolved edge output profile: " + name + "; using " + fallback);
            }
        }
    });
    return accepted;
}

function validate(input) {
    var result = defaults();
    var warnings = [];
    if (!object(input))
        return { values: result, warnings: ["Invalid configuration; using defaults"] };
    if (input.schemaVersion === 1)
        input = migrateV1(input, warnings);
    else if (input.schemaVersion === 2) {
        input = copy(input);
        input.schemaVersion = 3;
        warnings.push("Migrated schemaVersion 2 configuration in memory; the user file was not changed");
    } else if (input.schemaVersion !== 3)
        return { values: result, warnings: ["Invalid configuration or unsupported schemaVersion; using defaults"] };
    var limits = {
        "field.width": [160, 800], "field.height": [300, 600], "field.spacing": [8, 48],
        "field.dotRadius": [0.5, 4], "field.lineWidth": [0.5, 4], "field.feather": [16, 120], "field.backdropOpacity": [0, 1],
        "placement.margin": [0, 128], "edge.dwellMs": [50, 1000, true], "edge.width": [1, 4],
        "timing.emergeMs": [0, 1000, true], "timing.retractMs": [0, 1000, true],
        "timing.idleMs": [250, 10000, true], "volume.stepPercent": [1, 25, true],
        "volume.maxPercent": [1, 100, true], "timing.levelMs": [0, 1000, true], "timing.numberMs": [0, 1000, true],
        "motion.liquidStrength": [0, 2], "motion.liquidMs": [1000, 10000, true], "typography.travel": [0, 32],
        "motion.followRange": [0, 48], "motion.followMs": [0, 500, true],
        "motion.departureDrift": [0, 64], "motion.departureScale": [0.1, 1],
        "typography.pixelSize": [14, 40], "typography.weight": [100, 500, true]
    };
    Object.keys(input).forEach(function(group) {
        if (!Object.prototype.hasOwnProperty.call(result, group)) {
            warnings.push("Unknown configuration field: " + group);
            return;
        }
        if (group === "schemaVersion") return;
        if (!object(input[group])) { warnings.push("Invalid configuration group: " + group); return; }
        if (group === "bar") {
            var bar = input.bar;
            Object.keys(bar).forEach(function(key) {
                if (!Object.prototype.hasOwnProperty.call(result.bar, key))
                    warnings.push("Unknown configuration field: bar." + key);
            });
            if (["top", "left", "bottom", "right"].indexOf(bar.edge) !== -1) result.bar.edge = bar.edge;
            else if (bar.edge !== undefined) warnings.push("Invalid configuration field: bar.edge");
            if (["always", "auto"].indexOf(bar.visibility) !== -1) result.bar.visibility = bar.visibility;
            else if (bar.visibility !== undefined) warnings.push("Invalid configuration field: bar.visibility");
            if (bar.outputs === "all" || (Array.isArray(bar.outputs) && bar.outputs.length > 0 && bar.outputs.length <= 32
                    && bar.outputs.every(outputName) && new Set(bar.outputs).size === bar.outputs.length)) result.bar.outputs = bar.outputs;
            else if (bar.outputs !== undefined) warnings.push("Invalid configuration field: bar.outputs");
            [["thickness", 32, 96], ["revealMs", 50, 500], ["hideMs", 100, 3000]].forEach(function(rule) {
                if (bar[rule[0]] !== undefined) {
                    if (number(bar[rule[0]], rule[1], rule[2], true)) result.bar[rule[0]] = bar[rule[0]];
                    else warnings.push("Invalid configuration field: bar." + rule[0]);
                }
            });
            if (bar.widgets !== undefined) {
                if (!Array.isArray(bar.widgets)) warnings.push("Invalid configuration field: bar.widgets");
                else {
                    var seen = ({});
                    result.bar.widgets = bar.widgets.filter(function(entry) {
                        var valid = object(entry) && ["workspaces", "clock", "volume", "battery", "tray"].indexOf(entry.type) !== -1
                            && ["start", "center", "end"].indexOf(entry.group) !== -1
                            && typeof entry.enabled === "boolean" && number(entry.priority, 0, 100, true) && !seen[entry.type];
                        if (valid) seen[entry.type] = true;
                        else warnings.push("Invalid or duplicate bar widget entry");
                        return valid;
                    });
                }
            }
            return;
        }
        Object.keys(input[group]).forEach(function(key) {
            var path = group + "." + key;
            if (!Object.prototype.hasOwnProperty.call(result[group], key)) {
                warnings.push("Unknown configuration field: " + path); return;
            }
            var value = input[group][key];
            var valid;
            if (path === "edge.outputs") return;
            if (limits[path]) {
                var range = limits[path];
                valid = number(value, range[0], range[1], range[2]);
            } else if (path === "edge.side") {
                valid = ["left", "right"].indexOf(value) !== -1;
            } else if (path === "placement.fallbackOutput") {
                valid = typeof value === "string" && value.length <= 128;
            } else if (path === "field.backdropColor") {
                valid = typeof value === "string" && /^#[0-9a-fA-F]{6}$/.test(value);
            } else valid = typeof value === typeof result[group][key];
            if (valid) result[group][key] = value;
            else warnings.push("Invalid configuration field: " + path);
        });
    });
    if (input.edge && Object.prototype.hasOwnProperty.call(input.edge, "outputs"))
        result.edge.outputs = validateProfiles(input.edge.outputs, result.edge.side, warnings);
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
