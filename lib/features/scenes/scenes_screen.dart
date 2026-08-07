import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/automation_rule.dart';
import '../../core/models/device.dart';
import '../../core/models/scene.dart';
import '../../core/widgets/section_header.dart';
import '../../data/providers.dart';
import 'widgets/automation_card.dart';
import 'widgets/scene_card.dart';

/// Scenes & Automations screen: one-tap scene presets up top, "if this then
/// that" automations (with enable toggles and a manual test button) below.
class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(scenesProvider);
    final devicesAsync = ref.watch(devicesProvider);
    final automationsAsync = ref.watch(automationsProvider);
    final activeSceneIds = ref.watch(activeSceneIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scenes & Automations')),
      body: devicesAsync.when(
        data: (devices) => automationsAsync.when(
          data: (automations) => _ScenesAndAutomationsList(
            scenes: scenes,
            devices: devices,
            automations: automations,
            activeSceneIds: activeSceneIds,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Could not load automations: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Could not load devices: $error')),
      ),
    );
  }
}

class _ScenesAndAutomationsList extends ConsumerWidget {
  const _ScenesAndAutomationsList({
    required this.scenes,
    required this.devices,
    required this.automations,
    required this.activeSceneIds,
  });

  final List<Scene> scenes;
  final List<Device> devices;
  final List<Automation> automations;
  final Set<String> activeSceneIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: <Widget>[
        const SectionHeader(title: 'Scenes', subtitle: 'Apply a full set of device states in one tap.'),
        for (final scene in scenes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SceneCard(
              scene: scene,
              isActive: activeSceneIds.contains(scene.id),
              onApply: () => _applyScene(context, ref, scene),
            ),
          ),
        const SectionHeader(
          title: 'Automations',
          subtitle: 'If this happens, Homely does that automatically.',
        ),
        for (final automation in automations)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AutomationCard(
              automation: automation,
              devices: devices,
              onEnabledChanged: (enabled) =>
                  ref.read(automationsProvider.notifier).setEnabled(automation.id, enabled),
              onTest: () => _testAutomation(context, ref, automation),
            ),
          ),
      ],
    );
  }

  Future<void> _applyScene(BuildContext context, WidgetRef ref, Scene scene) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(devicesProvider.notifier).activateScene(scene);
    messenger.showSnackBar(SnackBar(content: Text('${scene.name} applied')));
  }

  Future<void> _testAutomation(BuildContext context, WidgetRef ref, Automation automation) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!automation.enabled) {
      messenger.showSnackBar(SnackBar(content: Text('Enable "${automation.name}" first')));
      return;
    }
    final fired = await ref.read(devicesProvider.notifier).testAutomation(automation, DateTime.now());
    messenger.showSnackBar(
      SnackBar(content: Text(fired ? '${automation.name} fired' : 'Trigger not met yet - nothing happened')),
    );
  }
}
