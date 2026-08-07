import '../models/automation_rule.dart';
import '../models/device.dart';

/// Pure, UI-independent automation math: evaluating whether a trigger
/// currently holds against a device list (and clock time), and applying an
/// action to produce a new device list. Nothing here depends on Flutter.

Device? _findDevice(List<Device> devices, String? deviceId) {
  if (deviceId == null) return null;
  for (final device in devices) {
    if (device.id == deviceId) return device;
  }
  return null;
}

/// Whether [trigger] currently holds, given the live [devices] list and the
/// current [now].
bool evaluateTrigger(AutomationTrigger trigger, List<Device> devices, DateTime now) {
  switch (trigger.type) {
    case TriggerType.deviceIsOn:
      return _findDevice(devices, trigger.deviceId)?.isOn ?? false;
    case TriggerType.deviceIsOff:
      final device = _findDevice(devices, trigger.deviceId);
      return device != null && !device.isOn;
    case TriggerType.deviceIsLocked:
      return _findDevice(devices, trigger.deviceId)?.isLocked ?? false;
    case TriggerType.deviceIsUnlocked:
      final device = _findDevice(devices, trigger.deviceId);
      return device != null && !device.isLocked;
    case TriggerType.timeAtOrAfter:
      return _isAtOrAfter(trigger.timeOfDay, now);
    case TriggerType.thermostatAtOrAbove:
      final device = _findDevice(devices, trigger.deviceId);
      return device != null && trigger.threshold != null && device.currentTemp >= trigger.threshold!;
    case TriggerType.thermostatAtOrBelow:
      final device = _findDevice(devices, trigger.deviceId);
      return device != null && trigger.threshold != null && device.currentTemp <= trigger.threshold!;
  }
}

/// Parses a `'HH:mm'` string and checks whether [now]'s time-of-day is at
/// or after it. Returns `false` for a missing or malformed [timeOfDay]
/// rather than throwing, since this runs against seeded/editable data.
bool _isAtOrAfter(String? timeOfDay, DateTime now) {
  if (timeOfDay == null) return false;
  final parts = timeOfDay.split(':');
  if (parts.length != 2) return false;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return false;
  final targetMinutes = hour * 60 + minute;
  final nowMinutes = now.hour * 60 + now.minute;
  return nowMinutes >= targetMinutes;
}

/// Returns a new device list with [action] applied to the device it
/// targets; every other device passes through unchanged. A no-op if the
/// target device is not present in [devices].
List<Device> applyAction(AutomationAction action, List<Device> devices) {
  return <Device>[
    for (final device in devices) device.id == action.deviceId ? _applyToDevice(device, action) : device,
  ];
}

Device _applyToDevice(Device device, AutomationAction action) {
  switch (action.type) {
    case ActionType.turnOn:
      return device.copyWith(isOn: true);
    case ActionType.turnOff:
      return device.copyWith(isOn: false);
    case ActionType.lock:
      return device.copyWith(isLocked: true);
    case ActionType.unlock:
      return device.copyWith(isLocked: false);
    case ActionType.setBrightness:
      return device.copyWith(brightness: action.brightness ?? device.brightness);
    case ActionType.setSetpoint:
      return device.copyWith(setpoint: action.setpoint ?? device.setpoint);
  }
}

/// Whether running [automation] right now would actually change anything:
/// it must be [Automation.enabled], its trigger must currently hold, and
/// its action must target a device that exists in [devices].
bool automationWouldFire(Automation automation, List<Device> devices, DateTime now) {
  if (!automation.enabled) return false;
  if (!evaluateTrigger(automation.trigger, devices, now)) return false;
  return _findDevice(devices, automation.action.deviceId) != null;
}

/// Evaluates [automation] against [devices] and [now], applying its action
/// if [automationWouldFire]; otherwise returns [devices] unchanged.
List<Device> runAutomation(Automation automation, List<Device> devices, DateTime now) {
  if (!automationWouldFire(automation, devices, now)) return devices;
  return applyAction(automation.action, devices);
}

/// A short, human-readable description of [trigger], e.g. "Front Door Lock
/// is locked" or "Time reaches 22:30" - used by the Scenes & Automations
/// screen. Falls back to generic wording if the referenced device is
/// missing from [devices].
String describeTrigger(AutomationTrigger trigger, List<Device> devices) {
  final deviceName = _findDevice(devices, trigger.deviceId)?.name;
  switch (trigger.type) {
    case TriggerType.deviceIsOn:
      return '${deviceName ?? 'Device'} turns on';
    case TriggerType.deviceIsOff:
      return '${deviceName ?? 'Device'} turns off';
    case TriggerType.deviceIsLocked:
      return '${deviceName ?? 'Device'} is locked';
    case TriggerType.deviceIsUnlocked:
      return '${deviceName ?? 'Device'} is unlocked';
    case TriggerType.timeAtOrAfter:
      return 'Time reaches ${trigger.timeOfDay ?? '--:--'}';
    case TriggerType.thermostatAtOrAbove:
      return '${deviceName ?? 'Thermostat'} reaches ${trigger.threshold?.toStringAsFixed(0) ?? '--'}°F or above';
    case TriggerType.thermostatAtOrBelow:
      return '${deviceName ?? 'Thermostat'} drops to ${trigger.threshold?.toStringAsFixed(0) ?? '--'}°F or below';
  }
}

/// A short, human-readable description of [action], e.g. "Lock Front Door
/// Lock" or "Set Living Room Thermostat to 62°F".
String describeAction(AutomationAction action, List<Device> devices) {
  final deviceName = _findDevice(devices, action.deviceId)?.name ?? 'device';
  switch (action.type) {
    case ActionType.turnOn:
      return 'Turn on $deviceName';
    case ActionType.turnOff:
      return 'Turn off $deviceName';
    case ActionType.lock:
      return 'Lock $deviceName';
    case ActionType.unlock:
      return 'Unlock $deviceName';
    case ActionType.setBrightness:
      return 'Set $deviceName brightness to ${action.brightness ?? 0}%';
    case ActionType.setSetpoint:
      return 'Set $deviceName to ${action.setpoint?.toStringAsFixed(0) ?? '--'}°F';
  }
}
