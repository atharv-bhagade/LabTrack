import 'package:hello_flutter/data/datasources/auth_local_datasource.dart';
import 'package:hello_flutter/domain/entities/app_user.dart';
import 'package:hello_flutter/domain/entities/user_role.dart';
import 'package:hello_flutter/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final AuthLocalDataSource _local;

  @override
  Future<void> ensureSeeded() => _local.seedIfEmpty();

  @override
  Future<AppUser?> getCurrentUser() async {
    await _local.seedIfEmpty();
    final sessionId = await _local.loadSessionUserId();
    if (sessionId == null) return null;

    final users = await _local.loadUsers();
    for (final user in users) {
      if (user.userId == sessionId) return user;
    }
    return null;
  }

  @override
  Future<AppUser> login({
    required String userId,
    required String password,
  }) async {
    await _local.seedIfEmpty();
    final normalizedId = userId.trim().toUpperCase();
    final users = await _local.loadUsers();

    for (final user in users) {
      if (user.userId == normalizedId && user.password == password) {
        await _local.saveSessionUserId(user.userId);
        return user;
      }
    }

    throw AuthException('Invalid User ID or password.');
  }

  @override
  Future<void> logout() => _local.clearSession();

  @override
  Future<List<AppUser>> listUsers() async {
    await _local.seedIfEmpty();
    return _local.loadUsers();
  }

  @override
  Future<AppUser> createUser({
    required String userId,
    required String password,
    required String name,
    required String email,
    required String phoneNumber,
    required UserRole role,
  }) async {
    final normalizedId = userId.trim().toUpperCase();
    final users = await _local.loadUsers();

    if (users.any((user) => user.userId == normalizedId)) {
      throw AuthException('User ID already exists.');
    }

    final user = AppUser(
      userId: normalizedId,
      password: password,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
    );

    users.add(user);
    await _local.saveUsers(users);
    return user;
  }

  @override
  Future<AppUser> updateUserDetails({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    final users = await _local.loadUsers();
    final index = users.indexWhere((user) => user.userId == userId);
    if (index == -1) {
      throw AuthException('User not found.');
    }

    final updated = users[index].copyWith(
      name: name.trim(),
      email: email.trim(),
      phoneNumber: phoneNumber.trim(),
    );
    users[index] = updated;
    await _local.saveUsers(users);
    return updated;
  }

  @override
  Future<void> deleteUser({
    required String userId,
    required String actingUserId,
  }) async {
    if (userId == actingUserId) {
      throw AuthException('You cannot remove your own account.');
    }

    final users = await _local.loadUsers();
    final target = users.cast<AppUser?>().firstWhere(
          (user) => user?.userId == userId,
          orElse: () => null,
        );
    if (target == null) {
      throw AuthException('User not found.');
    }
    if (target.role == UserRole.superAdmin) {
      throw AuthException('Super Admin accounts cannot be removed.');
    }

    users.removeWhere((user) => user.userId == userId);
    await _local.saveUsers(users);

    final assignments = await _local.loadTechnicianAssignments();
    if (assignments.remove(userId) != null) {
      await _local.saveTechnicianAssignments(assignments);
    }
  }

  @override
  Future<void> assignTechnician({
    required String technicianId,
    required String buildingId,
  }) async {
    final assignments = await _local.loadTechnicianAssignments();
    final current = {...assignments[technicianId] ?? const []};
    current.add(buildingId);
    assignments[technicianId] = current.toList();
    await _local.saveTechnicianAssignments(assignments);
  }

  @override
  Future<List<String>> technicianBuildingIds(String technicianId) async {
    final assignments = await _local.loadTechnicianAssignments();
    return assignments[technicianId] ?? const [];
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
