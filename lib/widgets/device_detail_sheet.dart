import 'package:flutter/material.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_status.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/utils/device_status_colors.dart';
import 'package:hello_flutter/utils/device_type_info.dart';
import 'package:hello_flutter/widgets/app_confirm_dialog.dart';
import 'package:hello_flutter/widgets/app_unsaved_name_dialog.dart';

class DeviceDetailSheet extends StatefulWidget {
  const DeviceDetailSheet({
    super.key,
    required this.device,
    required this.onSaveDevice,
    required this.onRemove,
    this.onReportProblem,
    this.hasActiveRepairTicket = false,
  });

  final Device device;
  final ValueChanged<Device> onSaveDevice;
  final Future<void> Function() onRemove;
  final Future<bool> Function(Device device, String description)? onReportProblem;
  final bool hasActiveRepairTicket;

  static Future<void> show({
    required BuildContext context,
    required Device device,
    required ValueChanged<Device> onSaveDevice,
    required Future<void> Function() onRemove,
    Future<bool> Function(Device device, String description)? onReportProblem,
    bool hasActiveRepairTicket = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: DeviceDetailSheet(
            device: device,
            onSaveDevice: onSaveDevice,
            onRemove: onRemove,
            onReportProblem: onReportProblem,
            hasActiveRepairTicket: hasActiveRepairTicket,
          ),
        );
      },
    );
  }

  @override
  State<DeviceDetailSheet> createState() => _DeviceDetailSheetState();
}

class _DeviceDetailSheetState extends State<DeviceDetailSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _reasonController;
  late Device _deviceRef;
  late String _committedName;
  late DeviceStatus _status;
  bool _pendingDefectiveReport = false;

  bool get _hasUnsavedName =>
      _nameController.text.trim() != _committedName &&
      _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _deviceRef = widget.device;
    _committedName = widget.device.name;
    _nameController = TextEditingController(text: widget.device.name);
    _reasonController =
        TextEditingController(text: widget.device.failureReason);
    _status = widget.device.status;
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<bool> _handleCloseRequest() async {
    if (!_hasUnsavedName) return true;

    final choice = await AppUnsavedNameDialog.show(context);
    switch (choice) {
      case UnsavedNameChoice.save:
        _saveName();
        return true;
      case UnsavedNameChoice.discard:
        return true;
      case UnsavedNameChoice.cancel:
        return false;
    }
  }

  void _saveName() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == _committedName) return;

    _deviceRef = _deviceRef.copyWith(
      name: newName,
      lastUpdated: DateTime.now(),
    );
    widget.onSaveDevice(_deviceRef);
    setState(() => _committedName = newName);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device renamed successfully.')),
    );
  }

  void _persistStatusOnly() {
    _deviceRef = _deviceRef.copyWith(
      status: _status,
      failureReason:
          _status == DeviceStatus.defective ? _reasonController.text.trim() : '',
      lastUpdated: DateTime.now(),
    );
    widget.onSaveDevice(_deviceRef);
  }

  Future<void> _submitReportProblem() async {
    final description = _reasonController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the problem first.')),
      );
      return;
    }

    final report = widget.onReportProblem;
    if (report == null) return;

    final ok = await report(_deviceRef, description);
    if (!mounted) return;

    if (!ok) return;

    setState(() {
      _status = DeviceStatus.defective;
      _pendingDefectiveReport = false;
      _deviceRef = _deviceRef.copyWith(
        status: DeviceStatus.defective,
        failureReason: description,
        lastUpdated: DateTime.now(),
      );
    });
  }

  Future<void> _handleRemove() async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Remove Device',
      message:
          'Remove "${_deviceRef.name}" from the lab layout? This action cannot be undone.',
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    Navigator.of(context).pop();
    await widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final showReportSection =
        _pendingDefectiveReport || _status == DeviceStatus.defective;
    final canSubmitReport = widget.onReportProblem != null &&
        !widget.hasActiveRepairTicket &&
        _status != DeviceStatus.underRepair &&
        _pendingDefectiveReport;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _handleCloseRequest()) {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: DeviceStatusColors.borderColor(palette, _status)
                          .withValues(alpha: 0.65),
                    ),
                  ),
                  child: Icon(
                    DeviceTypeInfo.icon(_deviceRef.type),
                    size: 34,
                    color: DeviceStatusColors.iconColor(palette, _status),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                ),
              ),
              if (_hasUnsavedName) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: _saveName,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('Save Name'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                DeviceTypeInfo.label(_deviceRef.type),
                style: TextStyle(color: palette.textSecondary),
              ),
              const SizedBox(height: 20),
              Text(
                'Status',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: DeviceStatusColors.badgeForeground(palette, _status),
                    fontWeight: FontWeight.w600,
                  ),
                  child: Text(DeviceStatusColors.label(_status)),
                ),
                subtitle: Text(
                  switch (_status) {
                    DeviceStatus.working => 'Device is operational',
                    DeviceStatus.defective => 'Device requires attention',
                    DeviceStatus.underRepair =>
                      'Technician is repairing this device',
                  },
                  style: TextStyle(color: palette.textSecondary),
                ),
                value: _status == DeviceStatus.working,
                onChanged: _status == DeviceStatus.underRepair
                    ? null
                    : (isWorking) {
                        setState(() {
                          if (isWorking) {
                            _status = DeviceStatus.working;
                            _pendingDefectiveReport = false;
                            _reasonController.clear();
                            _persistStatusOnly();
                          } else {
                            _status = DeviceStatus.defective;
                            _pendingDefectiveReport = true;
                          }
                        });
                      },
              ),
              if (widget.hasActiveRepairTicket &&
                  _status != DeviceStatus.working) ...[
                const SizedBox(height: 8),
                Text(
                  'This device already has an active repair ticket.',
                  style: TextStyle(
                    color: palette.underRepair,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: showReportSection
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _reasonController,
                        minLines: 3,
                        maxLines: 5,
                        readOnly: widget.hasActiveRepairTicket ||
                            _status == DeviceStatus.underRepair,
                        decoration: const InputDecoration(
                          labelText: 'Problem description',
                          alignLabelWithHint: true,
                        ),
                      ),
                      if (canSubmitReport) ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _submitReportProblem,
                          icon: const Icon(Icons.report_outlined),
                          label: const Text('Report Problem'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.defective,
                  side: BorderSide(
                    color: palette.defective.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _handleRemove,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Remove Device'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
