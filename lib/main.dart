import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/splash_scr.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 135, 12, 100),
  background: const Color.fromARGB(255, 10, 0, 10),
);

final theme = ThemeData.dark().copyWith(
  colorScheme: colorScheme,
  scaffoldBackgroundColor: colorScheme.background,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  badgeTheme: BadgeThemeData(textColor: colorScheme.primary),
  iconTheme: IconThemeData(color: colorScheme.primary),
  //
  appBarTheme: AppBarTheme(
    backgroundColor: colorScheme.background,
    foregroundColor: colorScheme.primary,
  ),
  //
  scrollbarTheme: ScrollbarThemeData(
    interactive: true,
    minThumbLength: 70,
    thickness: const MaterialStatePropertyAll(8),
    thumbColor: MaterialStatePropertyAll(colorScheme.primaryContainer),
    radius: const Radius.circular(4),
  ),
  //
  popupMenuTheme: PopupMenuThemeData(
    position: PopupMenuPosition.under,
    color: colorScheme.onPrimary,
    elevation: 6,
    textStyle: TextStyle(color: colorScheme.primary),
  ),
  //
  textTheme: ThemeData().textTheme.copyWith(
        //^ labelText текстового поля
        bodySmall: TextStyle(
          fontFamily: 'AlumniSans',
          fontSize: 18,
          color: colorScheme.primary.withOpacity(.6),
        ),
        //^ текст экрана
        bodyMedium: TextStyle(
          color: colorScheme.tertiary.withOpacity(.8),
        ),
        //
        displayLarge: TextStyle(
          //^ слово "100"
          fontFamily: 'AlumniSans',
          fontWeight: FontWeight.w900,
          color: colorScheme.primaryContainer.withOpacity(.9),
        ),
        displayMedium: TextStyle(
          //^ слово "МЕСТ"
          fontFamily: 'AlumniSans',
          fontWeight: FontWeight.w900,
          color: colorScheme.background,
        ),
        //
        headlineSmall: TextStyle(
          fontSize: 16,
          color: colorScheme.primary,
        ),
        //
        titleSmall: TextStyle(
          //^ названия на картинках
          fontFamily: 'AlumniSans',
          color: colorScheme.tertiary,
          fontSize: 16,
        ),
        titleMedium: TextStyle(
          //^_TextField_
          color: colorScheme.primary,
        ),
        titleLarge: TextStyle(
          //^ заголовок в панели приложений
          fontFamily: 'AlumniSans',
          color: colorScheme.primary,
          fontWeight: FontWeight.w200,
        ),
      ),
  //
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.transparent,
    contentTextStyle: TextStyle(color: colorScheme.tertiary),
  ),
  //
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
        elevation: 3,
        foregroundColor: colorScheme.primary,
        backgroundColor: colorScheme.primaryContainer.withOpacity(.8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        )),
  ),
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
