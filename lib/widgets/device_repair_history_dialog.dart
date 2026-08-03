import 'package:flutter/material.dart';
import 'package:hello_flutter/models/device_repair_history.dart';
import 'package:hello_flutter/theme/app_palette.dart';

abstract final class DeviceRepairHistoryView {
  static Future<void> show({
    required BuildContext context,
    required String deviceName,
    required List<DeviceRepairHistoryEntry> history,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => _DeviceRepairHistoryDialog(
        deviceName: deviceName,
        history: history,
      ),
    );
  }
}

class _DeviceRepairHistoryDialog extends StatelessWidget {
  const _DeviceRepairHistoryDialog({
    required this.deviceName,
    required this.history,
  });

  final String deviceName;
  final List<DeviceRepairHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final sorted = [...history]
      ..sort((a, b) => b.endTime.compareTo(a.endTime));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, color: palette.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Repair History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                deviceName,
                style: TextStyle(color: palette.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: sorted.isEmpty
                  ? Center(
                      child: Text(
                        'No repair history yet.',
                        style: TextStyle(color: palette.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: sorted.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _HistoryCard(entry: sorted[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});

  final DeviceRepairHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      elevation: 0,
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: palette.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 20,
                  color: palette.working,
                ),
                const SizedBox(width: 8),
                Text(
                  formatDeviceDateTime(entry.endTime),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _HistoryRow(
              icon: Icons.report_problem_outlined,
              label: 'Problem',
              value: entry.problem,
            ),
            _HistoryRow(
              icon: Icons.person_outline_rounded,
              label: 'Technician',
              value: '${entry.technicianName} (${entry.technicianId})',
            ),
            _HistoryRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: entry.phoneNumber.isEmpty ? '—' : entry.phoneNumber,
            ),
            _HistoryRow(
              icon: Icons.play_arrow_rounded,
              label: 'Start',
              value: formatDeviceDateTime(entry.repairStartTime),
            ),
            _HistoryRow(
              icon: Icons.stop_rounded,
              label: 'End',
              value: formatDeviceDateTime(entry.endTime),
            ),
            _HistoryRow(
              icon: Icons.summarize_outlined,
              label: 'Summary',
              value: entry.remarks.isEmpty ? '—' : entry.remarks,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: palette.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: palette.textSecondary,
                  height: 1.35,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(color: palette.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatDeviceDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year;
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/$year · $hour:$minute';
}
