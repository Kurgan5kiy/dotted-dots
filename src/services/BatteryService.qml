import QtQuick
import Quickshell.Services.UPower
import "BatteryState.js" as BatteryState

QtObject {
    readonly property var device: UPower.displayDevice
    readonly property var snapshot: BatteryState.snapshot(device, UPowerDeviceState.Charging)
    readonly property bool available: snapshot.available
    readonly property int percent: snapshot.percent
    readonly property bool charging: snapshot.charging
}
