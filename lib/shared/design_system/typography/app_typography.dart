import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static const fontFamily = 'Roboto';

  static TextStyle get title =>
      const TextStyle(fontSize: 24, fontWeight: FontWeight.w700);

  static TextStyle get body =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
}
