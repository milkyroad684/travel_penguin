import 'package:flutter/material.dart';

/// アプリ全体の配色。handoff.txt §15 のトーンに準拠。
class AppColors {
  static const background = Color(0xFFE3F2FD); // 淡い水色
  static const primary = Color(0xFF1E88E5); // 青
  static const correct = Color(0xFF43A047); // 緑
  static const wrong = Color(0xFFE53935); // 赤
  static const combo = Color(0xFFFB8C00); // オレンジ
  static const cardPrefecture = Color(0xFFFFFFFF);
  static const cardCapital = Color(0xFFFFF8E1); // ほんのり暖色で県名と区別
  static const cardSelected = Color(0xFFBBDEFB);
  static const penguinAura = Color(0xFFD1C4E9); // 薄い紫
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
  );
  return base.copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}
