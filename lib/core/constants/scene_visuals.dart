import 'package:flutter/material.dart';

import '../models/scene.dart';

/// The glyph shown on a scene's chip/card avatar.
IconData sceneIconFor(SceneIcon icon) {
  switch (icon) {
    case SceneIcon.morning:
      return Icons.wb_sunny;
    case SceneIcon.movie:
      return Icons.movie;
    case SceneIcon.away:
      return Icons.flight_takeoff;
  }
}

/// A stable accent color per scene icon, used for the scene's avatar
/// background.
Color sceneColorFor(SceneIcon icon) {
  switch (icon) {
    case SceneIcon.morning:
      return const Color(0xFFF59E0B); // amber
    case SceneIcon.movie:
      return const Color(0xFF7C3AED); // violet
    case SceneIcon.away:
      return const Color(0xFF0EA5E9); // sky
  }
}
