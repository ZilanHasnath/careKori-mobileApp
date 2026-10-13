import 'dart:math' as math;

import 'package:flutter/material.dart';

class CareLoader extends StatefulWidget {
  const CareLoader({super.key, this.label, this.size = 72});

  final String? label;
  final double size;

  @override
  State<CareLoader> createState() => _CareLoaderState();
}

class _CareLoaderState extends State<CareLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final size = widget.size;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                final beat = 1 + 0.18 * math.sin(t * 2 * math.pi).abs();
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: t * 2 * math.pi,
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: CircularProgressIndicator(
                          value: 0.28,
                          strokeWidth: 3,
                          strokeCap: StrokeCap.round,
                          color: color,
                          backgroundColor: color.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: beat,
                      child: Icon(Icons.favorite_rounded,
                          size: size * 0.4, color: color),
                    ),
                  ],
                );
              },
            ),
          ),
          if (widget.label != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.label!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ],
      ),
    );
  }
}
