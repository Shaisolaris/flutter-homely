/// What condition an [Automation] watches for.
enum TriggerType {
  deviceIsOn,
  deviceIsOff,
  deviceIsLocked,
  deviceIsUnlocked,
  timeAtOrAfter,
  thermostatAtOrAbove,
  thermostatAtOrBelow,
}

/// The condition half of an "if this, then that" [Automation].
///
/// Which fields matter depends on [type]:
/// - device-state triggers ([TriggerType.deviceIsOn] and friends): [deviceId]
/// - [TriggerType.timeAtOrAfter]: [timeOfDay], formatted `'HH:mm'` (24-hour)
/// - thermostat triggers: [deviceId] and [threshold] (degrees Fahrenheit)
class AutomationTrigger {
  const AutomationTrigger({
    required this.type,
    this.deviceId,
    this.timeOfDay,
    this.threshold,
  });

  final TriggerType type;
  final String? deviceId;
  final String? timeOfDay;
  final double? threshold;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        if (deviceId != null) 'deviceId': deviceId,
        if (timeOfDay != null) 'timeOfDay': timeOfDay,
        if (threshold != null) 'threshold': threshold,
      };

  factory AutomationTrigger.fromJson(Map<String, dynamic> json) {
    return AutomationTrigger(
      type: TriggerType.values.byName(json['type'] as String),
      deviceId: json['deviceId'] as String?,
      timeOfDay: json['timeOfDay'] as String?,
      threshold: (json['threshold'] as num?)?.toDouble(),
    );
  }
}

/// What an [Automation] does once its trigger fires.
enum ActionType { turnOn, turnOff, lock, unlock, setBrightness, setSetpoint }

/// The "then" half of an [Automation]: always targets exactly one device.
class AutomationAction {
  const AutomationAction({
    required this.type,
    required this.deviceId,
    this.brightness,
    this.setpoint,
  });

  final ActionType type;
  final String deviceId;
  final int? brightness;
  final double? setpoint;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'deviceId': deviceId,
        if (brightness != null) 'brightness': brightness,
        if (setpoint != null) 'setpoint': setpoint,
      };

  factory AutomationAction.fromJson(Map<String, dynamic> json) {
    return AutomationAction(
      type: ActionType.values.byName(json['type'] as String),
      deviceId: json['deviceId'] as String,
      brightness: json['brightness'] as int?,
      setpoint: (json['setpoint'] as num?)?.toDouble(),
    );
  }
}

/// A simple "if [trigger], then [action]" rule, toggled on or off with
/// [enabled]. See `core/logic/automation.dart` for the pure evaluation
/// logic that runs against it.
class Automation {
  const Automation({
    required this.id,
    required this.name,
    required this.trigger,
    required this.action,
    this.enabled = true,
  });

  final String id;
  final String name;
  final AutomationTrigger trigger;
  final AutomationAction action;
  final bool enabled;

  Automation copyWith({
    String? id,
    String? name,
    AutomationTrigger? trigger,
    AutomationAction? action,
    bool? enabled,
  }) {
    return Automation(
      id: id ?? this.id,
      name: name ?? this.name,
      trigger: trigger ?? this.trigger,
      action: action ?? this.action,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'trigger': trigger.toJson(),
        'action': action.toJson(),
        'enabled': enabled,
      };

  factory Automation.fromJson(Map<String, dynamic> json) {
    return Automation(
      id: json['id'] as String,
      name: json['name'] as String,
      trigger: AutomationTrigger.fromJson(json['trigger'] as Map<String, dynamic>),
      action: AutomationAction.fromJson(json['action'] as Map<String, dynamic>),
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  @override
  String toString() => 'Automation($id, $name, enabled: $enabled)';
}
