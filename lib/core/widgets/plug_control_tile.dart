import 'package:flutter/material.dart';

import '../models/device.dart';

/// A smart plug's control card: on/off switch only (no dimming).
class PlugControlTile extends StatelessWidget {
  const PlugControlTile({super.key, required this.device, required this.onToggle});

  final Device device;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 4, 20, 4),
        leading: CircleAvatar(
          backgroundColor: device.isOn ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          foregroundColor: device.isOn ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          child: const Icon(Icons.power),
        ),
        title: Text(device.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(device.isOn ? 'On' : 'Off'),
        trailing: Switch(value: device.isOn, onChanged: onToggle),
      ),
    );
  }
}
