import 'package:hello_flutter/models/device_status.dart';
import 'package:hello_flutter/models/device_type.dart';

class Device {
  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.row,
    required this.column,
    required this.status,
    required this.failureReason,
    required this.dateCreated,
    required this.lastUpdated,
  });

  final String id;
  final String name;
  final DeviceType type;
  final int row;
  final int column;
  final DeviceStatus status;
  final String failureReason;
  final DateTime dateCreated;
  final DateTime lastUpdated;

  bool get isDefective => status.isDefective;

  Device copyWith({
    String? id,
    String? name,
    DeviceType? type,
    int? row,
    int? column,
    DeviceStatus? status,
    String? failureReason,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      row: row ?? this.row,
      column: column ?? this.column,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      dateCreated: dateCreated ?? this.dateCreated,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'row': row,
        'column': column,
        'status': status.toJson(),
        'failureReason': failureReason,
        'dateCreated': dateCreated.toIso8601String(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Device',
      type: DeviceType.values.byName(json['type'] as String),
      row: (json['row'] as num).toInt(),
      column: (json['column'] as num).toInt(),
      status: DeviceStatus.fromJson(json['status'] as String? ?? 'working'),
      failureReason: json['failureReason'] as String? ?? '',
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          row == other.row &&
          column == other.column &&
          status == other.status &&
          failureReason == other.failureReason &&
          dateCreated == other.dateCreated &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        type,
        row,
        column,
        status,
        failureReason,
        dateCreated,
        lastUpdated,
      );
}
