import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hello_flutter/presentation/navigation/role_home_screen.dart';
import 'package:hello_flutter/presentation/providers/app_providers.dart';
import 'package:hello_flutter/screens/dashboard_screen.dart';

/// Super Admin campus dashboard — wraps the existing dashboard with full CRUD.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardScreen(
      layoutController: ref.watch(layoutControllerProvider),
      themeController: ref.watch(themeControllerProvider),
      dashboardController: ref.watch(dashboardControllerProvider),
      canManageCampus: true,
      onLogout: () => _logout(context, ref),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const RoleHomeScreen()),
      (_) => false,
    );
  }
}
