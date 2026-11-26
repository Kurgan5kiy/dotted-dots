.pragma library

function action(rightButton, onlyMenu, hasMenu) {
    return hasMenu && (rightButton || onlyMenu) ? "menu" : "activate";
}
