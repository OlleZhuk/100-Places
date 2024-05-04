import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/splash_scr.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 135, 12, 100),
  background: const Color.fromARGB(255, 10, 0, 10),
  // background: const Color.fromARGB(20, 135, 12, 100),
  // background: const Color.fromARGB(255, 56, 49, 66),
);

final theme = ThemeData().copyWith(
  colorScheme: colorScheme,
  scaffoldBackgroundColor: colorScheme.background,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  //
  appBarTheme: AppBarTheme(
    toolbarHeight: 70,
    backgroundColor: colorScheme.onPrimary,
    foregroundColor: colorScheme.primary,
  ),
  //
  scrollbarTheme: ScrollbarThemeData(
    interactive: true,
    minThumbLength: 70,
    thickness: const MaterialStatePropertyAll(8),
    thumbColor: MaterialStatePropertyAll(
      colorScheme.primaryContainer,
    ),
    radius: const Radius.circular(4),
  ),
  //
  popupMenuTheme: PopupMenuThemeData(
    position: PopupMenuPosition.under,
    color: colorScheme.onPrimary,
    textStyle: ThemeData().textTheme.bodyMedium!.copyWith(
          color: colorScheme.primary,
        ),
  ),
  //
  textTheme: ThemeData().textTheme.copyWith(
        titleSmall: TextStyle(
          fontFamily: 'UbuntuCondensed',
          color: colorScheme.tertiary,
          fontSize: 16,
        ),
        titleMedium: TextStyle(
          // fontFamily: 'UbuntuCondensed',
          fontFamily: 'AlumniSans',
          color: colorScheme.primary,
          fontSize: 20,
        ),
        titleLarge: const TextStyle(
          fontFamily: 'AlumniSans',
          fontWeight: FontWeight.w300,
          fontSize: 35,
        ),
        displayLarge: const TextStyle(
          fontFamily: 'AlumniSans',
          fontWeight: FontWeight.w900,
          fontSize: 200,
        ),
        headlineSmall: const TextStyle(
          fontSize: 16,
        ),
      ),
  badgeTheme: BadgeThemeData(textColor: colorScheme.primary),
  snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.transparent,
      contentTextStyle: TextStyle(
        color: colorScheme.tertiary,
      )),
);

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const SplashScreen(),
    );
  }
}
