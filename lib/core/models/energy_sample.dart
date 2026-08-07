/// A single room-day energy reading, in kilowatt-hours.
///
/// Historical/demo data only - see `core/logic/energy.dart` for the pure
/// aggregation logic and `data/seed_data.dart` for how these are seeded.
class EnergySample {
  const EnergySample({
    required this.id,
    required this.roomId,
    required this.day,
    required this.kwh,
  });

  final String id;
  final String roomId;

  /// Date-only (time-of-day is ignored/zeroed).
  final DateTime day;
  final double kwh;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'roomId': roomId,
        'day': day.toIso8601String(),
        'kwh': kwh,
      };

  factory EnergySample.fromJson(Map<String, dynamic> json) {
    return EnergySample(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      day: DateTime.parse(json['day'] as String),
      kwh: (json['kwh'] as num).toDouble(),
    );
  }

  @override
  String toString() => 'EnergySample($roomId, $day, ${kwh}kWh)';
}
