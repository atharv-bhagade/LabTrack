import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hello_flutter/constants/app_info.dart';
import 'package:hello_flutter/controllers/dashboard_controller.dart';
import 'package:hello_flutter/controllers/lab_layout_controller.dart';
import 'package:hello_flutter/controllers/theme_controller.dart';
import 'package:hello_flutter/presentation/navigation/role_home_screen.dart';
import 'package:hello_flutter/theme/app_palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.layoutController,
    required this.themeController,
    required this.dashboardController,
  });

  final LabLayoutController layoutController;
  final ThemeController themeController;
  final DashboardController dashboardController;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _toolRotation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    _scaleIn = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _toolRotation = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      widget.themeController.load(),
      widget.dashboardController.load(),
    ]);

    if (!mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: const RoleHomeScreen(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const palette = AppPalette.dark;

    return Material(
      color: palette.background,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              palette.background,
              palette.backgroundGradientEnd,
              palette.surface.withValues(alpha: 0.95),
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: _GlowOrb(
                color: palette.accent.withValues(alpha: 0.18),
                size: 280,
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: _GlowOrb(
                color: palette.working.withValues(alpha: 0.1),
                size: 240,
              ),
            ),
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: ScaleTransition(
                    scale: _scaleIn,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LogoBadge(
                          palette: palette,
                          toolRotation: _toolRotation,
                        ),
                        const SizedBox(height: 36),
                        SlideTransition(
                          position: _titleSlide,
                          child: Column(
                            children: [
                              Text(
                                AppInfo.appName,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 46,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.5,
                                  color: palette.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppInfo.tagline,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.4,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: palette.accent.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({
    required this.palette,
    required this.toolRotation,
  });

  final AppPalette palette;
  final Animation<double> toolRotation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.surfaceElevated,
            palette.surface,
          ],
        ),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.accent.withValues(alpha: 0.25),
            blurRadius: 40,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: toolRotation,
        builder: (context, child) {
          return Transform.rotate(
            angle: toolRotation.value,
            child: child,
          );
        },
        child: Icon(
          Icons.build_circle_outlined,
          size: 52,
          color: palette.accent,
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.45,
            spreadRadius: size * 0.08,
          ),
        ],
      ),
    );
  }
}
