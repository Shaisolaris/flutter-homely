import '../models/device.dart';
import '../models/scene.dart';

/// Pure, UI-independent scene math: applying a scene's device-state
/// overrides onto a device list, and checking whether the current device
/// list already matches a scene. Nothing here depends on Flutter.

/// Returns a new device list with every device referenced by
/// `scene.deviceStates` updated to match; devices the scene does not
/// mention pass through unchanged.
List<Device> applyScene(Scene scene, List<Device> devices) {
  final overrides = <String, SceneDeviceState>{
    for (final state in scene.deviceStates) state.deviceId: state,
  };
  return <Device>[
    for (final device in devices)
      if (overrides.containsKey(device.id)) _applyState(device, overrides[device.id]!) else device,
  ];
}

Device _applyState(Device device, SceneDeviceState state) {
  return device.copyWith(
    isOn: state.isOn ?? device.isOn,
    brightness: state.brightness ?? device.brightness,
    isLocked: state.isLocked ?? device.isLocked,
    setpoint: state.setpoint ?? device.setpoint,
    mode: state.mode ?? device.mode,
  );
}

/// Whether every device [scene] references is currently in the exact state
/// the scene calls for - used to highlight the "active" scene chip on Home.
///
/// A scene that references a device missing from [devices] is never
/// active. A scene with no device states is trivially active (vacuous
/// truth); every seeded scene has at least one, so this never surfaces in
/// practice.
bool isSceneActive(Scene scene, List<Device> devices) {
  final byId = <String, Device>{for (final device in devices) device.id: device};
  for (final state in scene.deviceStates) {
    final device = byId[state.deviceId];
    if (device == null) return false;
    if (state.isOn != null && state.isOn != device.isOn) return false;
    if (state.brightness != null && state.brightness != device.brightness) return false;
    if (state.isLocked != null && state.isLocked != device.isLocked) return false;
    if (state.setpoint != null && state.setpoint != device.setpoint) return false;
    if (state.mode != null && state.mode != device.mode) return false;
  }
  return true;
}
