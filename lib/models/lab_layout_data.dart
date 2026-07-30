import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_type.dart';

class LabLayoutData {
  const LabLayoutData({
    required this.rows,
    required this.cols,
    required this.devices,
    required this.typeCounters,
    required this.nextDeviceId,
  });

  final int rows;
  final int cols;
  final List<Device> devices;
  final Map<DeviceType, int> typeCounters;
  final int nextDeviceId;

  factory LabLayoutData.initial() {
    return LabLayoutData(
      rows: 8,
      cols: 8,
      devices: const [],
      typeCounters: {for (final type in DeviceType.values) type: 0},
      nextDeviceId: 1,
    );
  }

  LabLayoutData copyWith({
    int? rows,
    int? cols,
    List<Device>? devices,
    Map<DeviceType, int>? typeCounters,
    int? nextDeviceId,
  }) {
    return LabLayoutData(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      devices: devices ?? this.devices,
      typeCounters: typeCounters ?? this.typeCounters,
      nextDeviceId: nextDeviceId ?? this.nextDeviceId,
    );
  }

  Map<String, dynamic> toJson() => {
        'rows': rows,
        'cols': cols,
        'nextDeviceId': nextDeviceId,
        'typeCounters': {
          for (final entry in typeCounters.entries)
            entry.key.name: entry.value,
        },
        'devices': devices.map((device) => device.toJson()).toList(),
      };

  factory LabLayoutData.fromJson(Map<String, dynamic> json) {
    final countersJson =
        (json['typeCounters'] as Map<String, dynamic>?) ?? const {};
    final counters = {
      for (final type in DeviceType.values)
        type: (countersJson[type.name] as num?)?.toInt() ?? 0,
    };

    final devicesJson = (json['devices'] as List<dynamic>?) ?? const [];
    return LabLayoutData(
      rows: (json['rows'] as num?)?.toInt() ?? 8,
      cols: (json['cols'] as num?)?.toInt() ?? 8,
      nextDeviceId: (json['nextDeviceId'] as num?)?.toInt() ?? 1,
      typeCounters: counters,
      devices: devicesJson
          .whereType<Map<String, dynamic>>()
          .map(Device.fromJson)
          .toList(),
    );
  }
}
