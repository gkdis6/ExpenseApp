import 'package:financial_app/data/theme/color/dark_app_colors.dart';
import 'package:financial_app/data/theme/color/light_app_colors.dart';
import 'package:financial_app/data/theme/shadows/dart_app_shadows.dart';
import 'package:financial_app/data/theme/shadows/light_app_shadows.dart';
import 'package:financial_app/utils/common.dart';
import 'package:flutter/material.dart';

enum CustomTheme {
  dark(
    DarkAppColors(),
    DarkAppShadows(),
  ),
  light(
    LightAppColors(),
    LightAppShadows(),
  );

  const CustomTheme(this.appColors, this.appShadows);

  final AbstractThemeColors appColors;
  final AbsThemeShadows appShadows;

  ThemeData get themeData {
    switch (this) {
      case CustomTheme.dark:
        return darkTheme;
      case CustomTheme.light:
        return lightTheme;
    }
  }
}

// MaterialColor primarySwatchColor = Colors.lightBlue;

ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    // textTheme: CustomGoogleFonts.diphylleiaTextTheme(
    //   ThemeData(brightness: Brightness.light).textTheme,
    // ),
    colorScheme: ColorScheme.light(background: Colors.white));

// const darkColorSeed = Color(0xbcd5ff7e);
ThemeData darkTheme = ThemeData(
    // primarySwatch: primarySwatchColor,
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.veryDarkGrey,
    // textTheme: GoogleFonts.nanumMyeongjoTextTheme(
    //   ThemeData(brightness: Brightness.dark).textTheme,
    // ),
    colorScheme: ColorScheme.dark(background: AppColors.veryDarkGrey));
