import 'package:flutter_homely/core/logic/automation.dart';
import 'package:flutter_homely/core/models/automation_rule.dart';
import 'package:flutter_homely/core/models/device.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const devices = <Device>[
    Device(id: 'lock1', roomId: 'r1', name: 'Front Door', type: DeviceType.lock, isLocked: true),
    Device(id: 'light1', roomId: 'r1', name: 'Lamp', type: DeviceType.light, isOn: false, brightness: 40),
    Device(
      id: 'thermo1',
      roomId: 'r2',
      name: 'Bedroom Thermostat',
      type: DeviceType.thermostat,
      currentTemp: 75,
      setpoint: 70,
      mode: ThermostatMode.auto,
    ),
  ];

  final now = DateTime(2026, 8, 7, 20, 0);

  group('evaluateTrigger - device state', () {
    test('deviceIsOn is false for an off light, true once turned on', () {
      const trigger = AutomationTrigger(type: TriggerType.deviceIsOn, deviceId: 'light1');
      expect(evaluateTrigger(trigger, devices, now), isFalse);

      final lightOn = <Device>[
        for (final d in devices) d.id == 'light1' ? d.copyWith(isOn: true) : d,
      ];
      expect(evaluateTrigger(trigger, lightOn, now), isTrue);
    });

    test('deviceIsOff mirrors deviceIsOn', () {
      const trigger = AutomationTrigger(type: TriggerType.deviceIsOff, deviceId: 'light1');
      expect(evaluateTrigger(trigger, devices, now), isTrue);
    });

    test('deviceIsLocked / deviceIsUnlocked read the lock state', () {
      const lockedTrigger = AutomationTrigger(type: TriggerType.deviceIsLocked, deviceId: 'lock1');
      const unlockedTrigger = AutomationTrigger(type: TriggerType.deviceIsUnlocked, deviceId: 'lock1');
      expect(evaluateTrigger(lockedTrigger, devices, now), isTrue);
      expect(evaluateTrigger(unlockedTrigger, devices, now), isFalse);

      final unlocked = <Device>[
        for (final d in devices) d.id == 'lock1' ? d.copyWith(isLocked: false) : d,
      ];
      expect(evaluateTrigger(lockedTrigger, unlocked, now), isFalse);
      expect(evaluateTrigger(unlockedTrigger, unlocked, now), isTrue);
    });

    test('device-state triggers default to false for a missing device id', () {
      const trigger = AutomationTrigger(type: TriggerType.deviceIsOn, deviceId: 'missing');
      expect(evaluateTrigger(trigger, devices, now), isFalse);
      const offTrigger = AutomationTrigger(type: TriggerType.deviceIsOff, deviceId: 'missing');
      expect(evaluateTrigger(offTrigger, devices, now), isFalse);
    });
  });

  group('evaluateTrigger - time of day', () {
    const trigger = AutomationTrigger(type: TriggerType.timeAtOrAfter, timeOfDay: '22:30');

    test('exactly at the target time fires', () {
      expect(evaluateTrigger(trigger, devices, DateTime(2026, 8, 7, 22, 30)), isTrue);
    });

    test('one minute before does not fire', () {
      expect(evaluateTrigger(trigger, devices, DateTime(2026, 8, 7, 22, 29)), isFalse);
    });

    test('later the same night still fires', () {
      expect(evaluateTrigger(trigger, devices, DateTime(2026, 8, 7, 23, 0)), isTrue);
    });

    test('a missing or malformed time string never fires', () {
      const noTime = AutomationTrigger(type: TriggerType.timeAtOrAfter);
      const malformed = AutomationTrigger(type: TriggerType.timeAtOrAfter, timeOfDay: 'not-a-time');
      expect(evaluateTrigger(noTime, devices, now), isFalse);
      expect(evaluateTrigger(malformed, devices, now), isFalse);
    });
  });

  group('evaluateTrigger - thermostat threshold', () {
    test('thermostatAtOrAbove compares currentTemp to the threshold', () {
      const above = AutomationTrigger(type: TriggerType.thermostatAtOrAbove, deviceId: 'thermo1', threshold: 74);
      const notAbove = AutomationTrigger(type: TriggerType.thermostatAtOrAbove, deviceId: 'thermo1', threshold: 76);
      expect(evaluateTrigger(above, devices, now), isTrue); // 75 >= 74
      expect(evaluateTrigger(notAbove, devices, now), isFalse); // 75 >= 76 is false
    });

    test('thermostatAtOrBelow compares currentTemp to the threshold', () {
      const below = AutomationTrigger(type: TriggerType.thermostatAtOrBelow, deviceId: 'thermo1', threshold: 76);
      const notBelow = AutomationTrigger(type: TriggerType.thermostatAtOrBelow, deviceId: 'thermo1', threshold: 74);
      expect(evaluateTrigger(below, devices, now), isTrue); // 75 <= 76
      expect(evaluateTrigger(notBelow, devices, now), isFalse); // 75 <= 74 is false
    });

    test('a missing device or missing threshold never fires', () {
      const missingDevice = AutomationTrigger(type: TriggerType.thermostatAtOrAbove, deviceId: 'missing', threshold: 70);
      const missingThreshold = AutomationTrigger(type: TriggerType.thermostatAtOrAbove, deviceId: 'thermo1');
      expect(evaluateTrigger(missingDevice, devices, now), isFalse);
      expect(evaluateTrigger(missingThreshold, devices, now), isFalse);
    });
  });

  group('applyAction', () {
    test('turnOn / turnOff flip isOn on the target device only', () {
      const turnOn = AutomationAction(type: ActionType.turnOn, deviceId: 'light1');
      final result = applyAction(turnOn, devices);
      expect(result.firstWhere((d) => d.id == 'light1').isOn, isTrue);
      expect(result.firstWhere((d) => d.id == 'lock1').isLocked, isTrue); // untouched
    });

    test('lock / unlock flip isLocked', () {
      const unlock = AutomationAction(type: ActionType.unlock, deviceId: 'lock1');
      final result = applyAction(unlock, devices);
      expect(result.firstWhere((d) => d.id == 'lock1').isLocked, isFalse);
    });

    test('setBrightness updates brightness without touching isOn', () {
      const dim = AutomationAction(type: ActionType.setBrightness, deviceId: 'light1', brightness: 90);
      final result = applyAction(dim, devices);
      final light = result.firstWhere((d) => d.id == 'light1');
      expect(light.brightness, 90);
      expect(light.isOn, isFalse);
    });

    test('setSetpoint updates the thermostat target', () {
      const setTarget = AutomationAction(type: ActionType.setSetpoint, deviceId: 'thermo1', setpoint: 65);
      final result = applyAction(setTarget, devices);
      expect(result.firstWhere((d) => d.id == 'thermo1').setpoint, 65);
    });

    test('an action targeting an unknown device id changes nothing', () {
      const action = AutomationAction(type: ActionType.turnOn, deviceId: 'missing');
      final result = applyAction(action, devices);
      expect(result.length, devices.length);
      for (var i = 0; i < devices.length; i++) {
        expect(result[i].isOn, devices[i].isOn);
        expect(result[i].isLocked, devices[i].isLocked);
      }
    });
  });

  group('automationWouldFire / runAutomation', () {
    const automation = Automation(
      id: 'a1',
      name: 'Eco when locked',
      trigger: AutomationTrigger(type: TriggerType.deviceIsLocked, deviceId: 'lock1'),
      action: AutomationAction(type: ActionType.setSetpoint, deviceId: 'thermo1', setpoint: 62),
    );

    test('fires when enabled and the trigger holds, applying the action', () {
      expect(automationWouldFire(automation, devices, now), isTrue);
      final result = runAutomation(automation, devices, now);
      expect(result.firstWhere((d) => d.id == 'thermo1').setpoint, 62);
      // Everything else is untouched.
      expect(result.firstWhere((d) => d.id == 'light1').isOn, isFalse);
    });

    test('a disabled automation never fires, even if the trigger holds', () {
      final disabled = automation.copyWith(enabled: false);
      expect(automationWouldFire(disabled, devices, now), isFalse);
      final result = runAutomation(disabled, devices, now);
      expect(identical(result, devices), isTrue);
    });

    test('does not fire when the trigger does not hold', () {
      final unlocked = <Device>[
        for (final d in devices) d.id == 'lock1' ? d.copyWith(isLocked: false) : d,
      ];
      expect(automationWouldFire(automation, unlocked, now), isFalse);
      final result = runAutomation(automation, unlocked, now);
      expect(identical(result, unlocked), isTrue);
    });

    test('does not fire when the action targets a device that no longer exists', () {
      final withoutThermostat = devices.where((d) => d.id != 'thermo1').toList();
      expect(automationWouldFire(automation, withoutThermostat, now), isFalse);
    });
  });

  group('describeTrigger / describeAction', () {
    test('device-state triggers read naturally', () {
      const trigger = AutomationTrigger(type: TriggerType.deviceIsLocked, deviceId: 'lock1');
      expect(describeTrigger(trigger, devices), 'Front Door is locked');
    });

    test('time triggers read naturally', () {
      const trigger = AutomationTrigger(type: TriggerType.timeAtOrAfter, timeOfDay: '22:30');
      expect(describeTrigger(trigger, devices), 'Time reaches 22:30');
    });

    test('thermostat triggers include the device name and threshold', () {
      const trigger = AutomationTrigger(type: TriggerType.thermostatAtOrAbove, deviceId: 'thermo1', threshold: 74);
      expect(describeTrigger(trigger, devices), 'Bedroom Thermostat reaches 74°F or above');
    });

    test('actions read naturally', () {
      const setpointAction = AutomationAction(type: ActionType.setSetpoint, deviceId: 'thermo1', setpoint: 62);
      expect(describeAction(setpointAction, devices), 'Set Bedroom Thermostat to 62°F');

      const lockAction = AutomationAction(type: ActionType.lock, deviceId: 'lock1');
      expect(describeAction(lockAction, devices), 'Lock Front Door');
    });

    test('a missing device falls back to generic wording', () {
      const trigger = AutomationTrigger(type: TriggerType.deviceIsOn, deviceId: 'missing');
      expect(describeTrigger(trigger, devices), 'Device turns on');

      const action = AutomationAction(type: ActionType.turnOn, deviceId: 'missing');
      expect(describeAction(action, devices), 'Turn on device');
    });
  });
}
