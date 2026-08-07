import 'package:flutter_homely/core/logic/automation.dart';
import 'package:flutter_homely/core/logic/energy.dart';
import 'package:flutter_homely/core/logic/scenes.dart';
import 'package:flutter_homely/core/models/device.dart';
import 'package:flutter_homely/data/seed_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('seedRooms', () {
    test('seeds exactly the 4 documented rooms with stable ids', () {
      final rooms = seedRooms();
      expect(rooms.length, 4);
      expect(
        rooms.map((r) => r.id).toList(),
        <String>[RoomIds.livingRoom, RoomIds.bedroom, RoomIds.kitchen, RoomIds.entryway],
      );
    });
  });

  group('seedDevices', () {
    test('seeds exactly 12 devices, each with a unique id', () {
      final devices = seedDevices();
      expect(devices.length, 12);
      expect(devices.map((d) => d.id).toSet().length, 12);
    });

    test('every device belongs to one of the 4 seeded rooms', () {
      final roomIds = seedRooms().map((r) => r.id).toSet();
      for (final device in seedDevices()) {
        expect(roomIds.contains(device.roomId), isTrue, reason: '${device.id} has an unknown roomId');
      }
    });

    test('device types break down as 5 lights, 2 thermostats, 2 locks, 3 plugs', () {
      final devices = seedDevices();
      final byType = <DeviceType, int>{};
      for (final device in devices) {
        byType[device.type] = (byType[device.type] ?? 0) + 1;
      }
      expect(byType[DeviceType.light], 5);
      expect(byType[DeviceType.thermostat], 2);
      expect(byType[DeviceType.lock], 2);
      expect(byType[DeviceType.plug], 3);
    });

    test('both entryway locks start locked, matching a secure first-run default', () {
      final devices = seedDevices();
      expect(devices.firstWhere((d) => d.id == DeviceIds.entrywayFrontDoorLock).isLocked, isTrue);
      expect(devices.firstWhere((d) => d.id == DeviceIds.entrywayBackDoorLock).isLocked, isTrue);
    });
  });

  group('seedScenes', () {
    test('seeds exactly 3 scenes with the documented ids', () {
      final ids = seedScenes().map((s) => s.id).toList();
      expect(ids, <String>['scene-good-morning', 'scene-movie-night', 'scene-away']);
    });

    test('every scene only references real seeded device ids', () {
      final deviceIds = seedDevices().map((d) => d.id).toSet();
      for (final scene in seedScenes()) {
        for (final state in scene.deviceStates) {
          expect(deviceIds.contains(state.deviceId), isTrue, reason: '${scene.id} references unknown ${state.deviceId}');
        }
      }
    });

    test('Away Mode locks both doors, kills the interior lights, and leaves the porch light on low', () {
      final devices = seedDevices();
      final awayScene = seedScenes().firstWhere((s) => s.id == 'scene-away');
      final result = applyScene(awayScene, devices);
      final byId = <String, Device>{for (final d in result) d.id: d};

      expect(byId[DeviceIds.entrywayFrontDoorLock]!.isLocked, isTrue);
      expect(byId[DeviceIds.entrywayBackDoorLock]!.isLocked, isTrue);
      expect(byId[DeviceIds.livingRoomCeilingLights]!.isOn, isFalse);
      expect(byId[DeviceIds.kitchenCeilingLights]!.isOn, isFalse);
      expect(byId[DeviceIds.entrywayPorchLight]!.isOn, isTrue);
      expect(byId[DeviceIds.entrywayPorchLight]!.brightness, 40);
      expect(byId[DeviceIds.livingRoomThermostat]!.setpoint, 62);
      expect(byId[DeviceIds.bedroomThermostat]!.setpoint, 60);

      // Applying it lands the scene in the "active" state.
      expect(isSceneActive(awayScene, result), isTrue);
    });
  });

  group('seedAutomations', () {
    test('seeds exactly 2 automations, one enabled and one disabled by default', () {
      final automations = seedAutomations();
      expect(automations.length, 2);
      expect(automations.firstWhere((a) => a.id == 'auto-lock-up').enabled, isTrue);
      expect(automations.firstWhere((a) => a.id == 'auto-eco-when-locked').enabled, isFalse);
    });

    test('Lock Up at Night locks the front door once enabled and past 22:30', () {
      final devices = seedDevices();
      final unlockedFrontDoor = <Device>[
        for (final d in devices) d.id == DeviceIds.entrywayFrontDoorLock ? d.copyWith(isLocked: false) : d,
      ];
      final automation = seedAutomations().firstWhere((a) => a.id == 'auto-lock-up');

      final tooEarly = runAutomation(automation, unlockedFrontDoor, DateTime(2026, 8, 7, 20, 0));
      expect(tooEarly.firstWhere((d) => d.id == DeviceIds.entrywayFrontDoorLock).isLocked, isFalse);

      final afterHours = runAutomation(automation, unlockedFrontDoor, DateTime(2026, 8, 7, 23, 0));
      expect(afterHours.firstWhere((d) => d.id == DeviceIds.entrywayFrontDoorLock).isLocked, isTrue);
    });

    test('Eco Mode When Locked Up is seeded disabled, so it never fires even though its trigger already holds', () {
      final devices = seedDevices(); // both doors start locked
      final automation = seedAutomations().firstWhere((a) => a.id == 'auto-eco-when-locked');

      expect(automationWouldFire(automation, devices, DateTime(2026, 8, 7, 12, 0)), isFalse);
      final result = runAutomation(automation, devices, DateTime(2026, 8, 7, 12, 0));
      expect(identical(result, devices), isTrue);

      // Enabling it flips the outcome, since the front door is already locked.
      final enabled = automation.copyWith(enabled: true);
      expect(automationWouldFire(enabled, devices, DateTime(2026, 8, 7, 12, 0)), isTrue);
      final firedResult = runAutomation(enabled, devices, DateTime(2026, 8, 7, 12, 0));
      expect(firedResult.firstWhere((d) => d.id == DeviceIds.livingRoomThermostat).setpoint, 62);
    });
  });

  group('seedEnergySamples', () {
    final referenceNow = DateTime(2026, 8, 7);

    test('produces 7 days x 4 rooms = 28 samples', () {
      expect(seedEnergySamples(referenceNow).length, 28);
    });

    test('is deterministic - the same "now" always produces the same totals', () {
      final first = totalKwh(seedEnergySamples(referenceNow));
      final second = totalKwh(seedEnergySamples(referenceNow));
      expect(first, second);
    });

    test('the week totals 82.8 kWh, hand-summed per room', () {
      final samples = seedEnergySamples(referenceNow);
      final byRoom = kwhByRoom(samples);
      // living-room: 4.2+3.8+4.5+4.0+4.8+6.1+5.7 = 33.1
      expect(byRoom[RoomIds.livingRoom], closeTo(33.1, 0.001));
      // bedroom: 2.1+2.0+2.3+2.2+2.4+2.6+2.5 = 16.1
      expect(byRoom[RoomIds.bedroom], closeTo(16.1, 0.001));
      // kitchen: 3.4+3.9+3.6+3.7+4.1+5.2+4.9 = 28.8
      expect(byRoom[RoomIds.kitchen], closeTo(28.8, 0.001));
      // entryway: 0.6+0.6+0.7+0.6+0.6+0.9+0.8 = 4.8
      expect(byRoom[RoomIds.entryway], closeTo(4.8, 0.001));
      // 33.1 + 16.1 + 28.8 + 4.8 = 82.8
      expect(totalKwh(samples), closeTo(82.8, 0.001));
    });

    test('today (the last day of the window) totals 13.9 kWh across all rooms', () {
      final samples = seedEnergySamples(referenceNow);
      final today = samplesOnDay(samples, referenceNow);
      expect(today.length, 4); // one sample per room
      // 5.7 (living room) + 2.5 (bedroom) + 4.9 (kitchen) + 0.8 (entryway)
      expect(totalKwh(today), closeTo(13.9, 0.001));
    });

    test('living room uses the most energy and entryway the least, most weeks', () {
      final breakdown = roomUsageBreakdown(seedEnergySamples(referenceNow));
      expect(breakdown.map((u) => u.roomId).toList(), <String>[
        RoomIds.livingRoom,
        RoomIds.kitchen,
        RoomIds.bedroom,
        RoomIds.entryway,
      ]);
    });
  });
}
