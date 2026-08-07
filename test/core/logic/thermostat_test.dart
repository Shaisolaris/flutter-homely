import 'package:flutter_homely/core/logic/thermostat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('clampSetpoint', () {
    test('values within range pass through unchanged', () {
      expect(clampSetpoint(72), 72);
    });

    test('values below the default minimum (50) clamp up to 50', () {
      expect(clampSetpoint(45), minSetpointF);
      expect(clampSetpoint(45), 50);
    });

    test('values above the default maximum (90) clamp down to 90', () {
      expect(clampSetpoint(95), maxSetpointF);
      expect(clampSetpoint(95), 90);
    });

    test('a custom range is honored', () {
      expect(clampSetpoint(20, min: 60, max: 80), 60);
      expect(clampSetpoint(120, min: 60, max: 80), 80);
      expect(clampSetpoint(70, min: 60, max: 80), 70);
    });
  });

  group('adjustSetpoint', () {
    test('a positive delta raises the setpoint', () {
      expect(adjustSetpoint(70, 1), 71);
    });

    test('a negative delta lowers the setpoint', () {
      expect(adjustSetpoint(68, -2), 66);
    });

    test('raising past the maximum clamps at 90', () {
      expect(adjustSetpoint(90, 1), 90);
      expect(adjustSetpoint(89.5, 1), 90);
    });

    test('lowering past the minimum clamps at 50', () {
      expect(adjustSetpoint(50, -5), 50);
      expect(adjustSetpoint(52, -5), 50);
    });
  });

  group('scheduledSetpoint', () {
    // A typical weekday schedule: warm at 6am, ease back at 9am, warm again
    // at 5pm, cool down for sleep at 10pm.
    const schedule = <ThermostatSchedulePoint>[
      ThermostatSchedulePoint(hour: 6, setpoint: 70),
      ThermostatSchedulePoint(hour: 9, setpoint: 64),
      ThermostatSchedulePoint(hour: 17, setpoint: 71),
      ThermostatSchedulePoint(hour: 22, setpoint: 62),
    ];

    test('mid-morning (8am) still reflects the 6am point', () {
      expect(scheduledSetpoint(schedule, DateTime(2026, 8, 7, 8)), 70);
    });

    test('exactly on a schedule point (9am) switches to it', () {
      expect(scheduledSetpoint(schedule, DateTime(2026, 8, 7, 9)), 64);
    });

    test('late evening (11pm) reflects the 10pm point', () {
      expect(scheduledSetpoint(schedule, DateTime(2026, 8, 7, 23)), 62);
    });

    test('before the first point of the day wraps to the last point', () {
      expect(scheduledSetpoint(schedule, DateTime(2026, 8, 7, 2)), 62);
      expect(scheduledSetpoint(schedule, DateTime(2026, 8, 7, 0)), 62);
    });

    test('order of the input list does not matter - it is sorted internally', () {
      final shuffled = <ThermostatSchedulePoint>[schedule[2], schedule[0], schedule[3], schedule[1]];
      expect(scheduledSetpoint(shuffled, DateTime(2026, 8, 7, 10)), 64);
    });

    test('a single-point schedule applies all day', () {
      const single = <ThermostatSchedulePoint>[ThermostatSchedulePoint(hour: 0, setpoint: 65)];
      expect(scheduledSetpoint(single, DateTime(2026, 8, 7, 3)), 65);
      expect(scheduledSetpoint(single, DateTime(2026, 8, 7, 23)), 65);
    });

    test('an empty schedule throws ArgumentError', () {
      expect(() => scheduledSetpoint(const <ThermostatSchedulePoint>[], DateTime(2026, 8, 7)), throwsArgumentError);
    });
  });
}
