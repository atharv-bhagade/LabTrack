import 'package:flutter/material.dart';
import 'package:hello_flutter/models/device_type.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/utils/device_type_info.dart';

class ToolboxDraggableItem extends StatelessWidget {
  const ToolboxDraggableItem({
    super.key,
    required this.type,
    required this.compact,
  });

  final DeviceType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Draggable<DeviceType>(
      data: type,
      feedback: Material(
        color: Colors.transparent,
        child: _DragFeedback(type: type),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _ToolboxTile(type: type, compact: compact),
      ),
      child: _ToolboxTile(type: type, compact: compact),
    );
  }
}

class _ToolboxTile extends StatelessWidget {
  const _ToolboxTile({
    required this.type,
    required this.compact,
  });

  final DeviceType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: compact ? 72 : 88,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.borderSubtle),
      ),
      child: compact
          ? Icon(
              DeviceTypeInfo.icon(type),
              color: palette.accent,
              size: 24,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  DeviceTypeInfo.icon(type),
                  color: palette.accent,
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  DeviceTypeInfo.label(type),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
    );
  }
}

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.type});

  final DeviceType type;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Transform.scale(
      scale: 1.08,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.accent.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: palette.accent.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                DeviceTypeInfo.icon(type),
                color: palette.accent,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                DeviceTypeInfo.label(type),
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
