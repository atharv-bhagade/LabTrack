import 'package:hello_flutter/models/floor.dart';
import 'package:hello_flutter/models/room.dart';

class FloorWizardInput {
  const FloorWizardInput({
    required this.floorNumber,
    required this.name,
    required this.roomCount,
  });

  final int floorNumber;
  final String name;
  final int roomCount;
}

abstract final class BuildingWizardService {
  static String labRoomName(int floorNumber, int roomIndexOneBased) {
    final code = floorNumber * 100 + roomIndexOneBased;
    return 'Lab $code';
  }

  static List<Floor> buildFloors({
    required List<FloorWizardInput> inputs,
    required String Function(String prefix) newId,
  }) {
    return inputs.map((input) {
      final rooms = List<Room>.generate(input.roomCount, (index) {
        final roomIndex = index + 1;
        return Room(
          id: newId('room'),
          name: labRoomName(input.floorNumber, roomIndex),
        );
      });

      return Floor(
        id: newId('floor'),
        name: input.name,
        rooms: rooms,
      );
    }).toList();
  }
}
