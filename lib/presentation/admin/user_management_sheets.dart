import 'package:flutter/material.dart';
import 'package:hello_flutter/domain/entities/app_user.dart';
import 'package:hello_flutter/domain/entities/user_role.dart';
import 'package:hello_flutter/domain/repositories/auth_repository.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/widgets/app_confirm_dialog.dart';

class UserManagementSheets {
  static Future<void> showUserDetails({
    required BuildContext context,
    required AppUser user,
    required String actingUserId,
    required AuthRepository repository,
    required VoidCallback onChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.palette.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _UserDetailSheet(
          user: user,
          actingUserId: actingUserId,
          repository: repository,
          onChanged: onChanged,
        );
      },
    );
  }
}

class _UserDetailSheet extends StatelessWidget {
  const _UserDetailSheet({
    required this.user,
    required this.actingUserId,
    required this.repository,
    required this.onChanged,
  });

  final AppUser user;
  final String actingUserId;
  final AuthRepository repository;
  final VoidCallback onChanged;

  bool get _canRemove =>
      user.userId != actingUserId && user.role != UserRole.superAdmin;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _RoleAvatar(role: user.role, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    Text(
                      user.userId,
                      style: TextStyle(color: palette.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailTile(
            icon: Icons.badge_outlined,
            label: 'User ID',
            value: user.userId,
          ),
          _DetailTile(
            icon: Icons.work_outline_rounded,
            label: 'Role',
            value: user.role.label,
          ),
          _DetailTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          _DetailTile(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: user.phoneNumber,
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: () async {
              Navigator.pop(context);
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                backgroundColor: palette.surfaceElevated,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => _EditUserSheet(
                  user: user,
                  repository: repository,
                  onSaved: onChanged,
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Details'),
          ),
          if (_canRemove) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.defective,
                side: BorderSide(color: palette.defective.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _confirmRemove(context),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Remove User'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Remove User',
      message:
          'Remove ${user.name} (${user.userId})? They will no longer be able to sign in.',
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await repository.deleteUser(
        userId: user.userId,
        actingUserId: actingUserId,
      );
      if (!context.mounted) return;
      Navigator.pop(context);
      onChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User removed successfully.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}

class _EditUserSheet extends StatefulWidget {
  const _EditUserSheet({
    required this.user,
    required this.repository,
    required this.onSaved,
  });

  final AppUser user;
  final AuthRepository repository;
  final VoidCallback onSaved;

  @override
  State<_EditUserSheet> createState() => _EditUserSheetState();
}

class _EditUserSheetState extends State<_EditUserSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || email.isEmpty || phone.isEmpty) return;

    setState(() => _saving = true);
    try {
      await widget.repository.updateUserDetails(
        userId: widget.user.userId,
        name: name,
        email: email,
        phoneNumber: phone,
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'User ID',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              child: Text(
                widget.user.userId,
                style: TextStyle(color: palette.textPrimary),
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.work_outline_rounded),
              ),
              child: Text(
                widget.user.role.label,
                style: TextStyle(color: palette.textPrimary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.accent,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: palette.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: palette.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserRoleAvatar extends StatelessWidget {
  const UserRoleAvatar({super.key, required this.role, this.size = 40});

  final UserRole role;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _RoleAvatar(role: role, size: size);
  }
}

class _RoleAvatar extends StatelessWidget {
  const _RoleAvatar({required this.role, required this.size});

  final UserRole role;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (icon, color) = switch (role) {
      UserRole.superAdmin => (Icons.admin_panel_settings_outlined, palette.accent),
      UserRole.teacher => (Icons.school_outlined, palette.working),
      UserRole.technician => (Icons.build_outlined, palette.underRepair),
    };

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

String roleEmoji(UserRole role) => switch (role) {
      UserRole.superAdmin => '🛡️',
      UserRole.teacher => '👨‍🏫',
      UserRole.technician => '🛠️',
    };
