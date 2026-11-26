.pragma library

function select(screens, name) {
    for (var i = 0; i < screens.length; i++)
        if (screens[i].name === name) return screens[i];
    return screens.length ? screens[0] : null;
}
function selectForInvocation(screens, requested, focusedName, fallbackName) {
    if (requested && contains(screens, requested)) return requested;
    for (var i = 0; i < screens.length; i++)
        if (screens[i].name === focusedName) return screens[i];
    for (var j = 0; j < screens.length; j++)
        if (screens[j].name === fallbackName) return screens[j];
    return screens.length ? screens[0] : null;
}
function keepOrSelect(screens, current, locked, requested, focusedName, fallbackName) {
    if (locked && contains(screens, current)) return current;
    return selectForInvocation(screens, requested, focusedName, fallbackName);
}
function contains(screens, current) { return screens.indexOf(current) !== -1; }
function geometry(screenWidth, screenHeight, field, margin, anchor) {
    var width = Math.min(field.width, screenWidth - margin * 2);
    var height = Math.min(field.height, screenHeight - margin * 2);
    if (width < 160 || height < 300 || Math.floor(height / field.spacing) < 12 || Math.floor(width / field.spacing) < 5)
        return {usable: false, width: 0, height: 0, x: 0, y: 0};
    var x = anchor === "left-center" ? margin : anchor === "right-center" ? screenWidth - width - margin : (screenWidth - width) / 2;
    var y = anchor === "top-center" ? margin : anchor === "bottom-center" ? screenHeight - height - margin : (screenHeight - height) / 2;
    return {usable: true, width: width, height: height, x: x, y: y};
}
