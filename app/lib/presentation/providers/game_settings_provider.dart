import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/game_settings.dart';

/// ゲーム設定のProvider
final gameSettingsProvider =
    StateNotifierProvider<GameSettingsNotifier, GameSettings>((ref) {
  return GameSettingsNotifier();
});

/// ゲーム設定の状態管理
class GameSettingsNotifier extends StateNotifier<GameSettings> {
  GameSettingsNotifier() : super(const GameSettings());

  /// ジェスチャー時間を更新
  void updateGestureDuration(int seconds) {
    if (seconds < 10 || seconds > 30) return;
    state = state.copyWith(gestureDuration: seconds);
  }

  /// ディスカッション時間を更新
  void updateDiscussionDuration(int seconds) {
    if (seconds < 60 || seconds > 300) return;
    state = state.copyWith(discussionDuration: seconds);
  }

  /// 効果音のON/OFFを切り替え
  void toggleSound(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
  }

  /// BGMのON/OFFを切り替え
  void toggleMusic(bool enabled) {
    state = state.copyWith(musicEnabled: enabled);
  }

  /// ダークモードのON/OFFを切り替え
  void toggleDarkMode(bool enabled) {
    state = state.copyWith(darkMode: enabled);
  }

  /// 言語を設定
  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  /// 7-8人の時のウルフ数を設定
  void setWolfCountFor7to8Players(int count) {
    if (count < 1 || count > 2) return;
    state = state.copyWith(wolfCountFor7to8Players: count);
  }

  /// ジェスチャーのラウンド数を設定
  void updateGestureRounds(int rounds) {
    if (rounds < 1 || rounds > 5) return;
    state = state.copyWith(gestureRounds: rounds);
  }

  /// 設定をロード
  void loadSettings(GameSettings settings) {
    state = settings;
  }
}
