import 'package:hello_flutter/domain/entities/app_user.dart';
import 'package:hello_flutter/domain/entities/user_role.dart';

abstract class AuthRepository {
  Future<void> ensureSeeded();

  Future<AppUser?> getCurrentUser();

  Future<AppUser> login({required String userId, required String password});

  Future<void> logout();

  Future<List<AppUser>> listUsers();

  Future<AppUser> createUser({
    required String userId,
    required String password,
    required String name,
    required String email,
    required String phoneNumber,
    required UserRole role,
  });

  Future<AppUser> updateUserDetails({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
  });

  Future<void> deleteUser({
    required String userId,
    required String actingUserId,
  });

  Future<void> assignTechnician({
    required String technicianId,
    required String buildingId,
  });

  Future<List<String>> technicianBuildingIds(String technicianId);
}
