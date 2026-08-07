import 'package:flutter_homely/core/logic/scenes.dart';
import 'package:flutter_homely/core/models/device.dart';
import 'package:flutter_homely/core/models/scene.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const devices = <Device>[
    Device(id: 'd1', roomId: 'r1', name: 'Lamp', type: DeviceType.light, isOn: false, brightness: 50),
    Device(id: 'd2', roomId: 'r1', name: 'Front Door', type: DeviceType.lock, isLocked: false),
    Device(
      id: 'd3',
      roomId: 'r2',
      name: 'Thermostat',
      type: DeviceType.thermostat,
      currentTemp: 70,
      setpoint: 68,
      mode: ThermostatMode.heat,
    ),
  ];

  const scene = Scene(
    id: 's1',
    name: 'Test Scene',
    description: 'Turns the lamp on bright and locks the front door.',
    icon: SceneIcon.morning,
    deviceStates: <SceneDeviceState>[
      SceneDeviceState(deviceId: 'd1', isOn: true, brightness: 80),
      SceneDeviceState(deviceId: 'd2', isLocked: true),
    ],
  );

  group('applyScene', () {
    test('overrides only the fields a scene specifies, on only the devices it references', () {
      final result = applyScene(scene, devices);
      expect(result.length, 3);

      final lamp = result.firstWhere((d) => d.id == 'd1');
      expect(lamp.isOn, isTrue);
      expect(lamp.brightness, 80);

      final lock = result.firstWhere((d) => d.id == 'd2');
      expect(lock.isLocked, isTrue);

      // d3 is not referenced by the scene at all - it must pass through
      // completely unchanged.
      final thermostat = result.firstWhere((d) => d.id == 'd3');
      expect(thermostat.setpoint, 68);
      expect(thermostat.mode, ThermostatMode.heat);
    });

    test('a device state referencing an unknown device id is silently ignored', () {
      const sceneWithUnknownDevice = Scene(
        id: 's2',
        name: 'Unknown target',
        description: '',
        icon: SceneIcon.away,
        deviceStates: <SceneDeviceState>[SceneDeviceState(deviceId: 'does-not-exist', isOn: true)],
      );

      final result = applyScene(sceneWithUnknownDevice, devices);
      expect(result.length, 3);
      expect(result.firstWhere((d) => d.id == 'd1').isOn, isFalse);
      expect(result.firstWhere((d) => d.id == 'd2').isLocked, isFalse);
    });

    test('an empty device-state list leaves every device unchanged', () {
      const emptyScene = Scene(id: 's3', name: 'No-op', description: '', icon: SceneIcon.movie, deviceStates: []);
      final result = applyScene(emptyScene, devices);
      expect(result.firstWhere((d) => d.id == 'd1').isOn, isFalse);
      expect(result.firstWhere((d) => d.id == 'd1').brightness, 50);
    });
  });

  group('isSceneActive', () {
    test('is true immediately after applying the scene', () {
      final activated = applyScene(scene, devices);
      expect(isSceneActive(scene, activated), isTrue);
    });

    test('is false before the scene has been applied', () {
      expect(isSceneActive(scene, devices), isFalse);
    });

    test('is false once a referenced device drifts away from the target state', () {
      final activated = applyScene(scene, devices);
      final drifted = <Device>[
        for (final device in activated) device.id == 'd1' ? device.copyWith(brightness: 50) : device,
      ];
      expect(isSceneActive(scene, drifted), isFalse);
    });

    test('is false when a referenced device is missing entirely', () {
      final activated = applyScene(scene, devices);
      final withoutLock = activated.where((d) => d.id != 'd2').toList();
      expect(isSceneActive(scene, withoutLock), isFalse);
    });

    test('a scene with no device states is trivially active', () {
      const emptyScene = Scene(id: 's3', name: 'No-op', description: '', icon: SceneIcon.movie, deviceStates: []);
      expect(isSceneActive(emptyScene, devices), isTrue);
    });
  });
}
