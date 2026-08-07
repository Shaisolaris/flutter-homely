# Homely

A smart-home control panel built with Flutter. Homely brings every room's lights,
locks, thermostats, scenes, and automations into one dashboard, plus a room-by-room
breakdown of how much energy the house is actually using.

**Live preview:** https://shaisolaris.github.io/flutter-homely/

## Screens

| Screen | What it does |
| --- | --- |
| **Home** | A greeting, active-scene chips (highlighting whichever scene currently matches live device state), a 4-room overview grid, and quick controls for the most-used devices - a couple of lights with dimmers, the living room thermostat, and both door locks. |
| **Room detail** | Every device in one room, grouped by type (lights, thermostat, locks, plugs), each with its full control card. Opened by tapping a room card on Home. |
| **Scenes & Automations** | One-tap scene presets that push a whole set of device states at once, with an "Active" badge when the current state already matches. Below that, "if this, then that" automations with an enable switch and a manual "Test now" button that evaluates the rule against live device state right away. |
| **Energy** | This-week and today usage totals with an estimated dollar cost, a hand-drawn bar chart of kWh by room, and a ranked breakdown with share-of-total bars. |

Navigation is a bottom bar with three tabs: **Home**, **Scenes**, **Energy**.

## Architecture

```
lib/
  main.dart                  Entry point - loads SharedPreferences, wires ProviderScope
  app.dart                   MaterialApp, Material 3 theme (light + dark), bottom-nav shell
  core/
    models/                  Plain, JSON-serializable data classes (Device, Room, Scene, Automation, EnergySample)
    logic/                   Pure, Flutter-free business logic (see Testing below)
    constants/                Nav tab indices, room/device/scene/automation icon + color lookups, default thermostat schedule
    widgets/                  Shared control cards (light, thermostat, lock, plug) + the type-dispatching DeviceControlTile
  data/
    home_repository.dart       Storage interface + a shared_preferences-backed implementation
    seed_data.dart              Deterministic first-run demo data (rooms, devices, scenes, automations, energy history)
    providers.dart              Riverpod providers/notifiers wiring the repository to the UI
  features/
    home/         screen + widgets   Scene chips, room grid, quick device controls
    room_detail/  screen               Full device list for one room
    scenes/       screen + widgets   Scene cards, automation cards
    energy/       screen + widgets   Stat cards, bar chart, per-room breakdown
```

State management is [flutter_riverpod]. Device state and automation enabled flags
load from - and persist back to - a small `HomeRepository` abstraction backed by
`shared_preferences`; the UI never talks to `shared_preferences` directly, which
keeps the storage layer swappable and easy to fake in tests. Rooms and scenes are
fixed reference data rebuilt on every launch - Homely has no "add a room" or
"create a scene" flow, so only what the user can actually change gets persisted.

The **scene, energy, automation, and thermostat math is pure Dart** with no Flutter
dependency - it lives entirely under `lib/core/logic/` and is exercised directly by
unit tests, independent of widgets or storage:

- `scenes.dart` - applies a scene's device-state overrides onto a device list, and
  checks whether the live device list already matches a scene (for the "Active" badge).
- `energy.dart` - aggregates kWh usage per room and in total, and turns kWh into an
  estimated dollar cost.
- `automation.dart` - evaluates a simple "if trigger, then action" rule (device
  state, time-of-day, or thermostat threshold) against live device state, and
  builds the human-readable "If X, then Y" sentence shown on each automation card.
- `thermostat.dart` - clamps a setpoint into a safe range and resolves what a daily
  schedule says the setpoint should be at a given time.

## Testing

```
test/
  core/logic/
    thermostat_test.dart      Clamping, +/- adjustment, and schedule resolution (including the overnight wrap-around)
    scenes_test.dart          Applying overrides, unknown-device handling, and "is this scene active" detection
    automation_test.dart      Every trigger type, every action type, enabled/disabled gating, and the human-readable descriptions
    energy_test.dart          Per-room aggregation, sorting, percentage math, and the divide-by-zero guard
  data/
    seed_data_test.dart       The seeded rooms/devices/scenes/automations/energy history are internally
                               consistent and deterministic, with a full hand-summed energy trace
  widget_test.dart            App launches, room navigation, scene application, automation listing,
                               the energy chart, and toggling a device all work end to end
```

Every pure-logic test asserts a **hand-traced expected value** - for example, the
seeded week's living-room energy total (`4.2+3.8+4.5+4.0+4.8+6.1+5.7 = 33.1` kWh) is
summed by hand in `seed_data_test.dart`'s comments, not just checked against
whatever the function happens to return.

```bash
flutter test
```

## Run it

```bash
flutter pub get
flutter run                          # any connected device/simulator
flutter run -d chrome                # web
flutter build web --base-href /flutter-homely/
```

## Tech stack

- Flutter 3.24+, null-safe Dart, Material 3 (seed color `#0F766E`, light + dark)
- [flutter_riverpod] for state management
- `shared_preferences` for local, on-device persistence
- A hand-drawn `CustomPainter` bar chart on Energy - zero third-party charting or UI dependencies

[flutter_riverpod]: https://pub.dev/packages/flutter_riverpod

## License

MIT - see [LICENSE](LICENSE).

---

Author: **Shai**
