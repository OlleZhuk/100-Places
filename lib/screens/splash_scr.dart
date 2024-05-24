/// Экран входа, ЭВХ
library;

import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'places_scr.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cScheme = Theme.of(context).colorScheme;
    final tTheme = Theme.of(context).textTheme;

    return FlutterSplashScreen(
        useImmersiveMode: true,
        duration: 4.seconds,
        backgroundColor: cScheme.background,
        nextScreen: const PlacesScreen(),
        splashScreenBody: Center(
            child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Text(
              '100',
              style: tTheme.displayLarge!.copyWith(
                fontSize: 260,
              ),
            )
                .animate()
                .fadeIn(
                  duration: 1.seconds,
                )
                .slideX(
                  duration: 1.seconds,
                  curve: Curves.easeOutBack,
                )
                .slideX(
                  delay: 1200.ms,
                  begin: 0,
                  end: 10,
                  duration: 1.seconds,
                  curve: Curves.easeIn,
                ),
            Positioned(
                right: 6,
                bottom: 56,
                child: Text(
                  'МЕСТ',
                  style: tTheme.titleMedium!.copyWith(
                    fontSize: 130,
                  ),
                ))
          ],
        )));
  }
}
