import 'package:flutter/material.dart';
import 'package:hello_flutter/models/device_type.dart';

abstract final class DeviceTypeInfo {
  static IconData icon(DeviceType type) => switch (type) {
        DeviceType.desktop => Icons.desktop_windows_rounded,
        DeviceType.laptop => Icons.laptop_mac_rounded,
        DeviceType.printer => Icons.print_rounded,
        DeviceType.ac => Icons.ac_unit_rounded,
      };

  static String label(DeviceType type) => switch (type) {
        DeviceType.desktop => 'Desktop PC',
        DeviceType.laptop => 'Laptop',
        DeviceType.printer => 'Printer',
        DeviceType.ac => 'AC',
      };

  static String defaultNamePrefix(DeviceType type) => switch (type) {
        DeviceType.desktop => 'Desktop',
        DeviceType.laptop => 'Laptop',
        DeviceType.printer => 'Printer',
        DeviceType.ac => 'AC',
      };

  static const toolboxTypes = DeviceType.values;
}
