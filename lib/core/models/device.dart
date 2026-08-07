/// The kind of device. Each type only uses a subset of [Device]'s fields -
/// see the field-level docs on [Device] for which ones apply.
enum DeviceType { light, thermostat, lock, plug }

extension DeviceTypeLabel on DeviceType {
  String get label => switch (this) {
        DeviceType.light => 'Light',
        DeviceType.thermostat => 'Thermostat',
        DeviceType.lock => 'Lock',
        DeviceType.plug => 'Smart plug',
      };
}

/// A thermostat's operating mode.
enum ThermostatMode { off, heat, cool, auto }

extension ThermostatModeLabel on ThermostatMode {
  String get label => switch (this) {
        ThermostatMode.off => 'Off',
        ThermostatMode.heat => 'Heat',
        ThermostatMode.cool => 'Cool',
        ThermostatMode.auto => 'Auto',
      };
}

/// A single smart-home device.
///
/// Fields are shared across every [DeviceType] for simplicity (and to keep
/// [copyWith]/JSON trivial); which ones are meaningful depends on [type]:
///
/// - [DeviceType.light]: [isOn], [brightness]
/// - [DeviceType.thermostat]: [currentTemp], [setpoint], [mode]
/// - [DeviceType.lock]: [isLocked]
/// - [DeviceType.plug]: [isOn]
class Device {
  const Device({
    required this.id,
    required this.roomId,
    required this.name,
    required this.type,
    this.isOn = false,
    this.brightness = 100,
    this.isLocked = true,
    this.currentTemp = 70,
    this.setpoint = 70,
    this.mode = ThermostatMode.auto,
  });

  final String id;
  final String roomId;
  final String name;
  final DeviceType type;

  /// Power state, [DeviceType.light] and [DeviceType.plug] only.
  final bool isOn;

  /// Brightness percent (1-100), [DeviceType.light] only.
  final int brightness;

  /// Locked state, [DeviceType.lock] only.
  final bool isLocked;

  /// Ambient reading in degrees Fahrenheit, [DeviceType.thermostat] only.
  final double currentTemp;

  /// Target temperature in degrees Fahrenheit, [DeviceType.thermostat] only.
  final double setpoint;

  /// Operating mode, [DeviceType.thermostat] only.
  final ThermostatMode mode;

  Device copyWith({
    String? id,
    String? roomId,
    String? name,
    DeviceType? type,
    bool? isOn,
    int? brightness,
    bool? isLocked,
    double? currentTemp,
    double? setpoint,
    ThermostatMode? mode,
  }) {
    return Device(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
      brightness: brightness ?? this.brightness,
      isLocked: isLocked ?? this.isLocked,
      currentTemp: currentTemp ?? this.currentTemp,
      setpoint: setpoint ?? this.setpoint,
      mode: mode ?? this.mode,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'roomId': roomId,
        'name': name,
        'type': type.name,
        'isOn': isOn,
        'brightness': brightness,
        'isLocked': isLocked,
        'currentTemp': currentTemp,
        'setpoint': setpoint,
        'mode': mode.name,
      };

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      name: json['name'] as String,
      type: DeviceType.values.byName(json['type'] as String),
      isOn: json['isOn'] as bool? ?? false,
      brightness: json['brightness'] as int? ?? 100,
      isLocked: json['isLocked'] as bool? ?? true,
      currentTemp: (json['currentTemp'] as num?)?.toDouble() ?? 70,
      setpoint: (json['setpoint'] as num?)?.toDouble() ?? 70,
      mode: ThermostatMode.values.byName(json['mode'] as String? ?? ThermostatMode.auto.name),
    );
  }

  @override
  String toString() => 'Device($id, $name, ${type.name})';
}
