import 'package:flutter/material.dart';

import '../models/device.dart';

/// A light's control card: on/off switch plus a brightness slider that only
/// accepts input while the light is on.
class LightControlTile extends StatelessWidget {
  const LightControlTile({
    super.key,
    required this.device,
    required this.onToggle,
    required this.onBrightnessChanged,
  });

  final Device device;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onBrightnessChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: device.isOn ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                  foregroundColor: device.isOn ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                  child: Icon(device.isOn ? Icons.lightbulb : Icons.lightbulb_outline),
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
                        device.isOn ? '${device.brightness}% brightness' : 'Off',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Switch(value: device.isOn, onChanged: onToggle),
              ],
            ),
            if (device.isOn)
              SliderTheme(
                data: SliderTheme.of(context).copyWith(trackHeight: 3),
                child: Slider(
                  value: device.brightness.clamp(1, 100).toDouble(),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: '${device.brightness}%',
                  onChanged: (value) => onBrightnessChanged(value.round()),
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
