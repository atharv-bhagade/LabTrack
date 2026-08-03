import 'package:flutter/material.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/utils/device_status_colors.dart';
import 'package:hello_flutter/utils/device_type_info.dart';

class GridDevice extends StatelessWidget {
  const GridDevice({
    super.key,
    required this.device,
    required this.isRemoving,
    required this.isPlacing,
    required this.onTap,
  });

  final Device device;
  final bool isRemoving;
  final bool isPlacing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final statusColor = DeviceStatusColors.borderColor(palette, device.status);

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: device.name,
        waitDuration: const Duration(milliseconds: 400),
        child: AnimatedScale(
          scale: isRemoving ? 0.2 : isPlacing ? 1.05 : 1,
          duration: const Duration(milliseconds: 280),
          curve: isRemoving ? Curves.easeInBack : Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: isRemoving ? 0 : 1,
            duration: const Duration(milliseconds: 240),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.65),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  DeviceTypeInfo.icon(device.type),
                  color: DeviceStatusColors.iconColor(palette, device.status),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
