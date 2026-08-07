import 'device.dart';

/// The icon glyph a [Scene] is represented by (mapped to a concrete
/// `IconData` in `core/constants/scene_visuals.dart` - kept out of this
/// Flutter-free model layer).
enum SceneIcon { morning, movie, away }

/// A single device's target state within a [Scene].
///
/// Every field is optional: a scene only overrides the fields it cares
/// about and leaves everything else on the device untouched - see
/// `core/logic/scenes.dart`.
class SceneDeviceState {
  const SceneDeviceState({
    required this.deviceId,
    this.isOn,
    this.brightness,
    this.isLocked,
    this.setpoint,
    this.mode,
  });

  final String deviceId;
  final bool? isOn;
  final int? brightness;
  final bool? isLocked;
  final double? setpoint;
  final ThermostatMode? mode;
}

/// A named, one-tap preset that pushes a set of [deviceStates] onto
/// whatever devices they reference.
///
/// Scenes are fixed reference data (see `data/seed_data.dart`) - Homely has
/// no scene editor, so applying one only ever changes device state, never
/// the scene definition itself.
class Scene {
  const Scene({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.deviceStates,
  });

  final String id;
  final String name;
  final String description;
  final SceneIcon icon;
  final List<SceneDeviceState> deviceStates;

  @override
  String toString() => 'Scene($id, $name)';
}
