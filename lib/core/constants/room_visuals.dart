import 'package:flutter/material.dart';

import '../models/room.dart';

/// The icon that best represents [type], used on room cards and the Room
/// detail app bar.
IconData roomIconFor(RoomType type) {
  switch (type) {
    case RoomType.livingRoom:
      return Icons.weekend_outlined;
    case RoomType.bedroom:
      return Icons.bed_outlined;
    case RoomType.kitchen:
      return Icons.kitchen_outlined;
    case RoomType.entryway:
      return Icons.meeting_room_outlined;
  }
}

/// A stable accent color per room type, cycling through a small palette so
/// every room reads distinctly without clashing with the app's deep-teal
/// seed color.
const List<Color> roomAccentPalette = <Color>[
  Color(0xFF0F766E), // deep teal (living room)
  Color(0xFF7C3AED), // violet (bedroom)
  Color(0xFFF59E0B), // amber (kitchen)
  Color(0xFF0EA5E9), // sky (entryway)
];

Color roomAccentFor(RoomType type) => roomAccentPalette[type.index % roomAccentPalette.length];
