import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/automation_rule.dart';
import '../core/models/device.dart';
import '../core/models/energy_sample.dart';

/// Persistence contract for Homely's *mutable* data: device state,
/// automation enabled flags, and the seeded energy history.
///
/// Rooms and scenes are fixed reference data rebuilt from
/// `data/seed_data.dart` on every launch, so they are never persisted here
/// - only what the user can actually change needs a repository. The UI and
/// Riverpod notifiers only ever talk to this interface, never to
/// `shared_preferences` directly, which keeps the storage mechanism
/// swappable (and easy to fake in tests).
abstract class HomeRepository {
  Future<List<Device>> loadDevices();
  Future<void> saveDevices(List<Device> devices);

  Future<List<Automation>> loadAutomations();
  Future<void> saveAutomations(List<Automation> automations);

  Future<List<EnergySample>> loadEnergySamples();
  Future<void> saveEnergySamples(List<EnergySample> samples);

  /// Wipes every stored Homely key, restoring the app to a first-run state.
  Future<void> clearAll();
}

/// [HomeRepository] backed by `shared_preferences`, with each record type
/// stored as a single JSON-encoded string under its own key.
class SharedPreferencesHomeRepository implements HomeRepository {
  SharedPreferencesHomeRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String devicesKey = 'homely.devices.v1';
  static const String automationsKey = 'homely.automations.v1';
  static const String energySamplesKey = 'homely.energy_samples.v1';

  @override
  Future<List<Device>> loadDevices() async {
    final decoded = _readList(devicesKey);
    if (decoded == null) return const <Device>[];
    return decoded.map((json) => Device.fromJson(json)).toList();
  }

  @override
  Future<void> saveDevices(List<Device> devices) {
    return _writeList(devicesKey, devices.map((device) => device.toJson()).toList());
  }

  @override
  Future<List<Automation>> loadAutomations() async {
    final decoded = _readList(automationsKey);
    if (decoded == null) return const <Automation>[];
    return decoded.map((json) => Automation.fromJson(json)).toList();
  }

  @override
  Future<void> saveAutomations(List<Automation> automations) {
    return _writeList(automationsKey, automations.map((automation) => automation.toJson()).toList());
  }

  @override
  Future<List<EnergySample>> loadEnergySamples() async {
    final decoded = _readList(energySamplesKey);
    if (decoded == null) return const <EnergySample>[];
    return decoded.map((json) => EnergySample.fromJson(json)).toList();
  }

  @override
  Future<void> saveEnergySamples(List<EnergySample> samples) {
    return _writeList(energySamplesKey, samples.map((sample) => sample.toJson()).toList());
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(devicesKey);
    await _prefs.remove(automationsKey);
    await _prefs.remove(energySamplesKey);
  }

  List<Map<String, dynamic>>? _readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((entry) => entry as Map<String, dynamic>).toList();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> value) {
    return _prefs.setString(key, jsonEncode(value));
  }
}
