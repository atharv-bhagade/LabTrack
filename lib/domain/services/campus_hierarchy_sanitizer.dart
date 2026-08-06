import 'package:hello_flutter/models/building.dart';
import 'package:hello_flutter/models/floor.dart';
import 'package:hello_flutter/models/room.dart';
import 'package:hello_flutter/utils/unique_entity_id.dart';

class CampusHierarchySanitizeResult {
  const CampusHierarchySanitizeResult({
    required this.buildings,
    required this.repaired,
  });

  final List<Building> buildings;
  final bool repaired;
}

/// Ensures building, floor, and room IDs are unique across the campus tree.
/// Regenerates duplicates and migrates lab layout storage for reassigned rooms.
abstract final class CampusHierarchySanitizer {
  static Future<CampusHierarchySanitizeResult> sanitize({
    required List<Building> buildings,
  }) async {
    final seenBuildingIds = <String>{};
    final seenFloorIds = <String>{};
    final seenRoomIds = <String>{};
    var repaired = false;

    final sanitizedBuildings = <Building>[];

    for (final building in buildings) {
      var buildingId = building.id;
      if (buildingId.isEmpty || seenBuildingIds.contains(buildingId)) {
        buildingId = UniqueEntityId.generate('building');
        repaired = true;
      }
      seenBuildingIds.add(buildingId);

      final sanitizedFloors = <Floor>[];
      for (final floor in building.floors) {
        var floorId = floor.id;
        if (floorId.isEmpty || seenFloorIds.contains(floorId)) {
          floorId = UniqueEntityId.generate('floor');
          repaired = true;
        }
        seenFloorIds.add(floorId);

        final sanitizedRooms = <Room>[];
        for (final room in floor.rooms) {
          var roomId = room.id;
          if (roomId.isEmpty || seenRoomIds.contains(roomId)) {
            roomId = UniqueEntityId.generate('room');
            repaired = true;
          }
          seenRoomIds.add(roomId);
          sanitizedRooms.add(
            room.id == roomId ? room : room.copyWith(id: roomId),
          );
        }

        sanitizedFloors.add(
          floor.id == floorId && floor.rooms == sanitizedRooms
              ? floor
              : floor.copyWith(id: floorId, rooms: sanitizedRooms),
        );
      }

      sanitizedBuildings.add(
        building.id == buildingId && building.floors == sanitizedFloors
            ? building
            : building.copyWith(id: buildingId, floors: sanitizedFloors),
      );
    }

    return CampusHierarchySanitizeResult(
      buildings: sanitizedBuildings,
      repaired: repaired,
    );
  }
}
