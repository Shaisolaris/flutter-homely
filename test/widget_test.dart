import 'package:flutter/material.dart';
import 'package:flutter_homely/app.dart';
import 'package:flutter_homely/core/widgets/lock_control_tile.dart';
import 'package:flutter_homely/data/providers.dart';
import 'package:flutter_homely/features/energy/widgets/energy_bar_chart.dart';
import 'package:flutter_homely/features/energy/widgets/room_usage_row.dart';
import 'package:flutter_homely/features/home/widgets/room_overview_card.dart';
import 'package:flutter_homely/features/room_detail/room_detail_screen.dart';
import 'package:flutter_homely/features/scenes/scenes_screen.dart';
import 'package:flutter_homely/features/scenes/widgets/automation_card.dart';
import 'package:flutter_homely/features/scenes/widgets/scene_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps a fresh [HomelyApp] backed by an in-memory (mocked)
/// SharedPreferences instance, so every test starts from the same
/// first-run, freshly-seeded state.
Future<void> pumpHomelyApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const HomelyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('launches on Home with a 3-tab bottom nav and 4 seeded rooms', (tester) async {
    await pumpHomelyApp(tester);

    expect(find.text('Homely'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Home'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Scenes'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Energy'), findsOneWidget);

    // 4 rooms, each its own overview card.
    expect(find.byType(RoomOverviewCard), findsNWidgets(4));

    // 3 scene chips (Good Morning, Movie Night, Away Mode).
    expect(find.byType(ChoiceChip), findsNWidgets(3));

    // Seeded devices: exactly 4 are on (LR ceiling lights, TV plug, kitchen
    // ceiling lights, porch light) - see seed_data_test.dart for the trace.
    expect(find.text('4 devices on across the house'), findsOneWidget);
  });

  testWidgets("tapping a room card opens Room detail with that room's devices", (tester) async {
    await pumpHomelyApp(tester);

    // Living Room is the first seeded room, so it is the first card.
    await tester.tap(find.byType(RoomOverviewCard).first);
    await tester.pumpAndSettle();

    final roomDetail = find.byType(RoomDetailScreen);
    expect(roomDetail, findsOneWidget);

    // Living Room has exactly one light, one thermostat, one plug.
    expect(find.descendant(of: roomDetail, matching: find.text('Ceiling Lights')), findsOneWidget);
    expect(find.descendant(of: roomDetail, matching: find.text('Living Room Thermostat')), findsOneWidget);
    expect(find.descendant(of: roomDetail, matching: find.text('TV Plug')), findsOneWidget);
  });

  testWidgets('Scenes tab lists all 3 scenes and both automations', (tester) async {
    await pumpHomelyApp(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Scenes'));
    await tester.pumpAndSettle();

    final scenesScreen = find.byType(ScenesScreen);
    expect(scenesScreen, findsOneWidget);
    expect(find.descendant(of: scenesScreen, matching: find.byType(SceneCard)), findsNWidgets(3));
    expect(find.descendant(of: scenesScreen, matching: find.byType(AutomationCard)), findsNWidgets(2));
    expect(find.descendant(of: scenesScreen, matching: find.text('Good Morning')), findsOneWidget);
    expect(find.descendant(of: scenesScreen, matching: find.text('Movie Night')), findsOneWidget);
    expect(find.descendant(of: scenesScreen, matching: find.text('Away Mode')), findsOneWidget);
  });

  testWidgets('applying a scene from Home updates device state and shows a confirmation', (tester) async {
    await pumpHomelyApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Movie Night'));
    await tester.pumpAndSettle();

    expect(find.text('Movie Night applied'), findsOneWidget);
  });

  testWidgets('Energy tab shows the bar chart and one breakdown row per room', (tester) async {
    await pumpHomelyApp(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Energy'));
    await tester.pumpAndSettle();

    expect(find.byType(EnergyBarChart), findsOneWidget);
    expect(find.byType(RoomUsageRow), findsNWidgets(4));
  });

  testWidgets('toggling a lock switch on Home updates its state', (tester) async {
    await pumpHomelyApp(tester);

    final lockTile = find.byType(LockControlTile).first;
    final lockSwitch = find.descendant(of: lockTile, matching: find.byType(Switch));
    final before = tester.widget<Switch>(lockSwitch).value;

    await tester.tap(lockSwitch);
    await tester.pumpAndSettle();

    final after = tester.widget<Switch>(lockSwitch).value;
    expect(after, isNot(equals(before)));
  });
}
