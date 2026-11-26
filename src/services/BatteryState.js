.pragma library

function snapshot(device, chargingState) {
    if (!device || !device.isPresent || !device.isLaptopBattery
            || typeof device.percentage !== "number" || !isFinite(device.percentage)
            || device.percentage < 0 || device.percentage > 1)
        return { available: false, percent: 0, charging: false };
    return { available: true, percent: Math.round(device.percentage * 100),
        charging: device.state === chargingState };
}
