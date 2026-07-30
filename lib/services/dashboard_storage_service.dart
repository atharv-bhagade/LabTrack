import 'dart:convert';

import 'package:hello_flutter/models/building.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardStorageService {
  static const _dashboardKey = 'campus_dashboard_data';

  Future<List<Building>> loadBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dashboardKey);
    if (raw == null) {
      return const [];
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final buildingsJson = (json['buildings'] as List<dynamic>?) ?? const [];
      return buildingsJson
          .whereType<Map<String, dynamic>>()
          .map(Building.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveBuildings(List<Building> buildings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _dashboardKey,
      jsonEncode({
        'buildings': buildings.map((building) => building.toJson()).toList(),
      }),
    );
  }
}
