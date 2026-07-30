import 'package:flutter/material.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_status.dart';
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
  });

  final int rows;
  final int cols;
  final List<Device> devices;
  final ValueChanged<int> onRowsChanged;
  final ValueChanged<int> onColsChanged;

  @override
  Widget build(BuildContext context) {
    final workingCount =
        devices.where((d) => d.status == DeviceStatus.working).length;
    final nonWorkingCount = devices.length - workingCount;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        GridSizeControls(
          rows: rows,
          cols: cols,
          onRowsChanged: onRowsChanged,
          onColsChanged: onColsChanged,
        ),
        StatusLegend(
          compact: true,
          workingCount: workingCount,
          nonWorkingCount: nonWorkingCount,
        ),
      ],
    );
  }
}
