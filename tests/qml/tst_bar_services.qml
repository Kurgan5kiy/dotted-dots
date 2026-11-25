import QtQuick
import QtTest
import "../../src/services/BatteryState.js" as BatteryState
import "../../src/services/TrayState.js" as TrayState

TestCase {
    name: "BarServices"
    function test_batteryAvailabilityAndConfirmedState() {
        compare(BatteryState.snapshot(null, 1).available, false);
        compare(BatteryState.snapshot({
            isPresent: false,
            isLaptopBattery: true,
            percentage: 0.6
        }, 1).available, false);
        const observed = BatteryState.snapshot({
            isPresent: true,
            isLaptopBattery: true,
            percentage: 0.54,
            state: 1
        }, 1);
        compare(observed.available, true);
        compare(observed.percent, 54);
        compare(observed.charging, true);
        compare(BatteryState.snapshot({
            isPresent: true,
            isLaptopBattery: true,
            percentage: 1.2
        }, 1).available, false);
    }
    function test_trayActionRespectsSupportedMenu() {
        compare(TrayState.action(false, false, true), "activate");
        compare(TrayState.action(true, false, true), "menu");
        compare(TrayState.action(false, true, true), "menu");
        compare(TrayState.action(true, true, false), "activate");
    }
}
