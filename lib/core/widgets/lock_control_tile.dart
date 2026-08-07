import 'package:flutter/material.dart';

import '../models/device.dart';

/// A lock's control card: current state plus a lock/unlock switch.
class LockControlTile extends StatelessWidget {
  const LockControlTile({super.key, required this.device, required this.onToggle});

  final Device device;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locked = device.isLocked;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 4, 20, 4),
        leading: CircleAvatar(
          backgroundColor: locked ? scheme.primaryContainer : scheme.errorContainer,
          foregroundColor: locked ? scheme.onPrimaryContainer : scheme.onErrorContainer,
          child: Icon(locked ? Icons.lock : Icons.lock_open),
        ),
        title: Text(device.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(locked ? 'Locked' : 'Unlocked'),
        trailing: Switch(value: locked, onChanged: onToggle),
      ),
    );
  }
}
