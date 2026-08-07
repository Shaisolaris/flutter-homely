import 'package:flutter/material.dart';

import '../../../core/constants/scene_visuals.dart';
import '../../../core/models/scene.dart';

/// A single scene: icon, name, description, an "Active" badge when every
/// device it references already matches, and an Apply button.
class SceneCard extends StatelessWidget {
  const SceneCard({super.key, required this.scene, required this.isActive, required this.onApply});

  final Scene scene;
  final bool isActive;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = sceneColorFor(scene.icon);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: accent.withValues(alpha: 0.15),
              foregroundColor: accent,
              child: Icon(sceneIconFor(scene.icon)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scene.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(color: scheme.primary, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scene.description,
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(onPressed: onApply, child: const Text('Apply')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
