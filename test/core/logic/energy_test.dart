import 'package:flutter_homely/core/logic/energy.dart';
import 'package:flutter_homely/core/models/energy_sample.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final samples = <EnergySample>[
    EnergySample(id: 'e1', roomId: 'living-room', day: DateTime(2026, 8, 5), kwh: 4.0),
    EnergySample(id: 'e2', roomId: 'living-room', day: DateTime(2026, 8, 6), kwh: 5.0),
    EnergySample(id: 'e3', roomId: 'bedroom', day: DateTime(2026, 8, 5), kwh: 2.0),
    EnergySample(id: 'e4', roomId: 'bedroom', day: DateTime(2026, 8, 6), kwh: 3.0),
  ];

  group('totalKwh', () {
    test('sums every sample regardless of room or day', () {
      // 4.0 + 5.0 + 2.0 + 3.0
      expect(totalKwh(samples), 14.0);
    });

    test('an empty list totals to zero', () {
      expect(totalKwh(const <EnergySample>[]), 0);
    });
  });

  group('kwhByRoom', () {
    test('groups and sums per room', () {
      final byRoom = kwhByRoom(samples);
      expect(byRoom['living-room'], 9.0); // 4.0 + 5.0
      expect(byRoom['bedroom'], 5.0); // 2.0 + 3.0
      expect(byRoom.length, 2);
    });
  });

  group('roomUsageBreakdown', () {
    test('sorts highest-usage first and computes correct percentages', () {
      final breakdown = roomUsageBreakdown(samples);
      expect(breakdown.length, 2);

      expect(breakdown[0].roomId, 'living-room');
      expect(breakdown[0].kwh, 9.0);
      // 9 / 14 * 100 = 64.2857...
      expect(breakdown[0].percentOfTotal, closeTo(64.2857, 0.001));

      expect(breakdown[1].roomId, 'bedroom');
      expect(breakdown[1].kwh, 5.0);
      // 5 / 14 * 100 = 35.7142...
      expect(breakdown[1].percentOfTotal, closeTo(35.7143, 0.001));
    });

    test('an empty sample list produces an empty breakdown', () {
      expect(roomUsageBreakdown(const <EnergySample>[]), isEmpty);
    });

    test('a zero-usage sample reports 0% instead of dividing by zero', () {
      final zeroSamples = <EnergySample>[EnergySample(id: 'z1', roomId: 'attic', day: DateTime(2026, 8, 5), kwh: 0)];
      final breakdown = roomUsageBreakdown(zeroSamples);
      expect(breakdown.single.kwh, 0);
      expect(breakdown.single.percentOfTotal, 0);
    });
  });

  group('samplesOnDay', () {
    test('matches by calendar date, ignoring time-of-day', () {
      final onAug5 = samplesOnDay(samples, DateTime(2026, 8, 5, 23, 59));
      expect(onAug5.map((s) => s.id).toSet(), <String>{'e1', 'e3'});
    });

    test('a day with no samples returns an empty list', () {
      expect(samplesOnDay(samples, DateTime(2026, 1, 1)), isEmpty);
    });
  });

  group('estimatedCost', () {
    test('applies the default residential rate', () {
      // 10 kWh * $0.16/kWh
      expect(estimatedCost(10), closeTo(1.6, 0.0001));
    });

    test('zero usage costs nothing', () {
      expect(estimatedCost(0), 0);
    });

    test('a custom rate is honored', () {
      expect(estimatedCost(10, ratePerKwh: 0.20), closeTo(2.0, 0.0001));
    });
  });
}
