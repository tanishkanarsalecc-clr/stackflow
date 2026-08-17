import 'dart:ui';

import 'package:flutter/material.dart';

class StackFlowBackground extends StatelessWidget {
  final Widget child;
  final bool showBlobs;

  const StackFlowBackground({
    super.key,
    required this.child,
    this.showBlobs = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8F9FF),
                  Color(0xFFF4F5FB),
                  Color(0xFFF9FAFD),
                ],
              ),
            ),
          ),
        ),

        if (showBlobs) ...[
          Positioned(
            top: -110,
            right: -90,
            child: _GlowBlob(
              size: 270,
              color: const Color(0xFF5B5FEF),
            ),
          ),

          Positioned(
            top: 260,
            left: -150,
            child: _GlowBlob(
              size: 280,
              color: const Color(0xFF7C3AED),
            ),
          ),

          Positioned(
            bottom: -120,
            right: -100,
            child: _GlowBlob(
              size: 260,
              color: const Color(0xFF06B6D4),
            ),
          ),
        ],

        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 55,
              sigmaY: 55,
            ),
            child: const SizedBox(),
          ),
        ),

        Positioned.fill(child: child),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBlob({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.20),
              color.withValues(alpha: 0.08),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}