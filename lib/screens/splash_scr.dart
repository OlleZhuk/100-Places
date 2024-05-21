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
          alignment: Alignment.center,
          children: [
            Positioned(
              child: Text(
                '100',
                style: tTheme.displayLarge!.copyWith(
                  fontSize: 256,
                ),
              )
                  .animate()
                  .scale(
                    duration: 3.seconds,
                    curve: Curves.easeInOutBack,
                  )
                  .fadeOut(
                    delay: 2.seconds,
                    duration: 2.seconds,
                  ),
            ),
            Positioned(
                child: Text(
              'МЕСТ',
              style: tTheme.titleMedium!.copyWith(
                fontSize: 135,
              ),
            ))
          ],
        )));
  }
}
