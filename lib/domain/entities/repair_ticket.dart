import 'package:flutter/foundation.dart';
import 'package:hello_flutter/models/device_type.dart';

enum RepairStatus {
  available,
  accepted,
  underRepair,
  completed;

  String get label => switch (this) {
        RepairStatus.available => 'Available',
        RepairStatus.accepted => 'Accepted',
        RepairStatus.underRepair => 'Under Repair',
        RepairStatus.completed => 'Completed',
      };

  static RepairStatus fromJson(String value) => switch (value) {
        'accepted' => RepairStatus.accepted,
        'underRepair' => RepairStatus.underRepair,
        'completed' => RepairStatus.completed,
        'assigned' => RepairStatus.accepted,
        'inProgress' => RepairStatus.underRepair,
        'pending' => RepairStatus.available,
        'rejected' => RepairStatus.available,
        'available' => RepairStatus.available,
        _ => RepairStatus.available,
      };

  String toJson() => name;
}

@immutable
class RepairTicket {
  const RepairTicket({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.roomId,
    required this.roomName,
    required this.floorName,
    required this.buildingName,
    required this.faultDescription,
    required this.status,
    required this.reportedAt,
    required this.reportedBy,
    required this.reportedByName,
    this.acceptedBy,
    this.acceptedByName,
    this.acceptedTime,
    this.acceptedByPhone,
    this.completedTime,
    this.completedByName,
    this.completedByPhone,
    this.repairNotes = '',
  });

  final String id;
  final String deviceId;
  final String deviceName;
  final DeviceType deviceType;
  final String roomId;
  final String roomName;
  final String floorName;
  final String buildingName;
  final String faultDescription;
  final RepairStatus status;
  final DateTime reportedAt;
  final String reportedBy;
  final String reportedByName;
  final String? acceptedBy;
  final String? acceptedByName;
  final DateTime? acceptedTime;
  final String? acceptedByPhone;
  final DateTime? completedTime;
  final String? completedByName;
  final String? completedByPhone;
  final String repairNotes;

  bool get isAvailable => status == RepairStatus.available && acceptedBy == null;

  RepairTicket copyWith({
    String? id,
    String? deviceId,
    String? deviceName,
    DeviceType? deviceType,
    String? roomId,
    String? roomName,
    String? floorName,
    String? buildingName,
    String? faultDescription,
    RepairStatus? status,
    DateTime? reportedAt,
    String? reportedBy,
    String? reportedByName,
    String? acceptedBy,
    String? acceptedByName,
    DateTime? acceptedTime,
    String? acceptedByPhone,
    DateTime? completedTime,
    String? completedByName,
    String? completedByPhone,
    String? repairNotes,
    bool clearAcceptance = false,
    bool clearCompletion = false,
  }) {
    return RepairTicket(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      floorName: floorName ?? this.floorName,
      buildingName: buildingName ?? this.buildingName,
      faultDescription: faultDescription ?? this.faultDescription,
      status: status ?? this.status,
      reportedAt: reportedAt ?? this.reportedAt,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedByName: reportedByName ?? this.reportedByName,
      acceptedBy: clearAcceptance ? null : (acceptedBy ?? this.acceptedBy),
      acceptedByName:
          clearAcceptance ? null : (acceptedByName ?? this.acceptedByName),
      acceptedTime:
          clearAcceptance ? null : (acceptedTime ?? this.acceptedTime),
      acceptedByPhone:
          clearAcceptance ? null : (acceptedByPhone ?? this.acceptedByPhone),
      completedTime:
          clearCompletion ? null : (completedTime ?? this.completedTime),
      completedByName:
          clearCompletion ? null : (completedByName ?? this.completedByName),
      completedByPhone:
          clearCompletion ? null : (completedByPhone ?? this.completedByPhone),
      repairNotes: repairNotes ?? this.repairNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceId': deviceId,
        'deviceName': deviceName,
        'deviceType': deviceType.name,
        'roomId': roomId,
        'roomName': roomName,
        'floorName': floorName,
        'buildingName': buildingName,
        'faultDescription': faultDescription,
        'status': status.toJson(),
        'reportedAt': reportedAt.toIso8601String(),
        'reportedBy': reportedBy,
        'reportedByName': reportedByName,
        'acceptedBy': acceptedBy,
        'acceptedByName': acceptedByName,
        'acceptedTime': acceptedTime?.toIso8601String(),
        'acceptedByPhone': acceptedByPhone,
        'completedTime': completedTime?.toIso8601String(),
        'completedByName': completedByName,
        'completedByPhone': completedByPhone,
        'repairNotes': repairNotes,
        'assignedTechnicianId': acceptedBy,
      };

  factory RepairTicket.fromJson(Map<String, dynamic> json) {
    final deviceTypeRaw = json['deviceType'] as String?;
    return RepairTicket(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String? ?? '',
      deviceName: json['deviceName'] as String,
      deviceType: deviceTypeRaw == null
          ? DeviceType.desktop
          : DeviceType.values.byName(deviceTypeRaw),
      roomId: json['roomId'] as String? ?? '',
      roomName: json['roomName'] as String,
      floorName: json['floorName'] as String? ?? '',
      buildingName: json['buildingName'] as String,
      faultDescription: json['faultDescription'] as String? ?? '',
      status: RepairStatus.fromJson(json['status'] as String? ?? 'pending'),
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      reportedBy: json['reportedBy'] as String? ?? 'SYSTEM',
      reportedByName: json['reportedByName'] as String? ?? 'System',
      acceptedBy: json['acceptedBy'] as String? ??
          json['assignedTechnicianId'] as String?,
      acceptedByName: json['acceptedByName'] as String?,
      acceptedTime: json['acceptedTime'] != null
          ? DateTime.parse(json['acceptedTime'] as String)
          : null,
      acceptedByPhone: json['acceptedByPhone'] as String?,
      completedTime: json['completedTime'] != null
          ? DateTime.parse(json['completedTime'] as String)
          : null,
      completedByName: json['completedByName'] as String?,
      completedByPhone: json['completedByPhone'] as String?,
      repairNotes: json['repairNotes'] as String? ?? '',
    );
  }
}
