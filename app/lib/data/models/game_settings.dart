/// ゲーム設定
class GameSettings {
  final int gestureDuration; // 秒
  final int discussionDuration; // 秒
  final int gestureRounds; // ジェスチャーのラウンド数
  final bool soundEnabled;
  final bool musicEnabled;
  final bool darkMode;
  final String language; // 'ja' or 'en'
  final int wolfCountFor7to8Players; // 7-8人の時のウルフ数

  const GameSettings({
    this.gestureDuration = 15,
    this.discussionDuration = 180, // 3分
    this.gestureRounds = 2, // デフォルト2周
    this.soundEnabled = true,
    this.musicEnabled = false,
    this.darkMode = false,
    this.language = 'ja',
    this.wolfCountFor7to8Players = 2,
  });

  GameSettings copyWith({
    int? gestureDuration,
    int? discussionDuration,
    int? gestureRounds,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? darkMode,
    String? language,
    int? wolfCountFor7to8Players,
  }) {
    return GameSettings(
      gestureDuration: gestureDuration ?? this.gestureDuration,
      discussionDuration: discussionDuration ?? this.discussionDuration,
      gestureRounds: gestureRounds ?? this.gestureRounds,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      wolfCountFor7to8Players:
          wolfCountFor7to8Players ?? this.wolfCountFor7to8Players,
    );
  }

  Map<String, dynamic> toJson() => {
        'gestureDuration': gestureDuration,
        'discussionDuration': discussionDuration,
        'gestureRounds': gestureRounds,
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'darkMode': darkMode,
        'language': language,
        'wolfCountFor7to8Players': wolfCountFor7to8Players,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
        gestureDuration: json['gestureDuration'] as int? ?? 15,
        discussionDuration: json['discussionDuration'] as int? ?? 180,
        gestureRounds: json['gestureRounds'] as int? ?? 2,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        musicEnabled: json['musicEnabled'] as bool? ?? false,
        darkMode: json['darkMode'] as bool? ?? false,
        language: json['language'] as String? ?? 'ja',
        wolfCountFor7to8Players: json['wolfCountFor7to8Players'] as int? ?? 2,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSettings &&
          runtimeType == other.runtimeType &&
          gestureDuration == other.gestureDuration &&
          discussionDuration == other.discussionDuration &&
          gestureRounds == other.gestureRounds &&
          soundEnabled == other.soundEnabled &&
          musicEnabled == other.musicEnabled &&
          darkMode == other.darkMode &&
          language == other.language &&
          wolfCountFor7to8Players == other.wolfCountFor7to8Players;

  @override
  int get hashCode =>
      gestureDuration.hashCode ^
      discussionDuration.hashCode ^
      gestureRounds.hashCode ^
      soundEnabled.hashCode ^
      musicEnabled.hashCode ^
      darkMode.hashCode ^
      language.hashCode ^
      wolfCountFor7to8Players.hashCode;
}
