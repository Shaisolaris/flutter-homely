import '../logic/thermostat.dart';

/// Homely's default eco/comfort schedule, used by a thermostat tile's
/// "Sync to schedule" action. A typical weekday pattern: warm up in the
/// morning, ease back while the house is likely empty, warm again in the
/// evening, cool down for sleep.
const List<ThermostatSchedulePoint> defaultThermostatSchedule = <ThermostatSchedulePoint>[
  ThermostatSchedulePoint(hour: 6, setpoint: 70),
  ThermostatSchedulePoint(hour: 9, setpoint: 64),
  ThermostatSchedulePoint(hour: 17, setpoint: 71),
  ThermostatSchedulePoint(hour: 22, setpoint: 62),
];
