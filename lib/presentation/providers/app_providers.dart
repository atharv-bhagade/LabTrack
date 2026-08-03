import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hello_flutter/controllers/dashboard_controller.dart';
import 'package:hello_flutter/controllers/lab_layout_controller.dart';
import 'package:hello_flutter/controllers/theme_controller.dart';
import 'package:hello_flutter/data/datasources/auth_local_datasource.dart';
import 'package:hello_flutter/data/datasources/repair_local_datasource.dart';
import 'package:hello_flutter/data/repositories/auth_repository_impl.dart';
import 'package:hello_flutter/data/repositories/repair_repository.dart';
import 'package:hello_flutter/domain/entities/app_user.dart';
import 'package:hello_flutter/domain/repositories/auth_repository.dart';
import 'package:hello_flutter/services/layout_storage_service.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authLocalDataSourceProvider));
});

final repairRevisionProvider = StateProvider<int>((ref) => 0);

final repairRepositoryProvider = Provider<RepairRepository>((ref) {
  return RepairRepository(
    RepairLocalDataSource(),
    LayoutStorageService(),
    onChanged: () {
      ref.read(repairRevisionProvider.notifier).state++;
    },
  );
});

final layoutControllerProvider = Provider<LabLayoutController>(
  (ref) => throw UnimplementedError('layoutControllerProvider not overridden'),
);

final themeControllerProvider = Provider<ThemeController>(
  (ref) => throw UnimplementedError('themeControllerProvider not overridden'),
);

final dashboardControllerProvider = Provider<DashboardController>(
  (ref) =>
      throw UnimplementedError('dashboardControllerProvider not overridden'),
);

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.ensureSeeded();
    return repository.getCurrentUser();
  }

  Future<String?> login(String userId, String password) async {
    try {
      final user = await ref.read(authRepositoryProvider).login(
            userId: userId,
            password: password,
          );
      state = AsyncData(user);
      return null;
    } on AuthException catch (error) {
      state = const AsyncData(null);
      return error.message;
    } catch (_) {
      state = const AsyncData(null);
      return 'Login failed. Please try again.';
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
