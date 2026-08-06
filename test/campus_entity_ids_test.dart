import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/domain/services/building_wizard_service.dart';
import 'package:hello_flutter/domain/services/campus_hierarchy_sanitizer.dart';
import 'package:hello_flutter/models/building.dart';
import 'package:hello_flutter/models/floor.dart';
import 'package:hello_flutter/models/room.dart';
import 'package:hello_flutter/utils/unique_entity_id.dart';

void main() {
  test('UniqueEntityId generates distinct values in a tight loop', () {
    final ids = List.generate(50, (_) => UniqueEntityId.generate('room'));
    expect(ids.toSet().length, ids.length);
  });

  test('BuildingWizardService assigns unique room ids per floor', () {
    final floors = BuildingWizardService.buildFloors(
      inputs: [
        const FloorWizardInput(floorNumber: 1, name: 'Floor 1', roomCount: 12),
        const FloorWizardInput(floorNumber: 2, name: 'Floor 2', roomCount: 8),
      ],
      newId: UniqueEntityId.generate,
    );

    final roomIds = floors.expand((floor) => floor.rooms).map((r) => r.id);
    final floorIds = floors.map((f) => f.id);

    expect(roomIds.length, 20);
    expect(roomIds.toSet().length, 20);
    expect(floorIds.toSet().length, 2);
  });

  test('CampusHierarchySanitizer repairs duplicate room ids on load', () async {
    const duplicateId = 'room_duplicate_test';
    final buildings = [
      Building(
        id: 'building_1',
        name: 'B1',
        floors: [
          Floor(
            id: 'floor_1',
            name: 'F1',
            rooms: [
              Room(id: duplicateId, name: 'Lab 101'),
              Room(id: duplicateId, name: 'Lab 102'),
            ],
          ),
        ],
      ),
    ];

    final result = await CampusHierarchySanitizer.sanitize(buildings: buildings);
    expect(result.repaired, isTrue);

    final ids = result.buildings
        .expand((b) => b.floors)
        .expand((f) => f.rooms)
        .map((r) => r.id)
        .toList();
    expect(ids.length, 2);
    expect(ids.toSet().length, 2);
    expect(ids.contains(duplicateId), isTrue);
  });
}
