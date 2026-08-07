import 'package:flutter/material.dart';

import '../models/automation_rule.dart';

/// The glyph representing an automation's trigger type - a clock for
/// time-based triggers, a sensor for device-state ones, a thermostat glyph
/// for temperature ones.
IconData triggerIconFor(TriggerType type) {
  switch (type) {
    case TriggerType.timeAtOrAfter:
      return Icons.schedule;
    case TriggerType.deviceIsOn:
    case TriggerType.deviceIsOff:
    case TriggerType.deviceIsLocked:
    case TriggerType.deviceIsUnlocked:
      return Icons.sensors;
    case TriggerType.thermostatAtOrAbove:
    case TriggerType.thermostatAtOrBelow:
      return Icons.device_thermostat;
  }
}
