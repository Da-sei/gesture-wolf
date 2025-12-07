import 'dart:math';
import '../models/theme_pair.dart';
import '../data_sources/themes/default_themes.dart';

/// お題データへのアクセスを提供するリポジトリ
class ThemeRepository {
  final List<ThemePair> _customThemes = [];

  /// 全お題を取得（デフォルト + カスタム）
  List<ThemePair> getAllThemes() {
    return [...defaultThemes, ..._customThemes];
  }

  /// カテゴリー別のお題を取得
  List<ThemePair> getThemesByCategory(String category) {
    return getAllThemes().where((theme) => theme.category == category).toList();
  }

  /// 全カテゴリーを取得
  List<String> getCategories() {
    final categories = getAllThemes().map((theme) => theme.category).toSet();
    return categories.toList()..sort();
  }

  /// ランダムにお題を取得
  ThemePair getRandomTheme() {
    final allThemes = getAllThemes();
    final random = Random();
    return allThemes[random.nextInt(allThemes.length)];
  }

  /// IDでお題を取得
  ThemePair? getThemeById(String id) {
    try {
      return getAllThemes().firstWhere((theme) => theme.id == id);
    } catch (e) {
      return null;
    }
  }

  /// カスタムお題を追加
  void addCustomTheme(ThemePair theme) {
    _customThemes.add(theme);
  }

  /// カスタムお題を削除
  void removeCustomTheme(String themeId) {
    _customThemes.removeWhere((theme) => theme.id == themeId);
  }

  /// カスタムお題を全て取得
  List<ThemePair> getCustomThemes() {
    return List.unmodifiable(_customThemes);
  }

  /// カスタムお題を設定（読み込み時用）
  void setCustomThemes(List<ThemePair> themes) {
    _customThemes.clear();
    _customThemes.addAll(themes);
  }
}
