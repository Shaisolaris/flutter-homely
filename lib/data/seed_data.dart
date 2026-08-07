import '../core/logic/date_utils.dart';
import '../core/models/automation_rule.dart';
import '../core/models/device.dart';
import '../core/models/energy_sample.dart';
import '../core/models/room.dart';
import '../core/models/scene.dart';

/// Deterministic first-run demo data for Homely: 4 rooms, 12 devices, 3
/// scenes, 2 automations, and a week of energy history. Nothing here is
/// random - the same inputs always produce the same output, which keeps the
/// widget tests (and the demo itself) predictable.

/// Room IDs, exposed as constants so seed devices/scenes/automations below
/// (and tests) can reference them without magic strings.
abstract final class RoomIds {
  static const String livingRoom = 'living-room';
  static const String bedroom = 'bedroom';
  static const String kitchen = 'kitchen';
  static const String entryway = 'entryway';
}

/// Device IDs, exposed for the same reason as [RoomIds].
abstract final class DeviceIds {
  static const String livingRoomCeilingLights = 'lr-ceiling-lights';
  static const String livingRoomThermostat = 'lr-thermostat';
  static const String livingRoomTvPlug = 'lr-tv-plug';

  static const String bedroomLamp = 'br-lamp';
  static const String bedroomThermostat = 'br-thermostat';
  static const String bedroomFanPlug = 'br-fan-plug';

  static const String kitchenCeilingLights = 'kt-ceiling-lights';
  static const String kitchenUnderCabinetLights = 'kt-under-cabinet-lights';
  static const String kitchenCoffeeMakerPlug = 'kt-coffee-maker-plug';

  static const String entrywayFrontDoorLock = 'ent-front-door-lock';
  static const String entrywayBackDoorLock = 'ent-back-door-lock';
  static const String entrywayPorchLight = 'ent-porch-light';
}

List<Room> seedRooms() => const <Room>[
      Room(id: RoomIds.livingRoom, name: 'Living Room', type: RoomType.livingRoom),
      Room(id: RoomIds.bedroom, name: 'Bedroom', type: RoomType.bedroom),
      Room(id: RoomIds.kitchen, name: 'Kitchen', type: RoomType.kitchen),
      Room(id: RoomIds.entryway, name: 'Entryway', type: RoomType.entryway),
    ];

List<Device> seedDevices() => const <Device>[
      Device(
        id: DeviceIds.livingRoomCeilingLights,
        roomId: RoomIds.livingRoom,
        name: 'Ceiling Lights',
        type: DeviceType.light,
        isOn: true,
        brightness: 80,
      ),
      Device(
        id: DeviceIds.livingRoomThermostat,
        roomId: RoomIds.livingRoom,
        name: 'Living Room Thermostat',
        type: DeviceType.thermostat,
        currentTemp: 72,
        setpoint: 71,
        mode: ThermostatMode.auto,
      ),
      Device(
        id: DeviceIds.livingRoomTvPlug,
        roomId: RoomIds.livingRoom,
        name: 'TV Plug',
        type: DeviceType.plug,
        isOn: true,
      ),
      Device(
        id: DeviceIds.bedroomLamp,
        roomId: RoomIds.bedroom,
        name: 'Bedroom Lamp',
        type: DeviceType.light,
        isOn: false,
        brightness: 30,
      ),
      Device(
        id: DeviceIds.bedroomThermostat,
        roomId: RoomIds.bedroom,
        name: 'Bedroom Thermostat',
        type: DeviceType.thermostat,
        currentTemp: 69,
        setpoint: 68,
        mode: ThermostatMode.heat,
      ),
      Device(
        id: DeviceIds.bedroomFanPlug,
        roomId: RoomIds.bedroom,
        name: 'Box Fan Plug',
        type: DeviceType.plug,
        isOn: false,
      ),
      Device(
        id: DeviceIds.kitchenCeilingLights,
        roomId: RoomIds.kitchen,
        name: 'Ceiling Lights',
        type: DeviceType.light,
        isOn: true,
        brightness: 100,
      ),
      Device(
        id: DeviceIds.kitchenUnderCabinetLights,
        roomId: RoomIds.kitchen,
        name: 'Under-Cabinet Lights',
        type: DeviceType.light,
        isOn: false,
        brightness: 50,
      ),
      Device(
        id: DeviceIds.kitchenCoffeeMakerPlug,
        roomId: RoomIds.kitchen,
        name: 'Coffee Maker Plug',
        type: DeviceType.plug,
        isOn: false,
      ),
      Device(
        id: DeviceIds.entrywayFrontDoorLock,
        roomId: RoomIds.entryway,
        name: 'Front Door Lock',
        type: DeviceType.lock,
        isLocked: true,
      ),
      Device(
        id: DeviceIds.entrywayBackDoorLock,
        roomId: RoomIds.entryway,
        name: 'Back Door Lock',
        type: DeviceType.lock,
        isLocked: true,
      ),
      Device(
        id: DeviceIds.entrywayPorchLight,
        roomId: RoomIds.entryway,
        name: 'Porch Light',
        type: DeviceType.light,
        isOn: true,
        brightness: 60,
      ),
    ];

