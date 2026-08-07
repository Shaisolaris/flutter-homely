import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/scene_visuals.dart';
import '../../../data/providers.dart';

/// A horizontal row of scene chips. Whichever scene(s) currently match live
/// device state render as selected; tapping any chip applies that scene.
class SceneChipRow extends ConsumerWidget {
  const SceneChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(scenesProvider);
    final activeSceneIds = ref.watch(activeSceneIdsProvider);

    if (scenes.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: scenes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final scene = scenes[index];
          final isActive = activeSceneIds.contains(scene.id);
          return ChoiceChip(
            avatar: Icon(sceneIconFor(scene.icon), size: 18),
            label: Text(scene.name),
            selected: isActive,
            onSelected: (_) async {
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(devicesProvider.notifier).activateScene(scene);
              messenger.showSnackBar(SnackBar(content: Text('${scene.name} applied')));
            },
          );
        },
      ),
    );
  }
}
