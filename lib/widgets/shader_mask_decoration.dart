import 'package:flutter/material.dart';

class ShaderMaskDecoration extends StatelessWidget {
  const ShaderMaskDecoration({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cScheme = Theme.of(context).colorScheme;

    return ShaderMask(
      shaderCallback: (Rect rect) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          cScheme.background,
          Colors.transparent,
          Colors.transparent,
          cScheme.background,
        ],
        stops: const [0.0, 0.03, 0.87, 1.0], //^ 5% цвет, 79% transparent, 15% цвет
      ).createShader(rect),
      blendMode: BlendMode.dstOut,
      child: child,
    );
  }
}
