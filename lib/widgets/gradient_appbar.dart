import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget {
  const GradientAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cScheme = Theme.of(context).colorScheme;

    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
      colors: [
        Colors.transparent,
        cScheme.background,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [.5, 1],
    )));
  }
}
