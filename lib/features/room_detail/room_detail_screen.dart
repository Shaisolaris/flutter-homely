import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/room_visuals.dart';
import '../../core/models/device.dart';
import '../../core/models/room.dart';
import '../../core/widgets/device_control_tile.dart';
import '../../core/widgets/section_header.dart';
import '../../data/providers.dart';

Room? _findRoom(List<Room> rooms, String id) {
  for (final room in rooms) {
    if (room.id == id) return room;
  }
  return null;
}

/// Room detail screen: every device in one room, grouped by type, each with
/// its full control card - the same [DeviceControlTile] used in Home's
/// quick-controls section.
class RoomDetailScreen extends ConsumerWidget {
  const RoomDetailScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = _findRoom(ref.watch(roomsProvider), roomId);
    final devices = ref.watch(devicesByRoomProvider(roomId));

    final grouped = <DeviceType, List<Device>>{};
    for (final device in devices) {
      grouped.putIfAbsent(device.type, () => <Device>[]).add(device);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (room != null) ...[
              Icon(roomIconFor(room.type), size: 20),
              const SizedBox(width: 8),
            ],
            Text(room?.name ?? 'Room'),
          ],
        ),
      ),
      body: devices.isEmpty
          ? Center(
              child: Text('No devices in this room yet.', style: Theme.of(context).textTheme.bodyMedium),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: <Widget>[
                for (final type in DeviceType.values)
                  if (grouped[type]?.isNotEmpty ?? false) ...[
                    SectionHeader(title: type.label),
                    for (final device in grouped[type]!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: DeviceControlTile(device: device),
                      ),
                  ],
              ],
            ),
    );
  }
}
