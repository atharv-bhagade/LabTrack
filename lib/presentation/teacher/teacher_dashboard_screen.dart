import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hello_flutter/constants/app_info.dart';
import 'package:hello_flutter/presentation/navigation/role_home_screen.dart';
import 'package:hello_flutter/presentation/providers/app_providers.dart';
import 'package:hello_flutter/screens/dashboard_screen.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardScreen(
      layoutController: ref.watch(layoutControllerProvider),
      themeController: ref.watch(themeControllerProvider),
      dashboardController: ref.watch(dashboardControllerProvider),
      canManageCampus: false,
      dashboardTitle: '${AppInfo.appName} · Teacher',
      onLogout: () => _logout(context, ref),
      labLayoutReadOnly: true,
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
