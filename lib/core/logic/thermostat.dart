/// Pure, UI-independent thermostat math: clamping a setpoint into a safe
/// range and resolving what a daily schedule says the setpoint should be at
/// a given time. Nothing here depends on Flutter.
library;

/// A single point in a thermostat's daily schedule: from [hour] onward
/// (until the next point, or all day if there is only one point), the
/// target is [setpoint].
class ThermostatSchedulePoint {
  const ThermostatSchedulePoint({required this.hour, required this.setpoint});

  /// Local hour, 0-23, at which this point becomes active.
  final int hour;
  final double setpoint;
}

/// Homely's supported setpoint range, in degrees Fahrenheit.
const double minSetpointF = 50;
const double maxSetpointF = 90;

/// Clamps [value] into `[min, max]`.
double clampSetpoint(double value, {double min = minSetpointF, double max = maxSetpointF}) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

/// [current] shifted by [deltaDegrees] and clamped into `[min, max]` - the
/// building block behind a thermostat tile's +/- steppers.
double adjustSetpoint(
  double current,
  double deltaDegrees, {
  double min = minSetpointF,
  double max = maxSetpointF,
}) {
  return clampSetpoint(current + deltaDegrees, min: min, max: max);
}

/// The setpoint [schedule] specifies for [asOf], using [asOf]'s hour only
/// (minutes are ignored - schedules change on the hour).
///
/// [schedule] does not need to be sorted or start at hour 0: the applicable
/// point is whichever has the latest [ThermostatSchedulePoint.hour] that is
/// still less than or equal to `asOf.hour`. Before the first point of the
/// day, the schedule wraps around to the last point of [schedule] (i.e.
/// "last night's" setting is still in effect in the early hours).
///
/// Throws [ArgumentError] if [schedule] is empty.
double scheduledSetpoint(List<ThermostatSchedulePoint> schedule, DateTime asOf) {
  if (schedule.isEmpty) {
    throw ArgumentError.value(schedule, 'schedule', 'must contain at least one point');
  }
  final sorted = <ThermostatSchedulePoint>[...schedule]..sort((a, b) => a.hour.compareTo(b.hour));

  var applicable = sorted.last;
  for (final point in sorted) {
    if (point.hour > asOf.hour) break;
    applicable = point;
  }
  return applicable.setpoint;
}
