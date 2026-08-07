import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../constants/thermostat_schedule.dart';
import '../logic/thermostat.dart';
import '../models/device.dart';
import 'light_control_tile.dart';
import 'lock_control_tile.dart';
import 'plug_control_tile.dart';
import 'thermostat_control_tile.dart';

/// Renders the right control card for [device]'s type and wires its
/// callbacks straight to [devicesProvider]'s notifier, so every screen that
/// lists devices (Home's quick controls, Room detail) shares one
/// implementation.
class DeviceControlTile extends ConsumerWidget {
  const DeviceControlTile({super.key, required this.device});

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(devicesProvider.notifier);

    switch (device.type) {
      case DeviceType.light:
        return LightControlTile(
          device: device,
          onToggle: (isOn) => notifier.setOn(device.id, isOn),
          onBrightnessChanged: (value) => notifier.setBrightness(device.id, value),
        );
      case DeviceType.thermostat:
        return ThermostatControlTile(
          device: device,
          onAdjust: (delta) => notifier.setSetpoint(device.id, adjustSetpoint(device.setpoint, delta)),
          onModeChanged: (mode) => notifier.setMode(device.id, mode),
          onSyncToSchedule: () => notifier.setSetpoint(
            device.id,
            scheduledSetpoint(defaultThermostatSchedule, DateTime.now()),
          ),
        );
      case DeviceType.lock:
        return LockControlTile(
          device: device,
          onToggle: (isLocked) => notifier.setLocked(device.id, isLocked),
        );
      case DeviceType.plug:
        return PlugControlTile(
          device: device,
          onToggle: (isOn) => notifier.setOn(device.id, isOn),
        );
    }
  }
}
