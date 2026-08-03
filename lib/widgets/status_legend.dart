import 'package:flutter/material.dart';
import 'package:hello_flutter/theme/app_palette.dart';

class StatusLegend extends StatelessWidget {
  const StatusLegend({
    super.key,
    this.workingCount = 0,
    this.reportedCount = 0,
    this.underRepairCount = 0,
  });

  final int workingCount;
  final int reportedCount;
  final int underRepairCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusBadge(
          palette: palette,
          label: 'Working',
          count: workingCount,
          color: palette.working,
        ),
        const SizedBox(height: 6),
        _StatusBadge(
          palette: palette,
          label: 'Reported',
          count: reportedCount,
          color: palette.defective,
        ),
        const SizedBox(height: 6),
        _StatusBadge(
          palette: palette,
          label: 'Under Repair',
          count: underRepairCount,
          color: palette.underRepair,
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.palette,
    required this.label,
    required this.count,
    required this.color,
  });

  final AppPalette palette;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
