import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_flutter/constants/app_info.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/widgets/app_gradient_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('About'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: palette.borderSubtle),
        ),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppInfo.appName,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Version ${AppInfo.version}',
                        style: TextStyle(color: palette.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Developer:',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppInfo.developer,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Description:',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppInfo.description,
                        style: TextStyle(
                          color: palette.textPrimary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          _ContactButton(
                            icon: Icons.code_rounded,
                            label: 'GitHub',
                            onTap: () => _copyToClipboard(
                              context,
                              AppInfo.githubUrl,
                              'GitHub URL copied',
                            ),
                          ),
                          const SizedBox(width: 12),
                          _ContactButton(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            onTap: () => _copyToClipboard(
                              context,
                              AppInfo.email,
                              'Email copied',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(
    BuildContext context,
    String value,
    String message,
  ) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Expanded(
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: palette.surface,
          foregroundColor: palette.accent,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
