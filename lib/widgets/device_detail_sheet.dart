import 'package:flutter/material.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_status.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/utils/device_type_info.dart';
import 'package:hello_flutter/widgets/app_confirm_dialog.dart';

class DeviceDetailSheet extends StatefulWidget {
  const DeviceDetailSheet({
    super.key,
    required this.device,
    required this.onSave,
    required this.onRemove,
  });

  final Device device;
  final ValueChanged<Device> onSave;
  final Future<void> Function() onRemove;

  static Future<void> show({
    required BuildContext context,
    required Device device,
    required ValueChanged<Device> onSave,
    required Future<void> Function() onRemove,
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
            onSave: onSave,
            onRemove: onRemove,
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
  late DeviceStatus _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.name);
    _reasonController =
        TextEditingController(text: widget.device.failureReason);
    _status = widget.device.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _persistChanges() {
    widget.onSave(
      widget.device.copyWith(
        name: _nameController.text.trim().isEmpty
            ? widget.device.name
            : _nameController.text.trim(),
        status: _status,
        failureReason:
            _status.isDefective ? _reasonController.text.trim() : '',
        lastUpdated: DateTime.now(),
      ),
    );
  }

  Future<void> _handleRemove() async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Remove Device',
      message:
          'Remove "${widget.device.name}" from the lab layout? This action cannot be undone.',
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

    return AnimatedPadding(
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
                    color: _status.isDefective
                        ? palette.defective.withValues(alpha: 0.6)
                        : palette.working.withValues(alpha: 0.6),
                  ),
                ),
                child: Icon(
                  DeviceTypeInfo.icon(widget.device.type),
                  size: 34,
                  color: _status.isDefective
                      ? palette.defective
                      : palette.accent,
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
              onSubmitted: (_) => _persistChanges(),
              onEditingComplete: _persistChanges,
            ),
            const SizedBox(height: 12),
            Text(
              DeviceTypeInfo.label(widget.device.type),
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
                  color: _status.isDefective
                      ? palette.defective
                      : palette.working,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(
                  _status.isDefective ? 'Defective' : 'Working',
                ),
              ),
              subtitle: Text(
                _status.isDefective
                    ? 'Device requires attention'
                    : 'Device is operational',
                style: TextStyle(color: palette.textSecondary),
              ),
              value: !_status.isDefective,
              onChanged: (isWorking) {
                setState(() {
                  _status =
                      isWorking ? DeviceStatus.working : DeviceStatus.defective;
                  if (isWorking) {
                    _reasonController.clear();
                  }
                });
                _persistChanges();
              },
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _status.isDefective
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: _reasonController,
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (_) => _persistChanges(),
                  decoration: const InputDecoration(
                    labelText: 'Reason why device is not working',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.defective,
                side: BorderSide(color: palette.defective.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _handleRemove,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Remove Device'),
            ),
          ],
        ),
      ),
    );
  }
}
