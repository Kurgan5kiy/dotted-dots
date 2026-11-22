import QtQuick

Item {
    id: root
    property real value: 0
    property bool available: true
    property bool reducedMotion: false
    property int duration: 180
    property real travel: 12
    property font numberFont: Qt.font({
        family: "cursive",
        pixelSize: 30
    })
    readonly property string targetText: available ? Math.round(value) + "%" : "—"
    property string displayedText: "—"
    property string outgoingText: ""
    property real previousValue: 0
    property real progress: 1
    property int direction: 1
    property bool initialized: false
    readonly property bool animating: transition.running
    implicitWidth: Math.max(incoming.implicitWidth, outgoing.implicitWidth) + 4
    implicitHeight: Math.max(incoming.implicitHeight, outgoing.implicitHeight) + 4
    clip: true
    Component.onCompleted: {
        displayedText = targetText;
        previousValue = value;
        initialized = true;
    }
    onTargetTextChanged: {
        if (!initialized || displayedText === targetText)
            return;
        transition.stop();
        outgoingText = displayedText;
        displayedText = targetText;
        direction = value >= previousValue ? 1 : -1;
        previousValue = value;
        if (reducedMotion || !available)
            progress = 1;
        else {
            progress = 0;
            transition.restart();
        }
    }
    NumberAnimation {
        id: transition
        target: root
        property: "progress"
        from: 0
        to: 1
        duration: root.duration
        easing.type: Easing.OutCubic
    }
    Text {
        id: outgoing
        text: root.outgoingText
        font: root.numberFont
        color: "white"
        x: (root.width - width) / 2
        y: 2 - root.direction * root.progress * root.travel
        opacity: 1 - root.progress
    }
    Text {
        id: incoming
        text: root.displayedText
        font: root.numberFont
        color: "white"
        x: (root.width - width) / 2
        y: 2 + root.direction * (1 - root.progress) * root.travel
        opacity: root.progress
    }
}
