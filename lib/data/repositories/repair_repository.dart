import 'package:hello_flutter/data/datasources/repair_local_datasource.dart';
import 'package:hello_flutter/domain/entities/app_user.dart';
import 'package:hello_flutter/domain/entities/repair_ticket.dart';
import 'package:hello_flutter/models/device.dart';
import 'package:hello_flutter/models/device_repair_history.dart';
import 'package:hello_flutter/models/device_status.dart';
import 'package:hello_flutter/services/layout_storage_service.dart';

typedef RepairChangedCallback = void Function();

class RepairRepository {
  RepairRepository(
    this._local,
    this._layoutStorage, {
    this.onChanged,
  });

  final RepairLocalDataSource _local;
  final LayoutStorageService _layoutStorage;
  final RepairChangedCallback? onChanged;

  List<RepairTicket>? _cache;

  void _notifyChanged() => onChanged?.call();

  Future<List<RepairTicket>> getTickets({bool forceRefresh = false}) async {
    if (forceRefresh) _cache = null;
    _cache ??= await _local.loadTickets();
    return List.unmodifiable(_cache!);
  }

  Future<void> _persist(List<RepairTicket> tickets) async {
    _cache = tickets;
    await _local.saveTickets(tickets);
    _notifyChanged();
  }

  Future<bool> reportFault(RepairTicket ticket) async {
    final existing = await openTicketForDevice(ticket.deviceId);
    if (existing != null) return false;

    final tickets = [...await getTickets(), ticket];
    await _persist(tickets);
    await _updateDevice(
      roomId: ticket.roomId,
      deviceId: ticket.deviceId,
      transform: (device) => device.copyWith(
        status: DeviceStatus.defective,
        failureReason: ticket.faultDescription,
      ),
    );
    return true;
  }

  Future<bool> acceptTicket({
    required String ticketId,
    required AppUser technician,
  }) async {
    final tickets = [...await getTickets()];
    final index = tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index == -1) return false;

    final ticket = tickets[index];
    if (!ticket.isAvailable) return false;

    tickets[index] = ticket.copyWith(
      status: RepairStatus.accepted,
      acceptedBy: technician.userId,
      acceptedByName: technician.name,
      acceptedTime: DateTime.now(),
      acceptedByPhone: technician.phoneNumber,
    );
    await _persist(tickets);
    return true;
  }

  Future<bool> markUnderRepair({
    required String ticketId,
    required AppUser technician,
  }) async {
    final tickets = [...await getTickets()];
    final index = tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index == -1) return false;

    final ticket = tickets[index];
    if (ticket.acceptedBy != technician.userId) return false;
    if (ticket.status != RepairStatus.accepted) return false;

    tickets[index] = ticket.copyWith(status: RepairStatus.underRepair);
    await _persist(tickets);

    await _updateDevice(
      roomId: ticket.roomId,
      deviceId: ticket.deviceId,
      transform: (device) => device.copyWith(status: DeviceStatus.underRepair),
    );
    return true;
  }

  Future<bool> completeRepair({
    required String ticketId,
    required AppUser technician,
    required String remarks,
  }) async {
    final tickets = [...await getTickets()];
    final index = tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index == -1) return false;

    final ticket = tickets[index];
    if (ticket.acceptedBy != technician.userId) return false;
    if (ticket.status != RepairStatus.accepted &&
        ticket.status != RepairStatus.underRepair) {
      return false;
    }

    final completedAt = DateTime.now();
    final duration = ticket.acceptedTime != null
        ? completedAt.difference(ticket.acceptedTime!)
        : Duration.zero;
    final repairStart = ticket.acceptedTime ?? completedAt.subtract(duration);

    tickets[index] = ticket.copyWith(
      status: RepairStatus.completed,
      repairNotes: remarks,
      completedTime: completedAt,
      completedByName: technician.name,
      completedByPhone: technician.phoneNumber,
    );
    await _persist(tickets);

    await _updateDevice(
      roomId: ticket.roomId,
      deviceId: ticket.deviceId,
      transform: (device) {
        final historyEntry = DeviceRepairHistoryEntry(
          date: completedAt,
          startTime: repairStart,
          technicianName: technician.name,
          technicianId: technician.userId,
          phoneNumber: technician.phoneNumber,
          problem: ticket.faultDescription,
          remarks: remarks,
          repairDuration: duration,
        );
        return device.copyWith(
          status: DeviceStatus.working,
          failureReason: '',
          repairHistory: [...device.repairHistory, historyEntry],
        );
      },
    );
    return true;
  }

  Future<bool> leaveJob({
    required String ticketId,
    required AppUser technician,
  }) async {
    final tickets = [...await getTickets()];
    final index = tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index == -1) return false;

    final ticket = tickets[index];
    if (ticket.acceptedBy != technician.userId) return false;
    if (ticket.status != RepairStatus.accepted &&
        ticket.status != RepairStatus.underRepair) {
      return false;
    }

    tickets[index] = ticket.copyWith(
      status: RepairStatus.available,
      clearAcceptance: true,
    );
    await _persist(tickets);

    await _updateDevice(
      roomId: ticket.roomId,
      deviceId: ticket.deviceId,
      transform: (device) => device.copyWith(
        status: DeviceStatus.defective,
      ),
    );
    return true;
  }

  Future<void> clearCompletedHistory() async {
    final tickets = (await getTickets())
        .where((ticket) => ticket.status != RepairStatus.completed)
        .toList();
    await _persist(tickets);
  }

  /// Removes a single available ticket only (no device/layout changes).
  Future<bool> removeAvailableTicket(String ticketId) async {
    final tickets = [...await getTickets()];
    final index = tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index == -1) return false;

    final ticket = tickets[index];
    if (!ticket.isAvailable) return false;

    tickets.removeAt(index);
    await _persist(tickets);
    return true;
  }

  Future<void> updateTicket(RepairTicket ticket) async {
    final tickets = await getTickets();
    await _persist(
      tickets.map((existing) => existing.id == ticket.id ? ticket : existing).toList(),
    );
  }

  /// Latest open (non-completed) ticket for a device, if any.
  Future<RepairTicket?> openTicketForDevice(String deviceId) async {
    if (deviceId.isEmpty) return null;
    final matches = (await getTickets())
        .where(
          (ticket) =>
              ticket.deviceId == deviceId &&
              ticket.status != RepairStatus.completed,
        )
        .toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    return matches.first;
  }

  Future<void> _updateDevice({
    required String roomId,
    required String deviceId,
    required Device Function(Device device) transform,
  }) async {
    if (roomId.isEmpty || deviceId.isEmpty) return;

    final layout = await _layoutStorage.loadLayout(roomId);
    if (layout == null) return;

    final now = DateTime.now();
    final updatedDevices = layout.devices.map((device) {
      if (device.id != deviceId) return device;
      return transform(device).copyWith(lastUpdated: now);
    }).toList();

    final updatedLayout = layout.copyWith(devices: updatedDevices);
    await _layoutStorage.saveLayout(roomId, updatedLayout);
    _notifyChanged();
  }
}
