import 'package:flutter/material.dart';
import 'package:hello_flutter/constants/layout_constants.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/widgets/room_grid.dart';

class LabRoom extends StatefulWidget {
  const LabRoom({
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
  State<LabRoom> createState() => _LabRoomState();
}

class _LabRoomState extends State<LabRoom> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final TransformationController _transformController;
  double _currentScale = 1;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _transformController.addListener(_onTransformChanged);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.01) {
      setState(() => _currentScale = scale);
    }
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
    setState(() => _currentScale = 1);
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final aspectRatio = widget.cols / widget.rows;
        var width = [
          constraints.maxWidth,
          LayoutConstants.roomMaxWidth,
        ].reduce((a, b) => a < b ? a : b);
        var height = width / aspectRatio;

        if (height > constraints.maxHeight) {
          height = constraints.maxHeight;
          width = height * aspectRatio;
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                LayoutConstants.roomBorderRadius,
              ),
              border: Border.all(color: palette.border),
              boxShadow: [
                BoxShadow(
                  color: palette.shadow,
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: palette.accent.withValues(alpha: 0.12),
                  blurRadius: 60,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                LayoutConstants.roomBorderRadius,
              ),
              child: GestureDetector(
                onDoubleTap: _resetZoom,
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.75,
                  maxScale: 4,
                  panEnabled: _currentScale > 1.02,
                  scaleEnabled: true,
                  clipBehavior: Clip.none,
                  boundaryMargin: const EdgeInsets.all(48),
                  child: RoomGrid(
                    rows: widget.rows,
                    cols: widget.cols,
                    devices: widget.devices,
                    removingDeviceIds: widget.removingDeviceIds,
                    placingDeviceIds: widget.placingDeviceIds,
                    onDeviceDropped: widget.onDeviceDropped,
                    onDeviceTap: widget.onDeviceTap,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
