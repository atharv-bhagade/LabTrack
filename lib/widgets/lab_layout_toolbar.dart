import 'package:flutter/material.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_status.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/widgets/grid_size_controls.dart';
import 'package:hello_flutter/widgets/status_legend.dart';

class LabLayoutToolbar extends StatelessWidget {
  const LabLayoutToolbar({
    super.key,
    required this.rows,
    required this.cols,
    required this.devices,
    required this.onRowsChanged,
    required this.onColsChanged,
    this.readOnly = false,
    this.onClearLayout,
  });

  final int rows;
  final int cols;
  final List<Device> devices;
  final ValueChanged<int> onRowsChanged;
  final ValueChanged<int> onColsChanged;
  final bool readOnly;
  final VoidCallback? onClearLayout;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final workingCount =
        devices.where((d) => d.status == DeviceStatus.working).length;
    final reportedCount =
        devices.where((d) => d.status == DeviceStatus.defective).length;
    final underRepairCount =
        devices.where((d) => d.status == DeviceStatus.underRepair).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 400;

        final statusPanel = ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: narrow ? constraints.maxWidth * 0.42 : 168,
            minWidth: 120,
          ),
          child: StatusLegend(
            workingCount: workingCount,
            reportedCount: reportedCount,
            underRepairCount: underRepairCount,
          ),
        );

        if (readOnly) {
          return Align(
            alignment: Alignment.centerRight,
            child: statusPanel,
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GridSizeControls(
                      rows: rows,
                      cols: cols,
                      onRowsChanged: onRowsChanged,
                      onColsChanged: onColsChanged,
                    ),
                    if (onClearLayout != null) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: onClearLayout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.defective,
                          side: BorderSide(
                            color: palette.defective.withValues(alpha: 0.45),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.layers_clear_outlined, size: 18),
                        label: const Text('Clear Layout'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              statusPanel,
            ],
          ),
        );
      },
    );
  }
}
