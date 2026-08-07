import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/nav_tabs.dart';
import '../../core/models/device.dart';
import '../../core/widgets/device_control_tile.dart';
import '../../core/widgets/section_header.dart';
import '../../data/providers.dart';
import '../../data/seed_data.dart';
import 'widgets/room_overview_card.dart';
import 'widgets/scene_chip_row.dart';

/// The Home screen: a greeting, active-scene chips, a room-by-room overview
/// grid, and quick controls for a handful of everyday devices (a couple of
/// lights with dimming, the living room thermostat, both door locks).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onNavigateToTab});

  /// Switches the bottom-navigation tab (see [NavTab]) - used by the
  /// scenes section's "Manage" button.
  final ValueChanged<int> onNavigateToTab;

  /// A curated handful of devices featured directly on Home, so the most
  /// commonly touched controls never require drilling into a room.
  static const List<String> _quickDeviceIds = <String>[
    DeviceIds.livingRoomCeilingLights,
    DeviceIds.kitchenCeilingLights,
    DeviceIds.livingRoomThermostat,
    DeviceIds.entrywayFrontDoorLock,
    DeviceIds.entrywayBackDoorLock,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final devicesAsync = ref.watch(devicesProvider);
    final rooms = ref.watch(roomsProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Homely')),
      body: devicesAsync.when(
        data: (devices) {
          final deviceById = <String, Device>{for (final device in devices) device.id: device};
          final quickDevices = <Device>[
            for (final id in _quickDeviceIds)
              if (deviceById.containsKey(id)) deviceById[id]!,
          ];
          final quickLights = quickDevices.where((d) => d.type == DeviceType.light).toList();
          final quickThermostats = quickDevices.where((d) => d.type == DeviceType.thermostat).toList();
          final quickLocks = quickDevices.where((d) => d.type == DeviceType.lock).toList();
          final activeCount = devices
              .where((d) => (d.type == DeviceType.light || d.type == DeviceType.plug) && d.isOn)
              .length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Text(
                _greeting(now),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                '$activeCount device${activeCount == 1 ? '' : 's'} on across the house',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              SectionHeader(
                title: 'Scenes',
                trailing: TextButton(
                  onPressed: () => onNavigateToTab(NavTab.scenes),
                  child: const Text('Manage'),
                ),
              ),
              const SceneChipRow(),
              const SectionHeader(title: 'Rooms'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: <Widget>[for (final room in rooms) RoomOverviewCard(room: room)],
              ),
              if (quickLights.isNotEmpty) ...[
                const SectionHeader(title: 'Lights'),
                for (final device in quickLights)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DeviceControlTile(device: device),
                  ),
              ],
              if (quickThermostats.isNotEmpty) ...[
                const SectionHeader(title: 'Thermostat'),
                for (final device in quickThermostats)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DeviceControlTile(device: device),
                  ),
              ],
              if (quickLocks.isNotEmpty) ...[
                const SectionHeader(title: 'Locks'),
                for (final device in quickLocks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DeviceControlTile(device: device),
                  ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Could not load devices: $error')),
      ),
    );
  }

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
