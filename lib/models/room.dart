import 'package:flutter/foundation.dart';
import 'package:hello_flutter/constants/layout_constants.dart';

@immutable
class Room {
  const Room({
    required this.id,
    required this.name,
    this.rows = LayoutConstants.defaultGridSize,
    this.columns = LayoutConstants.defaultGridSize,
  });

  final String id;
  final String name;
  final int rows;
  final int columns;

  Room copyWith({
    String? id,
    String? name,
    int? rows,
    int? columns,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rows': rows,
        'columns': columns,
      };

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
      rows: (json['rows'] as num?)?.toInt() ??
          LayoutConstants.defaultGridSize,
      columns: (json['columns'] as num?)?.toInt() ??
          LayoutConstants.defaultGridSize,
    );
  }
}
