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

final theme = ThemeData.dark().copyWith(
  colorScheme: colorScheme,
  scaffoldBackgroundColor: colorScheme.background,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  //
  appBarTheme: AppBarTheme(
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
      elevation: 6,
      textStyle: TextStyle(
        color: colorScheme.primary,
      )),
  //
  textTheme: ThemeData().textTheme.copyWith(
        bodyMedium: TextStyle(
          color: colorScheme.tertiary.withOpacity(.8),
        ), // обычный текст на экране
        displayLarge: TextStyle(
          fontFamily: 'AlumniSans',
          fontWeight: FontWeight.w900,
          color: colorScheme.primaryContainer.withOpacity(.9),
        ),
        headlineSmall: const TextStyle(
          fontSize: 16,
        ),
        titleSmall: TextStyle(
          fontFamily: 'AlumniSans',
          color: colorScheme.tertiary,
          fontSize: 16, //^ названия на картинках
        ),
        titleMedium: TextStyle(
          fontFamily: 'AlumniSans',
          color: colorScheme.background,
          fontWeight: FontWeight.w900, //^ "мест"
        ),
        titleLarge: TextStyle(
          fontFamily: 'AlumniSans',
          color: colorScheme.primary,
          fontWeight: FontWeight.w200,
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
