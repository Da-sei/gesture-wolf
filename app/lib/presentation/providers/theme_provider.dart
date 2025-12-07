import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/theme_pair.dart';
import '../../data/repositories/theme_repository.dart';

/// ThemeRepositoryのProvider
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepository();
});

/// 全お題を取得するProvider
final themesProvider = Provider<List<ThemePair>>((ref) {
  return ref.watch(themeRepositoryProvider).getAllThemes();
});

/// カテゴリー別お題を取得するProvider
final themesByCategoryProvider =
    Provider.family<List<ThemePair>, String>((ref, category) {
  return ref.watch(themeRepositoryProvider).getThemesByCategory(category);
});

/// 全カテゴリーを取得するProvider
final categoriesProvider = Provider<List<String>>((ref) {
  return ref.watch(themeRepositoryProvider).getCategories();
});

/// カスタムお題のProvider
final customThemesProvider =
    StateNotifierProvider<CustomThemesNotifier, List<ThemePair>>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return CustomThemesNotifier(repository);
});

/// カスタムお題の状態管理
class CustomThemesNotifier extends StateNotifier<List<ThemePair>> {
  final ThemeRepository _repository;

  CustomThemesNotifier(this._repository)
      : super(_repository.getCustomThemes());

  /// カスタムお題を追加
  Future<void> addCustomTheme(ThemePair theme) async {
    _repository.addCustomTheme(theme);
    state = _repository.getCustomThemes();
  }

  /// カスタムお題を削除
  Future<void> removeCustomTheme(String themeId) async {
    _repository.removeCustomTheme(themeId);
    state = _repository.getCustomThemes();
  }

  /// カスタムお題をロード
  void loadCustomThemes(List<ThemePair> themes) {
    _repository.setCustomThemes(themes);
    state = _repository.getCustomThemes();
  }
}
