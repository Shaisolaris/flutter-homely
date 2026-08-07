import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/room_visuals.dart';
import '../../core/logic/energy.dart';
import '../../core/models/room.dart';
import '../../core/widgets/section_header.dart';
import '../../data/providers.dart';
import 'widgets/energy_bar_chart.dart';
import 'widgets/room_usage_row.dart';

/// Energy screen: this-week and today usage summaries, a per-room bar
/// chart, and a ranked per-room breakdown with share-of-total bars.
class EnergyScreen extends ConsumerWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energyAsync = ref.watch(energySamplesProvider);
    final rooms = ref.watch(roomsProvider);
    final roomById = <String, Room>{for (final room in rooms) room.id: room};

    return Scaffold(
      appBar: AppBar(title: const Text('Energy')),
      body: energyAsync.when(
        data: (_) {
          final breakdown = ref.watch(roomUsageBreakdownProvider);
          final totalWeek = ref.watch(totalWeeklyKwhProvider);
          final todayKwh = ref.watch(todayKwhProvider);

          final chartEntries = <EnergyBarEntry>[
            for (final usage in breakdown)
              EnergyBarEntry(
                label: roomById[usage.roomId]?.name ?? usage.roomId,
                kwh: usage.kwh,
                color: roomAccentFor(roomById[usage.roomId]?.type ?? RoomType.livingRoom),
              ),
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.bolt,
                      label: 'This week',
                      value: '${totalWeek.toStringAsFixed(1)} kWh',
                      caption: '≈ \$${estimatedCost(totalWeek).toStringAsFixed(2)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.today_outlined,
                      label: 'Today',
                      value: '${todayKwh.toStringAsFixed(1)} kWh',
                      caption: '≈ \$${estimatedCost(todayKwh).toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              const SectionHeader(title: 'Usage by room', subtitle: 'Total kWh over the last 7 days.'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                  child: EnergyBarChart(entries: chartEntries),
                ),
              ),
              const SectionHeader(title: 'Breakdown'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    children: [
                      for (final usage in breakdown)
                        if (roomById[usage.roomId] != null) RoomUsageRow(room: roomById[usage.roomId]!, usage: usage),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Could not load energy data: $error')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.caption});

  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            Text(caption, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
