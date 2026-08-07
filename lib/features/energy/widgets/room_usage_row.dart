import 'package:flutter/material.dart';

import '../../../core/constants/room_visuals.dart';
import '../../../core/logic/energy.dart';
import '../../../core/models/room.dart';

/// One row in the Energy screen's per-room breakdown: icon, name, kWh
/// total, a share-of-total progress bar, and the percentage itself.
class RoomUsageRow extends StatelessWidget {
  const RoomUsageRow({super.key, required this.room, required this.usage});

  final Room room;
  final RoomEnergyUsage usage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = roomAccentFor(room.type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accent.withValues(alpha: 0.15),
            foregroundColor: accent,
            child: Icon(roomIconFor(room.type), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.name,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${usage.kwh.toStringAsFixed(1)} kWh',
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (usage.percentOfTotal / 100).clamp(0.0, 1.0).toDouble(),
                    minHeight: 6,
                    backgroundColor: scheme.surfaceContainerHighest,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 42,
            child: Text(
              '${usage.percentOfTotal.round()}%',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
