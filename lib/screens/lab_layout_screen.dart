import 'package:flutter/material.dart';
import 'package:hello_flutter/constants/layout_constants.dart';
import 'package:hello_flutter/controllers/lab_layout_controller.dart';
import 'package:hello_flutter/controllers/theme_controller.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_type.dart';
import 'package:hello_flutter/models/room.dart';
import 'package:hello_flutter/screens/about_screen.dart';
import 'package:hello_flutter/screens/settings_screen.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/widgets/app_confirm_dialog.dart';
import 'package:hello_flutter/widgets/app_gradient_background.dart';
import 'package:hello_flutter/widgets/device_detail_sheet.dart';
import 'package:hello_flutter/widgets/device_toolbox.dart';
import 'package:hello_flutter/widgets/lab_layout_toolbar.dart';
import 'package:hello_flutter/widgets/lab_room.dart';

class LabLayoutScreen extends StatefulWidget {
  const LabLayoutScreen({
    super.key,
    required this.room,
    required this.buildingName,
    required this.layoutController,
    required this.themeController,
  });

  final Room room;
  final String buildingName;
  final LabLayoutController layoutController;
  final ThemeController themeController;

  @override
  State<LabLayoutScreen> createState() => _LabLayoutScreenState();
}

class _LabLayoutScreenState extends State<LabLayoutScreen> {
  LabLayoutController get _controller => widget.layoutController;

  @override
  void initState() {
    super.initState();
    _controller.loadForRoom(
      widget.room.id,
      defaultRows: widget.room.rows,
      defaultCols: widget.room.columns,
    );
  }

  Future<void> _onDeviceDropped(DeviceType type, int row, int col) {
    return _controller.addDevice(type, row, col);
  }

  Future<void> _openDeviceSheet(Device device) {
    return DeviceDetailSheet.show(
      context: context,
      device: device,
      onSave: _controller.updateDevice,
      onRemove: () => _controller.removeDevice(device.id),
    );
  }

  Future<void> _changeRows(int newRows) async {
    if (newRows == _controller.rows) return;

    final outside = _controller.devicesOutsideBounds(rows: newRows);
    if (outside.isNotEmpty) {
      final confirmed = await AppConfirmDialog.show(
        context: context,
        title: 'Resize Lab Rows',
        message:
            '${outside.length} device(s) fall outside the new row count and will be removed. Continue?',
        confirmLabel: 'Resize',
        isDestructive: true,
      );
      if (!confirmed) return;
      await _controller.resizeRows(newRows, removeOutside: true);
      return;
    }

    await _controller.resizeRows(newRows, removeOutside: false);
  }

  Future<void> _changeCols(int newCols) async {
    if (newCols == _controller.cols) return;

    final outside = _controller.devicesOutsideBounds(cols: newCols);
    if (outside.isNotEmpty) {
      final confirmed = await AppConfirmDialog.show(
        context: context,
        title: 'Resize Lab Columns',
        message:
            '${outside.length} device(s) fall outside the new column count and will be removed. Continue?',
        confirmLabel: 'Resize',
        isDestructive: true,
      );
      if (!confirmed) return;
      await _controller.resizeCols(newCols, removeOutside: true);
      return;
    }

    await _controller.resizeCols(newCols, removeOutside: false);
  }

  @override
  Widget build(BuildContext context) {
    final isCompact =
        MediaQuery.sizeOf(context).width < LayoutConstants.compactBreakpoint;
    final palette = context.palette;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (!_controller.isLoaded ||
            _controller.currentRoomId != widget.room.id) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: palette.accent),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.room.name),
                Text(
                  widget.buildingName,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'About',
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AboutScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SettingsScreen(
                        layoutController: _controller,
                        themeController: widget.themeController,
                      ),
                    ),
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: palette.borderSubtle,
              ),
            ),
          ),
          body: AppGradientBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(LayoutConstants.roomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabLayoutToolbar(
                      rows: _controller.rows,
                      cols: _controller.cols,
                      devices: _controller.devices,
                      onRowsChanged: _changeRows,
                      onColsChanged: _changeCols,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: isCompact
                          ? _buildCompactLayout()
                          : _buildWideLayout(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.center,
          child: DeviceToolbox(horizontal: false),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildRoomArea(showBottomToolbox: false)),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return _buildRoomArea(showBottomToolbox: true);
  }

  Widget _buildRoomArea({required bool showBottomToolbox}) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: LabRoom(
              rows: _controller.rows,
              cols: _controller.cols,
              devices: _controller.devices,
              removingDeviceIds: _controller.removingDeviceIds,
              placingDeviceIds: _controller.placingDeviceIds,
              onDeviceDropped: _onDeviceDropped,
              onDeviceTap: _openDeviceSheet,
            ),
          ),
        ),
        if (showBottomToolbox) ...[
          const SizedBox(height: 16),
          const Center(child: DeviceToolbox(horizontal: true)),
        ],
      ],
    );
  }
}
