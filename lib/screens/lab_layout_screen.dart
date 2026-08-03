import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hello_flutter/constants/layout_constants.dart';
import 'package:hello_flutter/controllers/lab_layout_controller.dart';
import 'package:hello_flutter/controllers/theme_controller.dart';
import 'package:hello_flutter/domain/entities/repair_ticket.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_status.dart';
import 'package:hello_flutter/models/device_type.dart';
import 'package:hello_flutter/models/room.dart';
import 'package:hello_flutter/presentation/providers/app_providers.dart';
import 'package:hello_flutter/screens/about_screen.dart';
import 'package:hello_flutter/screens/settings_screen.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/widgets/app_confirm_dialog.dart';
import 'package:hello_flutter/widgets/app_gradient_background.dart';
import 'package:hello_flutter/widgets/report_problem_dialog.dart';
import 'package:hello_flutter/widgets/device_detail_sheet.dart';
import 'package:hello_flutter/widgets/device_status_view_dialog.dart';
import 'package:hello_flutter/widgets/device_toolbox.dart';
import 'package:hello_flutter/widgets/lab_layout_toolbar.dart';
import 'package:hello_flutter/widgets/lab_room.dart';

class LabLayoutScreen extends ConsumerStatefulWidget {
  const LabLayoutScreen({
    super.key,
    required this.room,
    required this.buildingName,
    required this.layoutController,
    required this.themeController,
    this.readOnly = false,
    this.floorName = '',
  });

  final Room room;
  final String buildingName;
  final String floorName;
  final LabLayoutController layoutController;
  final ThemeController themeController;
  final bool readOnly;

  @override
  ConsumerState<LabLayoutScreen> createState() => _LabLayoutScreenState();
}

class _LabLayoutScreenState extends ConsumerState<LabLayoutScreen> {
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
    if (widget.readOnly) return Future.value();
    return _controller.addDevice(type, row, col);
  }

  Future<void> _openDeviceSheet(Device device) => _openStatusView(device);

  Future<void> _openStatusView(Device device) async {
    final ticket = await ref
        .read(repairRepositoryProvider)
        .openTicketForDevice(device.id);

    if (!mounted) return;

    final canReport = widget.readOnly && device.status == DeviceStatus.working;

    await DeviceStatusViewDialog.show(
      context: context,
      device: device,
      openTicket: ticket,
      showReportFault: canReport,
      onReportFault: canReport ? () => _reportFault(device) : null,
      showEditDevice: !widget.readOnly,
      onEditDevice: !widget.readOnly
          ? () async {
              final openTicket = await ref
                  .read(repairRepositoryProvider)
                  .openTicketForDevice(device.id);
              if (!context.mounted) return;
              await DeviceDetailSheet.show(
                context: context,
                device: device,
                hasActiveRepairTicket: openTicket != null,
                onSaveDevice: _saveDeviceOnly,
                onReportProblem: _submitDeviceReport,
                onRemove: () => _controller.removeDevice(device.id),
              );
            }
          : null,
    );
  }

  Future<void> _saveDeviceOnly(Device updated) async {
    await _controller.updateDevice(updated);
  }

  Future<void> _reloadRoomLayout() {
    return _controller.loadForRoom(
      widget.room.id,
      defaultRows: widget.room.rows,
      defaultCols: widget.room.columns,
    );
  }

  void _showActiveTicketMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This device already has an active repair ticket.'),
      ),
    );
  }

  Future<bool> _submitDeviceReport(Device device, String description) async {
    if (device.status == DeviceStatus.defective ||
        device.status == DeviceStatus.underRepair) {
      _showActiveTicketMessage();
      return false;
    }

    final repository = ref.read(repairRepositoryProvider);
    final openTicket = await repository.openTicketForDevice(device.id);
    if (openTicket != null) {
      _showActiveTicketMessage();
      return false;
    }

    final user = ref.read(authStateProvider).value;
    final isTeacher = widget.readOnly;
    final ticket = RepairTicket(
      id: 'repair_${DateTime.now().microsecondsSinceEpoch}',
      deviceId: device.id,
      deviceName: device.name,
      deviceType: device.type,
      roomId: widget.room.id,
      roomName: widget.room.name,
      floorName: widget.floorName,
      buildingName: widget.buildingName,
      faultDescription: description,
      status: RepairStatus.available,
      reportedAt: DateTime.now(),
      reportedBy: user?.userId ?? (isTeacher ? 'TEACHER' : 'ADMIN'),
      reportedByName: user?.name ?? (isTeacher ? 'Teacher' : 'Administrator'),
    );

    final created = await repository.reportFault(ticket);
    if (!created) {
      _showActiveTicketMessage();
      return false;
    }

    await _controller.updateDevice(
      device.copyWith(
        status: DeviceStatus.defective,
        failureReason: description,
        lastUpdated: DateTime.now(),
      ),
    );
    await _reloadRoomLayout();
    if (!mounted) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fault reported. Technician notified.')),
    );
    return true;
  }

  Future<void> _reportFault(Device device) async {
    if (device.status == DeviceStatus.defective ||
        device.status == DeviceStatus.underRepair) {
      _showActiveTicketMessage();
      return;
    }

    final openTicket =
        await ref.read(repairRepositoryProvider).openTicketForDevice(device.id);
    if (openTicket != null) {
      _showActiveTicketMessage();
      return;
    }

    final reason = await ReportProblemDialog.show(context: context);
    if (reason == null || !mounted) return;

    await _submitDeviceReport(device, reason);
  }

  Future<void> _clearLayout() async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Clear Layout',
      message:
          'This will remove all placed devices from the lab board. The grid size will remain unchanged.',
      confirmLabel: 'Clear Layout',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    await _controller.clearLayout();
  }

  Future<void> _changeRows(int newRows) async {
    if (widget.readOnly) return;
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
    if (widget.readOnly) return;
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

    ref.listen<int>(repairRevisionProvider, (previous, next) {
      if (previous == next) return;
      _reloadRoomLayout();
    });

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
              if (!widget.readOnly)
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
                      readOnly: widget.readOnly,
                      onClearLayout: widget.readOnly ? null : _clearLayout,
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
    if (widget.readOnly) {
      return _buildRoomArea(showBottomToolbox: false);
    }

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
    return _buildRoomArea(showBottomToolbox: !widget.readOnly);
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
