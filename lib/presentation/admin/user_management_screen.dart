import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hello_flutter/domain/entities/app_user.dart';
import 'package:hello_flutter/domain/entities/user_role.dart';
import 'package:hello_flutter/presentation/admin/user_management_sheets.dart';
import 'package:hello_flutter/presentation/providers/app_providers.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/widgets/app_input_dialog.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  List<AppUser> _users = [];
  var _usersLoading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _usersLoading = true);
    final users = await ref.read(authRepositoryProvider).listUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _usersLoading = false;
    });
  }

  Future<void> _createUser(UserRole role) async {
    final userId = await AppInputDialog.show(
      context: context,
      title: 'Create ${role.label}',
      hint: 'User ID',
      confirmLabel: 'Next',
    );
    if (userId == null || !mounted) return;

    final name = await AppInputDialog.show(
      context: context,
      title: 'Full Name',
      hint: 'Name',
    );
    if (name == null || !mounted) return;

    final email = await AppInputDialog.show(
      context: context,
      title: 'Email',
      hint: 'email@labtrack.edu',
    );
    if (email == null || !mounted) return;

    final phone = await AppInputDialog.show(
      context: context,
      title: 'Phone Number',
      hint: 'Phone',
    );
    if (phone == null || !mounted) return;

    final password = await AppInputDialog.show(
      context: context,
      title: 'Temporary Password',
      hint: 'Password',
    );
    if (password == null || !mounted) return;

    try {
      await ref.read(authRepositoryProvider).createUser(
            userId: userId,
            password: password,
            name: name,
            email: email,
            phoneNumber: phone,
            role: role,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$userId created successfully.')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _openUser(AppUser user) {
    final actingUserId = ref.read(authStateProvider).value?.userId ?? '';
    UserManagementSheets.showUserDetails(
      context: context,
      user: user,
      actingUserId: actingUserId,
      repository: ref.read(authRepositoryProvider),
      onChanged: _refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: _usersLoading
          ? Center(child: CircularProgressIndicator(color: palette.accent))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _createUser(UserRole.teacher),
                      icon: const Icon(Icons.school_outlined),
                      label: const Text('Create Teacher'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _createUser(UserRole.technician),
                      icon: const Icon(Icons.build_outlined),
                      label: const Text('Create Technician'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._users.map((user) => _CompactUserCard(
                      user: user,
                      onTap: () => _openUser(user),
                    )),
              ],
            ),
    );
  }
}

class _CompactUserCard extends StatelessWidget {
  const _CompactUserCard({
    required this.user,
    required this.onTap,
  });

  final AppUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: palette.borderSubtle),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              UserRoleAvatar(role: user.role),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${roleEmoji(user.role)} ${user.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.userId,
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: palette.textSecondary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
