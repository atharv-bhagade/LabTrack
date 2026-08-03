import 'dart:convert';

import 'package:hello_flutter/domain/entities/app_user.dart';
import 'package:hello_flutter/domain/entities/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const _usersKey = 'auth_users_v1';
  static const _sessionKey = 'auth_session_user_id';
  static const _assignmentsKey = 'technician_assignments_v1';

  Future<void> seedIfEmpty() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_usersKey)) return;

    final defaults = [
      AppUser(
        userId: 'ADMIN001',
        password: 'admin123',
        name: 'Super Admin One',
        email: 'admin1@labtrack.edu',
        phoneNumber: '9000000001',
        role: UserRole.superAdmin,
      ),
      AppUser(
        userId: 'ADMIN002',
        password: 'admin123',
        name: 'Super Admin Two',
        email: 'admin2@labtrack.edu',
        phoneNumber: '9000000002',
        role: UserRole.superAdmin,
      ),
      AppUser(
        userId: 'TEACH001',
        password: 'teach123',
        name: 'Teacher One',
        email: 'teacher1@labtrack.edu',
        phoneNumber: '9000000101',
        role: UserRole.teacher,
      ),
      AppUser(
        userId: 'TEACH002',
        password: 'teach123',
        name: 'Teacher Two',
        email: 'teacher2@labtrack.edu',
        phoneNumber: '9000000102',
        role: UserRole.teacher,
      ),
      AppUser(
        userId: 'TECH001',
        password: 'tech123',
        name: 'Technician One',
        email: 'tech1@labtrack.edu',
        phoneNumber: '9000000201',
        role: UserRole.technician,
      ),
      AppUser(
        userId: 'TECH002',
        password: 'tech123',
        name: 'Technician Two',
        email: 'tech2@labtrack.edu',
        phoneNumber: '9000000202',
        role: UserRole.technician,
      ),
    ];

    await _saveUsers(defaults, prefs);
  }

  Future<List<AppUser>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];

    final json = jsonDecode(raw) as List<dynamic>;
    return json
        .whereType<Map<String, dynamic>>()
        .map(AppUser.fromJson)
        .toList();
  }

  Future<void> saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await _saveUsers(users, prefs);
  }

  Future<void> _saveUsers(List<AppUser> users, SharedPreferences prefs) async {
    await prefs.setString(
      _usersKey,
      jsonEncode(users.map((user) => user.toJson()).toList()),
    );
  }

  Future<String?> loadSessionUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<void> saveSessionUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<Map<String, List<String>>> loadTechnicianAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_assignmentsKey);
    if (raw == null) return {};

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).map((e) => e as String).toList(),
      ),
    );
  }

  Future<void> saveTechnicianAssignments(
    Map<String, List<String>> assignments,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_assignmentsKey, jsonEncode(assignments));
  }
}
