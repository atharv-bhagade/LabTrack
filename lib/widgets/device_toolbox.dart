import 'package:flutter/material.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/utils/device_type_info.dart';
import 'package:hello_flutter/widgets/toolbox_draggable_item.dart';

class DeviceToolbox extends StatefulWidget {
  const DeviceToolbox({
    super.key,
    required this.horizontal,
  });

  final bool horizontal;

  @override
  State<DeviceToolbox> createState() => _DeviceToolboxState();
}

class _DeviceToolboxState extends State<DeviceToolbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slide = Tween<Offset>(
      begin: widget.horizontal ? const Offset(0, 0.2) : const Offset(-0.15, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final items = DeviceTypeInfo.toolboxTypes
        .map(
          (type) => ToolboxDraggableItem(
            type: type,
            compact: widget.horizontal,
          ),
        )
        .toList();

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surfaceElevated.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: widget.horizontal
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        items[i],
                      ],
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Devices',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        items[i],
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
