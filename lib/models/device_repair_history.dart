import 'package:flutter/foundation.dart';

@immutable
class DeviceRepairHistoryEntry {
  const DeviceRepairHistoryEntry({
    required this.date,
    required this.technicianName,
    required this.technicianId,
    required this.phoneNumber,
    required this.problem,
    required this.remarks,
    required this.repairDuration,
    this.startTime,
  });

  /// Completion time (end of repair).
  final DateTime date;
  final String technicianName;
  final String technicianId;
  final String phoneNumber;
  final String problem;
  final String remarks;
  final Duration repairDuration;
  final DateTime? startTime;

  DateTime get endTime => date;

  DateTime get repairStartTime =>
      startTime ?? date.subtract(repairDuration);

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'technicianName': technicianName,
        'technicianId': technicianId,
        'phoneNumber': phoneNumber,
        'problem': problem,
        'remarks': remarks,
        'repairDurationMs': repairDuration.inMilliseconds,
        'startTime': startTime?.toIso8601String(),
      };

  factory DeviceRepairHistoryEntry.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);
    final duration = Duration(
      milliseconds: (json['repairDurationMs'] as num?)?.toInt() ?? 0,
    );
    return DeviceRepairHistoryEntry(
      date: date,
      technicianName: json['technicianName'] as String? ?? '',
      technicianId: json['technicianId'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      problem: json['problem'] as String? ?? '',
      remarks: json['remarks'] as String? ?? '',
      repairDuration: duration,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
    );
  }
}
