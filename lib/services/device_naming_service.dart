import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_type.dart';
import 'package:hello_flutter/utils/device_type_info.dart';

class DeviceNamingService {
  String nextDefaultName(
    DeviceType type,
    Map<DeviceType, int> counters,
  ) {
    final nextCount = (counters[type] ?? 0) + 1;
    counters[type] = nextCount;
    return '${DeviceTypeInfo.defaultNamePrefix(type)} $nextCount';
  }

  Map<DeviceType, int> recalculateCounters(Iterable<Device> devices) {
    final counters = {
      for (final type in DeviceType.values) type: 0,
    };

    for (final type in DeviceType.values) {
      final prefix = DeviceTypeInfo.defaultNamePrefix(type);
      final pattern = RegExp('^$prefix (\\d+)\$');

      for (final device in devices) {
        if (device.type != type) continue;
        final match = pattern.firstMatch(device.name);
        if (match != null) {
          final number = int.tryParse(match.group(1) ?? '') ?? 0;
          if (number > counters[type]!) {
            counters[type] = number;
          }
        }
      }
    }

    return counters;
  }
} 