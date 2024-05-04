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
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final TextTheme tTheme = Theme.of(context).textTheme;

    return FlutterSplashScreen(
        useImmersiveMode: true,
        duration: 5.seconds,
        backgroundColor: cScheme.background,
        nextScreen: const PlacesScreen(),
        splashScreenBody: Center(
            child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                child: Text(
              '100',
              textScaleFactor: 1.2,
              style: tTheme.displayLarge!.copyWith(
                color: cScheme.primaryContainer.withOpacity(.9),
              ),
            )
                    .animate()
                    .fadeIn(duration: 4.seconds)
                    .scale(
                      duration: 4.seconds,
                      curve: Curves.easeOutBack,
                    )
                    .fadeOut(
                      delay: 4.seconds,
                      duration: 1.seconds,
                    )),
            Positioned(
                top: 58,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    'мест',
                    textScaleFactor: 9,
                    style: tTheme.titleMedium!.copyWith(
                      color: cScheme.background,
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().fadeIn(duration: 4.seconds),
                ))
          ],
        )));
  }
}
