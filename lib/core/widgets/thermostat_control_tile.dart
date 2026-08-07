import 'package:flutter/material.dart';

import '../models/device.dart';

/// A thermostat's control card: current reading, a big target-setpoint
/// readout with +/- steppers, a mode selector, and a "sync to schedule"
/// shortcut.
class ThermostatControlTile extends StatelessWidget {
  const ThermostatControlTile({
    super.key,
    required this.device,
    required this.onAdjust,
    required this.onModeChanged,
    required this.onSyncToSchedule,
  });

  final Device device;

  /// Called with a signed degree delta (e.g. `-1` or `1`); the caller is
  /// responsible for clamping (see `core/logic/thermostat.dart`).
  final ValueChanged<double> onAdjust;
  final ValueChanged<ThermostatMode> onModeChanged;
  final VoidCallback onSyncToSchedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: const Icon(Icons.device_thermostat),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${device.currentTemp.round()}°F now',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: () => onAdjust(-1),
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        '${device.setpoint.round()}°',
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text('target', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => onAdjust(1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SegmentedButton<ThermostatMode>(
              segments: const <ButtonSegment<ThermostatMode>>[
                ButtonSegment(value: ThermostatMode.off, label: Text('Off'), icon: Icon(Icons.power_settings_new)),
                ButtonSegment(value: ThermostatMode.heat, label: Text('Heat'), icon: Icon(Icons.whatshot)),
                ButtonSegment(value: ThermostatMode.cool, label: Text('Cool'), icon: Icon(Icons.ac_unit)),
                ButtonSegment(value: ThermostatMode.auto, label: Text('Auto'), icon: Icon(Icons.autorenew)),
              ],
              selected: <ThermostatMode>{device.mode},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => onModeChanged(selection.first),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onSyncToSchedule,
                icon: const Icon(Icons.schedule, size: 18),
                label: const Text('Sync to schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
