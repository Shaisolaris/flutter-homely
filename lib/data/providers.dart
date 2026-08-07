import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logic/automation.dart';
import '../core/logic/energy.dart';
import '../core/logic/scenes.dart';
import '../core/logic/thermostat.dart';
import '../core/models/automation_rule.dart';
import '../core/models/device.dart';
import '../core/models/energy_sample.dart';
import '../core/models/room.dart';
import '../core/models/scene.dart';
import 'home_repository.dart';
import 'seed_data.dart';

/// Overridden with a real instance in `main.dart` once
/// `SharedPreferences.getInstance()` resolves. Left unimplemented here so
/// any accidental read before that override is applied fails loudly instead
/// of silently returning bad data.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with a real SharedPreferences '
    'instance before the app runs - see main().',
  );
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return SharedPreferencesHomeRepository(ref.watch(sharedPreferencesProvider));
});

/// Rooms are fixed reference data - no persistence, no mutation, just a
/// constant list rebuilt on every app start.
final roomsProvider = Provider<List<Room>>((ref) => seedRooms());

/// Scenes are fixed reference data too - applying one only ever changes
/// [devicesProvider], never the scene list itself.
final scenesProvider = Provider<List<Scene>>((ref) => seedScenes());

class DevicesNotifier extends AsyncNotifier<List<Device>> {
  @override
  Future<List<Device>> build() async {
    final repository = ref.watch(homeRepositoryProvider);
    final existing = await repository.loadDevices();
    if (existing.isNotEmpty) return existing;

    final seeded = seedDevices();
    await repository.saveDevices(seeded);
    return seeded;
  }

  Future<void> _persist(List<Device> updated) async {
    state = AsyncData<List<Device>>(updated);
    await ref.read(homeRepositoryProvider).saveDevices(updated);
  }

  List<Device> _map(String deviceId, Device Function(Device device) update) {
    final current = state.valueOrNull ?? const <Device>[];
    return <Device>[for (final device in current) device.id == deviceId ? update(device) : device];
  }

  Future<void> setOn(String deviceId, bool isOn) => _persist(_map(deviceId, (d) => d.copyWith(isOn: isOn)));

  Future<void> setBrightness(String deviceId, int brightness) {
    final clamped = brightness.clamp(1, 100).toInt();
    return _persist(_map(deviceId, (d) => d.copyWith(brightness: clamped)));
  }

  Future<void> setLocked(String deviceId, bool isLocked) {
    return _persist(_map(deviceId, (d) => d.copyWith(isLocked: isLocked)));
  }

  Future<void> setSetpoint(String deviceId, double setpoint) {
    final clamped = clampSetpoint(setpoint);
    return _persist(_map(deviceId, (d) => d.copyWith(setpoint: clamped)));
  }

  Future<void> setMode(String deviceId, ThermostatMode mode) {
    return _persist(_map(deviceId, (d) => d.copyWith(mode: mode)));
  }

  /// Applies every device-state override in [scene] onto the current
  /// device list (see `core/logic/scenes.dart`).
  Future<void> activateScene(Scene scene) async {
    final current = state.valueOrNull ?? const <Device>[];
    await _persist(applyScene(scene, current));
  }

  /// Evaluates [automation] against the current device list and [now],
  /// applying its action if the trigger holds. Returns whether it actually
  /// fired, so the caller can surface the right feedback.
  Future<bool> testAutomation(Automation automation, DateTime now) async {
    final current = state.valueOrNull ?? const <Device>[];
    if (!automationWouldFire(automation, current, now)) return false;
    await _persist(runAutomation(automation, current, now));
    return true;
  }
}

final devicesProvider = AsyncNotifierProvider<DevicesNotifier, List<Device>>(DevicesNotifier.new);

/// Every device belonging to [roomId], in seed order.
final devicesByRoomProvider = Provider.family<List<Device>, String>((ref, roomId) {
  final devices = ref.watch(devicesProvider).valueOrNull ?? const <Device>[];
  return devices.where((device) => device.roomId == roomId).toList();
});

/// The IDs of every scene whose device states are all currently matched -
/// drives which chip(s) read as "active" on Home.
final activeSceneIdsProvider = Provider<Set<String>>((ref) {
  final devices = ref.watch(devicesProvider).valueOrNull ?? const <Device>[];
  final scenes = ref.watch(scenesProvider);
  return <String>{for (final scene in scenes) if (isSceneActive(scene, devices)) scene.id};
});

class AutomationsNotifier extends AsyncNotifier<List<Automation>> {
  @override
  Future<List<Automation>> build() async {
    final repository = ref.watch(homeRepositoryProvider);
    final existing = await repository.loadAutomations();
    if (existing.isNotEmpty) return existing;

    final seeded = seedAutomations();
    await repository.saveAutomations(seeded);
    return seeded;
  }

  Future<void> setEnabled(String automationId, bool enabled) async {
    final current = state.valueOrNull ?? const <Automation>[];
    final updated = <Automation>[
      for (final automation in current)
        automation.id == automationId ? automation.copyWith(enabled: enabled) : automation,
    ];
    state = AsyncData<List<Automation>>(updated);
    await ref.read(homeRepositoryProvider).saveAutomations(updated);
  }
}

final automationsProvider = AsyncNotifierProvider<AutomationsNotifier, List<Automation>>(AutomationsNotifier.new);

class EnergySamplesNotifier extends AsyncNotifier<List<EnergySample>> {
  @override
  Future<List<EnergySample>> build() async {
    final repository = ref.watch(homeRepositoryProvider);
    final existing = await repository.loadEnergySamples();
    if (existing.isNotEmpty) return existing;

    final seeded = seedEnergySamples(DateTime.now());
    await repository.saveEnergySamples(seeded);
    return seeded;
  }
}

final energySamplesProvider =
    AsyncNotifierProvider<EnergySamplesNotifier, List<EnergySample>>(EnergySamplesNotifier.new);

/// Per-room usage totals across the full seeded history, highest-usage
/// first.
final roomUsageBreakdownProvider = Provider<List<RoomEnergyUsage>>((ref) {
  final samples = ref.watch(energySamplesProvider).valueOrNull ?? const <EnergySample>[];
  return roomUsageBreakdown(samples);
});

/// The combined total across every room and every seeded day.
final totalWeeklyKwhProvider = Provider<double>((ref) {
  final samples = ref.watch(energySamplesProvider).valueOrNull ?? const <EnergySample>[];
  return totalKwh(samples);
});

/// Usage for just today, across every room.
final todayKwhProvider = Provider<double>((ref) {
  final samples = ref.watch(energySamplesProvider).valueOrNull ?? const <EnergySample>[];
  return totalKwh(samplesOnDay(samples, DateTime.now()));
});
