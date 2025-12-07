import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/game_settings.dart';
import '../data/models/theme_pair.dart';

/// ローカルストレージを管理するサービス
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Settings
  Future<void> saveSettings(GameSettings settings) async {
    final json = jsonEncode(settings.toJson());
    await _prefs.setString('game_settings', json);
  }

  GameSettings? loadSettings() {
    final json = _prefs.getString('game_settings');
    if (json == null) return null;

    final map = jsonDecode(json) as Map<String, dynamic>;
    return GameSettings.fromJson(map);
  }

  // Custom Themes
  Future<void> saveCustomThemes(List<ThemePair> themes) async {
    final json = jsonEncode(themes.map((t) => t.toJson()).toList());
    await _prefs.setString('custom_themes', json);
  }

  List<ThemePair> loadCustomThemes() {
    final json = _prefs.getString('custom_themes');
    if (json == null) return [];

    final list = jsonDecode(json) as List;
    return list.map((item) => ThemePair.fromJson(item as Map<String, dynamic>)).toList();
  }

  // Favorite Themes
  Future<void> saveFavoriteThemeIds(List<String> ids) async {
    await _prefs.setStringList('favorite_themes', ids);
  }

  List<String> loadFavoriteThemeIds() {
    return _prefs.getStringList('favorite_themes') ?? [];
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
