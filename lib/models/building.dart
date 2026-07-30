import 'package:flutter/foundation.dart';
import 'package:hello_flutter/models/floor.dart';

@immutable
class Building {
  const Building({
    required this.id,
    required this.name,
    required this.floors,
  });

  final String id;
  final String name;
  final List<Floor> floors;

  Building copyWith({
    String? id,
    String? name,
    List<Floor>? floors,
  }) {
    return Building(
      id: id ?? this.id,
      name: name ?? this.name,
      floors: floors ?? this.floors,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'floors': floors.map((floor) => floor.toJson()).toList(),
      };

  factory Building.fromJson(Map<String, dynamic> json) {
    final floorsJson = (json['floors'] as List<dynamic>?) ?? const [];
    return Building(
      id: json['id'] as String,
      name: json['name'] as String,
      floors: floorsJson
          .whereType<Map<String, dynamic>>()
          .map(Floor.fromJson)
          .toList(),
    );
  }

  Iterable<String> get roomIds sync* {
    for (final floor in floors) {
      for (final room in floor.rooms) {
        yield room.id;
      }
    }
  }
}
