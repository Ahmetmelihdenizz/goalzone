import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D0F14);
  static const Color primary = Color.fromARGB(255, 232, 149, 17);
  static const Color secondary = Color(0xFFFF0055);
  static const Color wall = Color.fromARGB(255, 141, 37, 155);

  // Burada kesinlikle areaFill olmalı
  static const Color areaFill = Color(0x44FFFF00);

  static const Color sparkle1 = Color(0xFF00FFFF);
  static const Color sparkle2 = Color(0xFFFFAA00);
}

final ThemeData appTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.dark(
    primary: const Color.fromARGB(255, 167, 49, 144),
    secondary: AppColors.secondary,
    background: AppColors.background,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
);
