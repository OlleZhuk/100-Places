import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget {
  const GradientAppBar({super.key});

  @override
  Widget build(BuildContext context) => Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Theme.of(context).colorScheme.background.withOpacity(0.8),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.7, 1],
      )));
}
