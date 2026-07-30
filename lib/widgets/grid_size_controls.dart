import 'package:flutter/material.dart';
import 'package:hello_flutter/constants/layout_constants.dart';
import 'package:hello_flutter/theme/app_palette.dart';

class GridSizeControls extends StatelessWidget {
  const GridSizeControls({
    super.key,
    required this.rows,
    required this.cols,
    required this.onRowsChanged,
    required this.onColsChanged,
  });

  final int rows;
  final int cols;
  final ValueChanged<int> onRowsChanged;
  final ValueChanged<int> onColsChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceElevated.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lab Size',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            _AxisControls(
              label: 'Rows',
              value: rows,
              onIncrement: () => onRowsChanged(rows + 1),
              onDecrement: () => onRowsChanged(rows - 1),
              canIncrement: rows < LayoutConstants.maxGridSize,
              canDecrement: rows > LayoutConstants.minGridSize,
            ),
            const SizedBox(height: 8),
            _AxisControls(
              label: 'Columns',
              value: cols,
              onIncrement: () => onColsChanged(cols + 1),
              onDecrement: () => onColsChanged(cols - 1),
              canIncrement: cols < LayoutConstants.maxGridSize,
              canDecrement: cols > LayoutConstants.minGridSize,
            ),
          ],
        ),
      ),
    );
  }
}

class _AxisControls extends StatelessWidget {
  const _AxisControls({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    required this.canIncrement,
    required this.canDecrement,
  });

  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canIncrement;
  final bool canDecrement;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(color: palette.textSecondary, fontSize: 12),
          ),
        ),
        _ControlButton(
          icon: Icons.remove_rounded,
          onPressed: canDecrement ? onDecrement : null,
        ),
        Container(
          width: 36,
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _ControlButton(
          icon: Icons.add_rounded,
          onPressed: canIncrement ? onIncrement : null,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: onPressed == null
                ? palette.textSecondary.withValues(alpha: 0.35)
                : palette.accent,
          ),
        ),
      ),
    );
  }
}
