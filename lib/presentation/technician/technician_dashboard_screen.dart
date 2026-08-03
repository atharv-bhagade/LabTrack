import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hello_flutter/constants/app_info.dart';
import 'package:hello_flutter/domain/entities/app_user.dart';
import 'package:hello_flutter/domain/entities/repair_ticket.dart';
import 'package:hello_flutter/presentation/navigation/role_home_screen.dart';
import 'package:hello_flutter/presentation/providers/app_providers.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/utils/device_type_info.dart';
import 'package:hello_flutter/widgets/app_confirm_dialog.dart';
import 'package:hello_flutter/widgets/app_gradient_background.dart';

class TechnicianDashboardScreen extends ConsumerStatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  ConsumerState<TechnicianDashboardScreen> createState() =>
      _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState
    extends ConsumerState<TechnicianDashboardScreen> {
  List<RepairTicket> _tickets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tickets =
        await ref.read(repairRepositoryProvider).getTickets(forceRefresh: true);
    if (!mounted) return;
    setState(() {
      _tickets = tickets;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await ref.read(authStateProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const RoleHomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final technician = ref.watch(authStateProvider).value;
    final techId = technician?.userId;

    ref.listen<int>(repairRevisionProvider, (previous, next) {
      if (previous != next) _load();
    });

    final available = _tickets.where((ticket) => ticket.isAvailable).toList()
      ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    final myJobs = _tickets
        .where(
          (ticket) =>
              ticket.acceptedBy == techId &&
              (ticket.status == RepairStatus.accepted ||
                  ticket.status == RepairStatus.underRepair),
        )
        .toList();
    final completed = _tickets
        .where(
          (ticket) =>
              ticket.status == RepairStatus.completed &&
              ticket.acceptedBy == techId,
        )
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('${AppInfo.appName} · Technician'),
          actions: [
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout_rounded),
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Available (${available.length})'),
              Tab(text: 'My Jobs (${myJobs.length})'),
              Tab(text: 'Completed (${completed.length})'),
            ],
          ),
        ),
        body: AppGradientBackground(
          child: SafeArea(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(color: palette.accent),
                  )
                : TabBarView(
                    children: [
                      _AvailableWorkList(
                        tickets: available,
                        onRefresh: _load,
                      ),
                      _MyJobsList(
                        tickets: myJobs,
                        technician: technician,
                        onRefresh: _load,
                      ),
                      _CompletedJobsList(
                        tickets: completed,
                        onRefresh: _load,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _AvailableWorkList extends ConsumerWidget {
  const _AvailableWorkList({
    required this.tickets,
    required this.onRefresh,
  });

  final List<RepairTicket> tickets;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tickets.isEmpty) return const _EmptyJobs(message: 'No available work.');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _TicketCard(
          ticket: ticket,
          onDismiss: () async {
            final confirmed = await AppConfirmDialog.show(
              context: context,
              title: 'Remove Report',
              message:
                  'Remove this repair request from the Available list?',
              confirmLabel: 'Remove',
              isDestructive: true,
            );
            if (!confirmed || !context.mounted) return;
            await ref
                .read(repairRepositoryProvider)
                .removeAvailableTicket(ticket.id);
            onRefresh();
          },
          children: [
            OutlinedButton(
              onPressed: () => _showProblem(context, ticket),
              child: const Text('View Problem'),
            ),
            FilledButton(
              onPressed: () async {
                final tech = ref.read(authStateProvider).value;
                if (tech == null) return;
                final accepted = await ref
                    .read(repairRepositoryProvider)
                    .acceptTicket(ticketId: ticket.id, technician: tech);
                if (!context.mounted) return;
                if (!accepted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ticket is no longer available.'),
                    ),
                  );
                }
                onRefresh();
              },
              child: const Text('Accept Repair'),
            ),
          ],
        );
      },
    );
  }
}

class _MyJobsList extends ConsumerStatefulWidget {
  const _MyJobsList({
    required this.tickets,
    required this.technician,
    required this.onRefresh,
  });

  final List<RepairTicket> tickets;
  final AppUser? technician;
  final VoidCallback onRefresh;

  @override
  ConsumerState<_MyJobsList> createState() => _MyJobsListState();
}

class _MyJobsListState extends ConsumerState<_MyJobsList> {
  @override
  Widget build(BuildContext context) {
    if (widget.tickets.isEmpty) {
      return const _EmptyJobs(message: 'No accepted jobs yet.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.tickets.length,
      itemBuilder: (context, index) {
        final ticket = widget.tickets[index];
        return _AcceptedJobCard(
          ticket: ticket,
          technician: widget.technician,
          onRefresh: widget.onRefresh,
        );
      },
    );
  }
}

class _AcceptedJobCard extends ConsumerStatefulWidget {
  const _AcceptedJobCard({
    required this.ticket,
    required this.technician,
    required this.onRefresh,
  });

  final RepairTicket ticket;
  final AppUser? technician;
  final VoidCallback onRefresh;

