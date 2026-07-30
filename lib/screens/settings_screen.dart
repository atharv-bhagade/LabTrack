import 'package:flutter/material.dart';
import 'package:hello_flutter/controllers/lab_layout_controller.dart';
import 'package:hello_flutter/controllers/theme_controller.dart';
import 'package:hello_flutter/services/settings_storage_service.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/widgets/app_confirm_dialog.dart';
import 'package:hello_flutter/widgets/app_gradient_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.layoutController,
    required this.themeController,
  });

  final LabLayoutController layoutController;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: palette.borderSubtle),
        ),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _SettingsSection(
                title: 'Appearance',
                children: [
                  AnimatedBuilder(
                    animation: themeController,
                    builder: (context, _) {
                      return Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Dark Theme'),
                            subtitle: const Text('Use premium dark dashboard'),
                            value: themeController.mode == AppThemeMode.dark,
                            onChanged: (enabled) {
                              if (enabled) {
                                themeController.setDarkTheme();
                              }
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Light Theme'),
                            subtitle: const Text('Use clean light dashboard'),
                            value: themeController.mode == AppThemeMode.light,
                            onChanged: (enabled) {
                              if (enabled) {
                                themeController.setLightTheme();
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'Lab Layout',
                children: [
                  ListTile(
                    leading: Icon(Icons.delete_sweep_outlined,
                        color: palette.defective),
                    title: const Text('Clear Layout'),
                    subtitle: const Text('Remove all devices from the board'),
                    onTap: () => _clearLayout(context),
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.restart_alt_rounded, color: palette.accent),
                    title: const Text('Reset Device Counter'),
                    subtitle: const Text(
                      'Reset default naming counters for new devices',
                    ),
                    onTap: () => _resetCounter(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _clearLayout(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Clear Layout',
      message:
          'This will remove all placed devices from the lab board. The grid size will remain unchanged.',
      confirmLabel: 'Clear Layout',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await layoutController.clearLayout();
  }

  Future<void> _resetCounter(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Reset Device Counter',
      message:
          'Reset naming counters so the next devices start from Desktop 1, Laptop 1, etc.?',
      confirmLabel: 'Reset',
    );
    if (!confirmed || !context.mounted) return;
    await layoutController.resetDeviceCounter();
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                title,
                style: TextStyle(
                  color: palette.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
