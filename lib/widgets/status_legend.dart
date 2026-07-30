import 'package:flutter/material.dart';
import 'package:hello_flutter/theme/app_palette.dart';

class StatusLegend extends StatefulWidget {
  const StatusLegend({
    super.key,
    this.compact = false,
    this.workingCount = 0,
    this.nonWorkingCount = 0,
  });

  final bool compact;
  final int workingCount;
  final int nonWorkingCount;

  @override
  State<StatusLegend> createState() => _StatusLegendState();
}

class _StatusLegendState extends State<StatusLegend>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slide = Tween<Offset>(
      begin: widget.compact ? const Offset(-0.08, 0) : const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LegendItem(
              compact: widget.compact,
              emoji: '🟢',
              label: 'Working (${widget.workingCount})',
              color: palette.working,
            ),
            SizedBox(width: widget.compact ? 10 : 20),
            _LegendItem(
              compact: widget.compact,
              emoji: '🔴',
              label: 'Non Working (${widget.nonWorkingCount})',
              color: palette.defective,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.compact,
    required this.emoji,
    required this.label,
    required this.color,
  });

  final bool compact;
  final String emoji;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: palette.surfaceElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: compact ? 12 : 14)),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