  @override
  ConsumerState<_AcceptedJobCard> createState() => _AcceptedJobCardState();
}

class _AcceptedJobCardState extends ConsumerState<_AcceptedJobCard> {
  late final TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _remarksController =
        TextEditingController(text: widget.ticket.repairNotes);
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AcceptedJobCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ticket.id != widget.ticket.id) {
      _remarksController.text = widget.ticket.repairNotes;
    }
  }

  Future<void> _saveRemarks() async {
    final repository = ref.read(repairRepositoryProvider);
    await repository.updateTicket(
      widget.ticket.copyWith(repairNotes: _remarksController.text.trim()),
    );
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final tech = widget.technician;
    final canComplete = ticket.status == RepairStatus.accepted ||
        ticket.status == RepairStatus.underRepair;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ticket.deviceName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('${ticket.buildingName} · ${ticket.floorName} · ${ticket.roomName}'),
            const SizedBox(height: 4),
            Text(ticket.faultDescription),
            const SizedBox(height: 4),
            Text('Reported: ${_formatDateTime(ticket.reportedAt)}'),
            const SizedBox(height: 12),
            TextField(
              controller: _remarksController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                alignLabelWithHint: true,
              ),
              onEditingComplete: _saveRemarks,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (ticket.status == RepairStatus.accepted)
                  FilledButton(
                    onPressed: tech == null
                        ? null
                        : () async {
                            await ref.read(repairRepositoryProvider).markUnderRepair(
                                  ticketId: ticket.id,
                                  technician: tech,
                                );
                            widget.onRefresh();
                          },
                    child: const Text('Under Repair'),
                  ),
                if (canComplete)
                  FilledButton(
                    onPressed: tech == null
                        ? null
                        : () async {
                            await _saveRemarks();
                            final ok = await ref
                                .read(repairRepositoryProvider)
                                .completeRepair(
                                  ticketId: ticket.id,
                                  technician: tech,
                                  remarks: _remarksController.text.trim(),
                                );
                            if (!context.mounted) return;
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Unable to complete repair.'),
                                ),
                              );
                            }
                            widget.onRefresh();
                          },
                    child: const Text('Done Repair'),
                  ),
                OutlinedButton(
                  onPressed: tech == null
                      ? null
                      : () async {
                          final confirmed = await AppConfirmDialog.show(
                            context: context,
                            title: 'Leave Job',
                            message:
                                'Release this ticket back to Available Work?',
                            confirmLabel: 'Leave Job',
                            isDestructive: true,
                          );
                          if (!confirmed) return;
                          await ref.read(repairRepositoryProvider).leaveJob(
                                ticketId: ticket.id,
                                technician: tech,
                              );
                          widget.onRefresh();
                        },
                  child: const Text('Leave Job'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedJobsList extends ConsumerWidget {
  const _CompletedJobsList({
    required this.tickets,
    required this.onRefresh,
  });

  final List<RepairTicket> tickets;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tickets.isEmpty) {
      return const _EmptyJobs(message: 'No completed jobs yet.');
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await AppConfirmDialog.show(
                  context: context,
                  title: 'Clear History',
                  message: 'Remove all completed jobs from this list?',
                  confirmLabel: 'Clear',
                  isDestructive: true,
                );
                if (!confirmed) return;
                await ref.read(repairRepositoryProvider).clearCompletedHistory();
                onRefresh();
              },
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Clear History'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(ticket.deviceName),
                  subtitle: Text(
                    '${ticket.buildingName} · ${ticket.floorName} · ${ticket.roomName}\n'
                    'Completed: ${ticket.completedTime != null ? _formatDateTime(ticket.completedTime!) : '-'}\n'
                    'Technician: ${ticket.completedByName ?? ticket.acceptedByName ?? '-'}\n'
                    'Remarks: ${ticket.repairNotes.isEmpty ? '-' : ticket.repairNotes}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'View History',
                    icon: const Icon(Icons.history_rounded),
                    onPressed: () => _showHistory(context, ticket),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.children,
    this.onDismiss,
  });

  final RepairTicket ticket;
  final List<Widget> children;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    ticket.deviceName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    tooltip: 'Remove report',
                    onPressed: onDismiss,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: palette.textSecondary.withValues(alpha: 0.75),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(label: 'Building', value: ticket.buildingName),
            _InfoRow(label: 'Floor', value: ticket.floorName),
            _InfoRow(label: 'Room', value: ticket.roomName),
            _InfoRow(
              label: 'Device Type',
              value: DeviceTypeInfo.label(ticket.deviceType),
            ),
            _InfoRow(label: 'Reported Problem', value: ticket.faultDescription),
            _InfoRow(label: 'Reported By', value: ticket.reportedByName),
            _InfoRow(
              label: 'Report Time',
              value: _formatDateTime(ticket.reportedAt),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: children),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: palette.textSecondary, height: 1.4),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value, style: TextStyle(color: palette.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _EmptyJobs extends StatelessWidget {
  const _EmptyJobs({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Text(message, style: TextStyle(color: palette.textSecondary)),
    );
  }
}

void _showProblem(BuildContext context, RepairTicket ticket) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reported Problem'),
      content: Text(ticket.faultDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

void _showHistory(BuildContext context, RepairTicket ticket) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Repair History'),
      content: SingleChildScrollView(
        child: Text(
          'Device: ${ticket.deviceName}\n'
          'Problem: ${ticket.faultDescription}\n'
          'Technician: ${ticket.completedByName ?? ticket.acceptedByName ?? '-'}\n'
          'Phone: ${ticket.completedByPhone ?? '-'}\n'
          'Completed: ${ticket.completedTime != null ? _formatDateTime(ticket.completedTime!) : '-'}\n'
          'Remarks: ${ticket.repairNotes}',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

String _formatDateTime(DateTime value) {
  return '${value.day}/${value.month}/${value.year} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}
