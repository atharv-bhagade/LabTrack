import 'package:flutter/material.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_type.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/widgets/grid_device.dart';

typedef DeviceDropCallback = void Function(DeviceType type, int row, int col);
typedef DeviceTapCallback = void Function(Device device);

class RoomGrid extends StatefulWidget {
  const RoomGrid({
    super.key,
    required this.rows,
    required this.cols,
    required this.devices,
    required this.removingDeviceIds,
    required this.placingDeviceIds,
    required this.onDeviceDropped,
    required this.onDeviceTap,
  });

  final int rows;
  final int cols;
  final List<Device> devices;
  final Set<String> removingDeviceIds;
  final Set<String> placingDeviceIds;
  final DeviceDropCallback onDeviceDropped;
  final DeviceTapCallback onDeviceTap;

  @override
  State<RoomGrid> createState() => _RoomGridState();
}

class _RoomGridState extends State<RoomGrid> {
  int? _hoverRow;
  int? _hoverCol;

  ({int row, int col}) _cellFromOffset(Offset local, double cellWidth, double cellHeight) {
    final col = (local.dx / cellWidth).round().clamp(0, widget.cols - 1);
    final row = (local.dy / cellHeight).round().clamp(0, widget.rows - 1);
    return (row: row, col: col);
  }

  void _updateHover(
    Offset globalOffset,
    RenderBox gridBox,
    double cellWidth,
    double cellHeight,
  ) {
    final local = gridBox.globalToLocal(globalOffset);
    if (!gridBox.size.contains(local)) {
      if (_hoverRow != null || _hoverCol != null) {
        setState(() {
          _hoverRow = null;
          _hoverCol = null;
        });
      }
      return;
    }

    final cell = _cellFromOffset(local, cellWidth, cellHeight);
    if (cell.row != _hoverRow || cell.col != _hoverCol) {
      setState(() {
        _hoverRow = cell.row;
        _hoverCol = cell.col;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / widget.cols;
        final cellHeight = constraints.maxHeight / widget.rows;

        return DragTarget<DeviceType>(
          onWillAcceptWithDetails: (_) => true,
          onMove: (details) {
            final gridBox = context.findRenderObject() as RenderBox?;
            if (gridBox == null) return;
            _updateHover(details.offset, gridBox, cellWidth, cellHeight);
          },
          onLeave: (_) {
            if (_hoverRow != null || _hoverCol != null) {
              setState(() {
                _hoverRow = null;
                _hoverCol = null;
              });
            }
          },
          onAcceptWithDetails: (details) {
            final gridBox = context.findRenderObject() as RenderBox;
            final local = gridBox.globalToLocal(details.offset);
            final cell = _cellFromOffset(local, cellWidth, cellHeight);
            widget.onDeviceDropped(details.data, cell.row, cell.col);
            setState(() {
              _hoverRow = null;
              _hoverCol = null;
            });
          },
          builder: (context, candidateData, rejectedData) {
            final isDragging = candidateData.isNotEmpty;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.cols,
                    childAspectRatio: cellWidth / cellHeight,
                  ),
                  itemCount: widget.rows * widget.cols,
                  itemBuilder: (context, index) {
                    final row = index ~/ widget.cols;
                    final col = index % widget.cols;
                    final isLight = (row + col).isEven;
                    final isHovered =
                        isDragging && row == _hoverRow && col == _hoverCol;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isHovered
                            ? palette.accent.withValues(alpha: 0.22)
                            : isLight
                                ? palette.tileLight
                                : palette.tileDark,
                        border: isHovered
                            ? Border.all(
                                color:
                                    palette.accent.withValues(alpha: 0.55),
                              )
                            : null,
                      ),
                    );
                  },
                ),
                for (final device in widget.devices)
                  AnimatedPositioned(
                    key: ValueKey(device.id),
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: device.column * cellWidth,
                    top: device.row * cellHeight,
                    width: cellWidth,
                    height: cellHeight,
                    child: Padding(
                      padding: EdgeInsets.all(cellWidth * 0.12),
                      child: GridDevice(
                        device: device,
                        isRemoving:
                            widget.removingDeviceIds.contains(device.id),
                        isPlacing: widget.placingDeviceIds.contains(device.id),
                        onTap: () => widget.onDeviceTap(device),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
