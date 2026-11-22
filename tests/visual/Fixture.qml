pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
    id: root
    property int variant: 0
    color: variant === 0 ? "#ffffff" : variant === 1 ? "#080808" : variant === 2 ? "#b548c7" : "#fafafa"
    Repeater {
        model: root.variant >= 2 ? 96 : 0
        Rectangle {
            required property int index
            x: (index % 8) * root.width / 8
            y: Math.floor(index / 8) * root.height / 12
            width: root.width / 8
            height: root.height / 12
            color: root.variant === 3 ? (index % 2 ? "#000000" : "#ffffff") : ["#f0a020", "#2040e0", "#e03070", "#30c0a0"][index % 4]
        }
    }
}
