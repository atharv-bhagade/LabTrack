import 'package:flutter/material.dart';
import 'package:hello_flutter/models/device_status.dart';
import 'package:hello_flutter/theme/app_palette.dart';

abstract final class DeviceStatusColors {
  static Color borderColor(AppPalette palette, DeviceStatus status) =>
      switch (status) {
        DeviceStatus.working => palette.working,
        DeviceStatus.defective => palette.defective,
        DeviceStatus.underRepair => palette.underRepair,
      };

  static Color iconColor(AppPalette palette, DeviceStatus status) =>
      switch (status) {
        DeviceStatus.working => palette.working,
        DeviceStatus.defective => palette.defective,
        DeviceStatus.underRepair => palette.underRepair,
      };

  static Color badgeBackground(AppPalette palette, DeviceStatus status) =>
      borderColor(palette, status).withValues(alpha: 0.18);

  static Color badgeForeground(AppPalette palette, DeviceStatus status) =>
      borderColor(palette, status);

  static String label(DeviceStatus status) => switch (status) {
        DeviceStatus.working => 'Working',
        DeviceStatus.defective => 'Reported',
        DeviceStatus.underRepair => 'Under Repair',
      };

  static IconData icon(DeviceStatus status) => switch (status) {
        DeviceStatus.working => Icons.check_circle_outline_rounded,
        DeviceStatus.defective => Icons.error_outline_rounded,
        DeviceStatus.underRepair => Icons.build_circle_outlined,
      };
}
