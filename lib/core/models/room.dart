/// The physical space a [Device] belongs to. Drives which icon and accent
/// color represent the room across Home, Room detail, and Energy.
enum RoomType { livingRoom, bedroom, kitchen, entryway }

extension RoomTypeLabel on RoomType {
  String get label => switch (this) {
        RoomType.livingRoom => 'Living Room',
        RoomType.bedroom => 'Bedroom',
        RoomType.kitchen => 'Kitchen',
        RoomType.entryway => 'Entryway',
      };
}

/// A room in the home.
///
/// Rooms are fixed reference data (see `data/seed_data.dart`) - Homely has
/// no "add a room" flow, so this model has no `copyWith` or JSON
/// persistence; it is simply rebuilt fresh on every app start via
/// `seedRooms()`.
class Room {
  const Room({required this.id, required this.name, required this.type});

  final String id;
  final String name;
  final RoomType type;

  @override
  String toString() => 'Room($id, $name)';
}
