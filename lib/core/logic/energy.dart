import '../models/energy_sample.dart';
import 'date_utils.dart';

/// Pure, UI-independent energy math: summing usage across rooms, breaking
/// it down per room, and turning kWh into an estimated dollar cost. Nothing
/// here depends on Flutter.

/// The sum of every sample's kWh reading.
double totalKwh(List<EnergySample> samples) {
  return samples.fold<double>(0, (sum, sample) => sum + sample.kwh);
}

/// Total kWh grouped by [EnergySample.roomId].
Map<String, double> kwhByRoom(List<EnergySample> samples) {
  final result = <String, double>{};
  for (final sample in samples) {
    result[sample.roomId] = (result[sample.roomId] ?? 0) + sample.kwh;
  }
  return result;
}

/// One room's share of total energy usage.
class RoomEnergyUsage {
  const RoomEnergyUsage({required this.roomId, required this.kwh, required this.percentOfTotal});

  final String roomId;
  final double kwh;

  /// This room's share of the combined total, 0-100. `0` when the combined
  /// total is zero (nothing to divide by).
  final double percentOfTotal;
}

/// Per-room usage totals across every sample given, sorted highest-usage
/// first.
List<RoomEnergyUsage> roomUsageBreakdown(List<EnergySample> samples) {
  final total = totalKwh(samples);
  final byRoom = kwhByRoom(samples);
  final breakdown = <RoomEnergyUsage>[
    for (final entry in byRoom.entries)
      RoomEnergyUsage(
        roomId: entry.key,
        kwh: entry.value,
        percentOfTotal: total <= 0 ? 0 : (entry.value / total) * 100,
      ),
  ];
  breakdown.sort((a, b) => b.kwh.compareTo(a.kwh));
  return breakdown;
}

/// Only the samples that fall on [day] (calendar-date comparison, ignoring
/// time-of-day).
List<EnergySample> samplesOnDay(List<EnergySample> samples, DateTime day) {
  return samples.where((sample) => isSameDate(sample.day, day)).toList();
}

/// [kwh] converted to an estimated dollar cost at [ratePerKwh] ($/kWh,
/// defaulting to a realistic US residential rate).
double estimatedCost(double kwh, {double ratePerKwh = 0.16}) => kwh * ratePerKwh;
