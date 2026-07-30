import 'package:flutter/material.dart';
import 'package:hello_flutter/theme/app_palette.dart';

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.background,
            palette.backgroundGradientEnd,
          ],
        ),
      ),
      child: child,
    );
  }
}
