import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/room_visuals.dart';
import '../../../core/models/device.dart';
import '../../../core/models/room.dart';
import '../../../data/providers.dart';
import '../../room_detail/room_detail_screen.dart';

/// A room's summary card on Home: icon, name, and how many of its
/// switchable devices (lights/plugs) are currently on. Tapping it opens
/// [RoomDetailScreen].
class RoomOverviewCard extends ConsumerWidget {
  const RoomOverviewCard({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final devices = ref.watch(devicesByRoomProvider(room.id));
    final switchable = devices.where((d) => d.type == DeviceType.light || d.type == DeviceType.plug).toList();
    final onCount = switchable.where((d) => d.isOn).length;
    final accent = roomAccentFor(room.type);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => RoomDetailScreen(roomId: room.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: accent.withValues(alpha: 0.15),
                foregroundColor: accent,
                child: Icon(roomIconFor(room.type)),
              ),
              const SizedBox(height: 12),
              Text(room.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                switchable.isEmpty ? '${devices.length} devices' : '$onCount of ${switchable.length} on',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
