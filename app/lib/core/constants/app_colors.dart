import 'package:flutter/material.dart';

/// アプリで使用するカラーパレット
class AppColors {
  AppColors._();

  // Primary Colors
  static const primary = Color(0xFFFF6B35); // オレンジ（活発）
  static const primaryLight = Color(0xFFFF8F6B);
  static const primaryDark = Color(0xFFCC5529);

  // Secondary Colors
  static const secondary = Color(0xFF4ECDC4); // ターコイズ（楽しさ）
  static const secondaryLight = Color(0xFF7FD9D3);
  static const secondaryDark = Color(0xFF3DA49D);

  // Accent Colors
  static const accent = Color(0xFFFFC857); // イエロー（注目）
  static const accentLight = Color(0xFFFFD67F);
  static const accentDark = Color(0xFFCCA046);

  // Status Colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);

  // Neutral Colors (Light Mode)
  static const backgroundLight = Color(0xFFFAFAFA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textPrimaryLight = Color(0xFF212121);
  static const textSecondaryLight = Color(0xFF757575);

  // Neutral Colors (Dark Mode)
  static const backgroundDark = Color(0xFF121212);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const textPrimaryDark = Color(0xFFE0E0E0);
  static const textSecondaryDark = Color(0xFFB0B0B0);

  // Special Colors
  static const wolfColor = Color(0xFFD32F2F); // ウルフ用
  static const citizenColor = Color(0xFF1976D2); // 市民用
}
