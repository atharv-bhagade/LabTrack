import 'package:flutter/foundation.dart';
import 'package:hello_flutter/models/room.dart';

@immutable
class Floor {
  const Floor({
    required this.id,
    required this.name,
    required this.rooms,
  });

  final String id;
  final String name;
  final List<Room> rooms;

  Floor copyWith({
    String? id,
    String? name,
    List<Room>? rooms,
  }) {
    return Floor(
      id: id ?? this.id,
      name: name ?? this.name,
      rooms: rooms ?? this.rooms,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rooms': rooms.map((room) => room.toJson()).toList(),
      };

  factory Floor.fromJson(Map<String, dynamic> json) {
    final roomsJson = (json['rooms'] as List<dynamic>?) ?? const [];
    return Floor(
      id: json['id'] as String,
      name: json['name'] as String,
      rooms: roomsJson
          .whereType<Map<String, dynamic>>()
          .map(Room.fromJson)
          .toList(),
    );
  }
}
