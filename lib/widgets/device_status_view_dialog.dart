import 'package:flutter/material.dart';
import 'package:hello_flutter/domain/entities/repair_ticket.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_repair_history.dart';
import 'package:hello_flutter/models/device_status.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/utils/device_status_colors.dart';
import 'package:hello_flutter/utils/device_type_info.dart';
import 'package:hello_flutter/widgets/device_repair_history_dialog.dart';

class DeviceStatusViewDialog extends StatelessWidget {
  const DeviceStatusViewDialog({
    super.key,
    required this.device,
    this.openTicket,
    this.showReportFault = false,
    this.onReportFault,
    this.showEditDevice = false,
    this.onEditDevice,
  });

  final Device device;
  final RepairTicket? openTicket;
  final bool showReportFault;
  final VoidCallback? onReportFault;
  final bool showEditDevice;
  final VoidCallback? onEditDevice;

  static Future<void> show({
    required BuildContext context,
    required Device device,
    RepairTicket? openTicket,
    bool showReportFault = false,
    VoidCallback? onReportFault,
    bool showEditDevice = false,
    VoidCallback? onEditDevice,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => DeviceStatusViewDialog(
        device: device,
        openTicket: openTicket,
        showReportFault: showReportFault,
        onReportFault: onReportFault,
        showEditDevice: showEditDevice,
        onEditDevice: onEditDevice,
      ),
    );
  }

  DeviceRepairHistoryEntry? get _latestRepair {
    if (device.repairHistory.isEmpty) return null;
    return device.repairHistory.reduce(
      (a, b) => a.endTime.isAfter(b.endTime) ? a : b,
    );
  }

  bool get _showRepairedSummary =>
      device.status == DeviceStatus.working && _latestRepair != null;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final status = device.status;
    final statusLabel = DeviceStatusColors.label(status);
    final badgeColor = DeviceStatusColors.badgeForeground(palette, status);
    final badgeBg = DeviceStatusColors.badgeBackground(palette, status);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: DeviceStatusColors.borderColor(palette, status)
                              .withValues(alpha: 0.65),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        DeviceTypeInfo.icon(device.type),
                        color: DeviceStatusColors.iconColor(palette, status),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DeviceTypeInfo.label(device.type),
                            style: TextStyle(color: palette.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        DeviceStatusColors.icon(status),
                        size: 18,
                        color: badgeColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ..._buildStatusBody(context, palette),
                if (device.repairHistory.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      DeviceRepairHistoryView.show(
                        context: context,
                        deviceName: device.name,
                        history: device.repairHistory,
                      );
                    },
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('View History'),
                  ),
                ],
                if (showReportFault && onReportFault != null) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onReportFault!();
                    },
                    icon: const Icon(Icons.report_outlined),
                    label: const Text('Report Fault'),
                  ),
                ],
                if (showEditDevice && onEditDevice != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onEditDevice!();
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Device'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStatusBody(BuildContext context, AppPalette palette) {
    switch (device.status) {
      case DeviceStatus.working:
        if (_showRepairedSummary) {
          final entry = _latestRepair!;
          return [
            _DetailCard(
              children: [
                _DetailRow(
                  icon: Icons.engineering_outlined,
                  label: 'Repaired by',
                  value: entry.technicianName,
                ),
                _DetailRow(
                  icon: Icons.badge_outlined,
                  label: 'Technician ID',
                  value: entry.technicianId,
                ),
                _DetailRow(
                  icon: Icons.event_available_outlined,
                  label: 'Completion time',
                  value: formatDeviceDateTime(entry.endTime),
                ),
                _DetailRow(
                  icon: Icons.summarize_outlined,
                  label: 'Repair summary',
                  value: entry.remarks.isEmpty ? '—' : entry.remarks,
                ),
              ],
            ),
          ];
        }
        return [
          Text(
            'This object is operating normally.',
            style: TextStyle(color: palette.textSecondary, height: 1.4),
          ),
        ];
      case DeviceStatus.defective:
        final ticket = openTicket;
        return [
          _DetailCard(
            children: [
              _DetailRow(
                icon: Icons.report_problem_outlined,
                label: 'Reported problem',
                value: device.failureReason.isNotEmpty
                    ? device.failureReason
                    : (ticket?.faultDescription ?? '—'),
              ),
              _DetailRow(
                icon: Icons.person_outline_rounded,
                label: 'Reported by',
                value: ticket?.reportedByName ?? '—',
              ),
              _DetailRow(
                icon: Icons.schedule_rounded,
                label: 'Reported at',
                value: ticket != null
                    ? formatDeviceDateTime(ticket.reportedAt)
                    : formatDeviceDateTime(device.lastUpdated),
              ),
            ],
          ),
        ];
      case DeviceStatus.underRepair:
        final ticket = openTicket;
        return [
          _DetailCard(
            children: [
              _DetailRow(
                icon: Icons.build_circle_outlined,
                label: 'Status',
                value: 'Repair In Progress',
              ),
              _DetailRow(
                icon: Icons.engineering_outlined,
                label: 'Technician',
                value: ticket?.acceptedByName ?? '—',
              ),
              _DetailRow(
                icon: Icons.badge_outlined,
                label: 'Technician ID',
                value: ticket?.acceptedBy ?? '—',
              ),
              _DetailRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: ticket?.acceptedByPhone ?? '—',
              ),
              _DetailRow(
                icon: Icons.event_available_outlined,
                label: 'Accepted at',
                value: ticket?.acceptedTime != null
                    ? formatDeviceDateTime(ticket!.acceptedTime!)
                    : '—',
              ),
              _DetailRow(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Latest remark',
                value: ticket?.repairNotes.isNotEmpty == true
                    ? ticket!.repairNotes
                    : '—',
              ),
            ],
          ),
        ];
    }
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: palette.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: palette.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: palette.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
