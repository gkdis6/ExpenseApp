import 'dart:ui';

Color transColor(String color) => Color(
      int.parse(color.substring(1), radix: 16) + 0xFF000000,
    );