List<Scene> seedScenes() => const <Scene>[
      Scene(
        id: 'scene-good-morning',
        name: 'Good Morning',
        description: 'Bright living room and kitchen lights, porch light off, thermostat to 72°F.',
        icon: SceneIcon.morning,
        deviceStates: <SceneDeviceState>[
          SceneDeviceState(deviceId: DeviceIds.livingRoomCeilingLights, isOn: true, brightness: 80),
          SceneDeviceState(deviceId: DeviceIds.kitchenCeilingLights, isOn: true, brightness: 100),
          SceneDeviceState(deviceId: DeviceIds.entrywayPorchLight, isOn: false),
          SceneDeviceState(deviceId: DeviceIds.livingRoomThermostat, setpoint: 72, mode: ThermostatMode.auto),
        ],
      ),
      Scene(
        id: 'scene-movie-night',
        name: 'Movie Night',
        description: 'Living room dimmed low, kitchen lights off, TV plug on.',
        icon: SceneIcon.movie,
        deviceStates: <SceneDeviceState>[
          SceneDeviceState(deviceId: DeviceIds.livingRoomCeilingLights, isOn: true, brightness: 15),
          SceneDeviceState(deviceId: DeviceIds.kitchenCeilingLights, isOn: false),
          SceneDeviceState(deviceId: DeviceIds.kitchenUnderCabinetLights, isOn: false),
          SceneDeviceState(deviceId: DeviceIds.livingRoomTvPlug, isOn: true),
        ],
      ),
      Scene(
        id: 'scene-away',
        name: 'Away Mode',
        description: 'Everything off and locked, porch light on for security, thermostats set to eco.',
        icon: SceneIcon.away,
        deviceStates: <SceneDeviceState>[
          SceneDeviceState(deviceId: DeviceIds.livingRoomCeilingLights, isOn: false),
          SceneDeviceState(deviceId: DeviceIds.bedroomLamp, isOn: false),
          SceneDeviceState(deviceId: DeviceIds.kitchenCeilingLights, isOn: false),
          SceneDeviceState(deviceId: DeviceIds.kitchenUnderCabinetLights, isOn: false),
          SceneDeviceState(deviceId: DeviceIds.entrywayPorchLight, isOn: true, brightness: 40),
          SceneDeviceState(deviceId: DeviceIds.livingRoomTvPlug, isOn: false),
          SceneDeviceState(deviceId: DeviceIds.bedroomFanPlug, isOn: false),
          SceneDeviceState(deviceId: DeviceIds.kitchenCoffeeMakerPlug, isOn: false),
          SceneDeviceState(deviceId: DeviceIds.entrywayFrontDoorLock, isLocked: true),
          SceneDeviceState(deviceId: DeviceIds.entrywayBackDoorLock, isLocked: true),
          SceneDeviceState(deviceId: DeviceIds.livingRoomThermostat, setpoint: 62, mode: ThermostatMode.auto),
          SceneDeviceState(deviceId: DeviceIds.bedroomThermostat, setpoint: 60, mode: ThermostatMode.auto),
        ],
      ),
    ];

List<Automation> seedAutomations() => const <Automation>[
      Automation(
        id: 'auto-lock-up',
        name: 'Lock Up at Night',
        trigger: AutomationTrigger(type: TriggerType.timeAtOrAfter, timeOfDay: '22:30'),
        action: AutomationAction(type: ActionType.lock, deviceId: DeviceIds.entrywayFrontDoorLock),
        enabled: true,
      ),
      Automation(
        id: 'auto-eco-when-locked',
        name: 'Eco Mode When Locked Up',
        trigger: AutomationTrigger(type: TriggerType.deviceIsLocked, deviceId: DeviceIds.entrywayFrontDoorLock),
        action: AutomationAction(type: ActionType.setSetpoint, deviceId: DeviceIds.livingRoomThermostat, setpoint: 62),
        enabled: false,
      ),
    ];

/// A week of realistic, hand-authored (not random) per-room daily kWh
/// readings, oldest first, ending on "today". Weekend-shaped: usage climbs
/// on the last two days, mirroring a household that's busier at home on
/// weekends.
const Map<String, List<double>> _weeklyKwhByRoom = <String, List<double>>{
  RoomIds.livingRoom: <double>[4.2, 3.8, 4.5, 4.0, 4.8, 6.1, 5.7],
  RoomIds.bedroom: <double>[2.1, 2.0, 2.3, 2.2, 2.4, 2.6, 2.5],
  RoomIds.kitchen: <double>[3.4, 3.9, 3.6, 3.7, 4.1, 5.2, 4.9],
  RoomIds.entryway: <double>[0.6, 0.6, 0.7, 0.6, 0.6, 0.9, 0.8],
};

/// Builds a week of [EnergySample]s ending on the calendar date of [now].
List<EnergySample> seedEnergySamples(DateTime now) {
  final today = dateOnly(now);
  final samples = <EnergySample>[];
  var counter = 0;
  for (final entry in _weeklyKwhByRoom.entries) {
    final roomId = entry.key;
    final values = entry.value; // oldest (6 days ago) -> newest (today)
    for (var i = 0; i < values.length; i++) {
      final dayOffset = values.length - 1 - i;
      samples.add(
        EnergySample(
          id: 'energy-$roomId-$counter',
          roomId: roomId,
          day: addCalendarDays(today, -dayOffset),
          kwh: values[i],
        ),
      );
      counter += 1;
    }
  }
  return samples;
}
