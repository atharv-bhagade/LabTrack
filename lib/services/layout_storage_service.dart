import 'dart:convert';

import 'package:hello_flutter/models/lab_layout_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LayoutStorageService {
  static String _layoutKey(String roomId) => 'lab_layout_$roomId';

  Future<LabLayoutData?> loadLayout(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_layoutKey(roomId));
    if (raw == null) {
      return null;
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return LabLayoutData.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLayout(String roomId, LabLayoutData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_layoutKey(roomId), jsonEncode(data.toJson()));
  }

  Future<void> deleteLayout(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_layoutKey(roomId));
  }

  Future<void> deleteLayouts(Iterable<String> roomIds) async {
    final prefs = await SharedPreferences.getInstance();
    for (final roomId in roomIds) {
      await prefs.remove(_layoutKey(roomId));
    }
  }

  /// Copies stored layout from one room id to another, then removes the old key.
  Future<void> migrateLayout({
    required String fromRoomId,
    required String toRoomId,
  }) async {
    if (fromRoomId.isEmpty ||
        toRoomId.isEmpty ||
        fromRoomId == toRoomId) {
      return;
    }

    final layout = await loadLayout(fromRoomId);
    if (layout == null) return;

    await saveLayout(toRoomId, layout);
    await deleteLayout(fromRoomId);
  }
}
