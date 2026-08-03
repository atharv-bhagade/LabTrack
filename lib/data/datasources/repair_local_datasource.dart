import 'dart:convert';

import 'package:hello_flutter/domain/entities/repair_ticket.dart';
import 'package:hello_flutter/models/device_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RepairLocalDataSource {
  static const _ticketsKey = 'repair_tickets_v1';

  Future<List<RepairTicket>> loadTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ticketsKey);
    if (raw == null) return _seedTickets();

    try {
      final json = jsonDecode(raw) as List<dynamic>;
      final tickets = json
          .whereType<Map<String, dynamic>>()
          .map(RepairTicket.fromJson)
          .toList();
      if (tickets.isEmpty) return _seedTickets();
      return tickets;
    } catch (_) {
      return _seedTickets();
    }
  }

  Future<void> saveTickets(List<RepairTicket> tickets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _ticketsKey,
      jsonEncode(tickets.map((ticket) => ticket.toJson()).toList()),
    );
  }

  List<RepairTicket> _seedTickets() {
    final now = DateTime.now();
    return [
      RepairTicket(
        id: 'repair_1',
        deviceId: 'seed_device_1',
        deviceName: 'Desktop 3',
        deviceType: DeviceType.desktop,
        roomId: 'seed_room_1',
        roomName: 'Lab 101',
        floorName: 'Floor 1',
        buildingName: 'Building A',
        faultDescription: 'System not booting after power outage.',
        status: RepairStatus.available,
        reportedAt: now.subtract(const Duration(hours: 5)),
        reportedBy: 'TEACH001',
        reportedByName: 'Teacher One',
      ),
      RepairTicket(
        id: 'repair_2',
        deviceId: 'seed_device_2',
        deviceName: 'Printer 1',
        deviceType: DeviceType.printer,
        roomId: 'seed_room_2',
        roomName: 'Lab 203',
        floorName: 'Floor 2',
        buildingName: 'Building B',
        faultDescription: 'Paper jam sensor error.',
        status: RepairStatus.accepted,
        reportedAt: now.subtract(const Duration(days: 1)),
        reportedBy: 'TEACH002',
        reportedByName: 'Teacher Two',
        acceptedBy: 'TECH001',
        acceptedByName: 'Technician One',
        acceptedTime: now.subtract(const Duration(hours: 10)),
      ),
      RepairTicket(
        id: 'repair_3',
        deviceId: 'seed_device_3',
        deviceName: 'Laptop 2',
        deviceType: DeviceType.laptop,
        roomId: 'seed_room_3',
        roomName: 'Lab 302',
        floorName: 'Floor 3',
        buildingName: 'Building A',
        faultDescription: 'Keyboard keys unresponsive.',
        status: RepairStatus.completed,
        reportedAt: now.subtract(const Duration(days: 3)),
        reportedBy: 'ADMIN001',
        reportedByName: 'Super Admin One',
        acceptedBy: 'TECH001',
        acceptedByName: 'Technician One',
        acceptedTime: now.subtract(const Duration(days: 2)),
        completedTime: now.subtract(const Duration(days: 1)),
        completedByName: 'Technician One',
        completedByPhone: '9000000201',
        repairNotes: 'Replaced keyboard module.',
      ),
    ];
  }
}
