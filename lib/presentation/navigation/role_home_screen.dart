import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hello_flutter/domain/entities/user_role.dart';
import 'package:hello_flutter/presentation/admin/admin_dashboard_screen.dart';
import 'package:hello_flutter/presentation/auth/login_screen.dart';
import 'package:hello_flutter/presentation/providers/app_providers.dart';
import 'package:hello_flutter/presentation/teacher/teacher_dashboard_screen.dart';
import 'package:hello_flutter/presentation/technician/technician_dashboard_screen.dart';

class RoleHomeScreen extends ConsumerWidget {
  const RoleHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return auth.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => const LoginScreen(),
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        return switch (user.role) {
          UserRole.superAdmin => const AdminDashboardScreen(),
          UserRole.teacher => const TeacherDashboardScreen(),
          UserRole.technician => const TechnicianDashboardScreen(),
        };
      },
    );
  }
}
