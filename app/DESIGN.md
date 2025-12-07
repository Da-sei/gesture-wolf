# ジェスチャーウルフ - 設計書

## 1. アーキテクチャ設計

### 1.1 全体アーキテクチャ

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (UI Components / Screens / Widgets)    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         State Management Layer          │
│     (Riverpod Providers / Notifiers)    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│           Business Logic Layer          │
│    (Services / Controllers / Use Cases) │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│            Data Layer                   │
│  (Repositories / Data Sources / Models) │
└─────────────────────────────────────────┘
```

### 1.2 ディレクトリ構成

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_sizes.dart
│   │   └── app_strings.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── light_theme.dart
│   │   └── dark_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   └── utils/
│       ├── extensions.dart
│       └── validators.dart
├── data/
│   ├── models/
│   │   ├── player.dart
│   │   ├── theme_pair.dart
│   │   ├── game_state.dart
│   │   └── game_settings.dart
│   ├── repositories/
│   │   ├── theme_repository.dart
│   │   ├── settings_repository.dart
│   │   └── game_history_repository.dart
│   └── data_sources/
│       ├── local/
│       │   ├── theme_data_source.dart
│       │   └── settings_data_source.dart
│       └── themes/
│           └── default_themes.dart
├── domain/
│   ├── entities/
│   │   ├── player_entity.dart
│   │   └── game_entity.dart
│   └── use_cases/
│       ├── select_wolf_use_case.dart
│       ├── calculate_votes_use_case.dart
│       └── determine_winner_use_case.dart
├── presentation/
│   ├── providers/
│   │   ├── game_state_provider.dart
│   │   ├── settings_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   ├── player_setup/
│   │   │   ├── player_setup_screen.dart
│   │   │   └── widgets/
│   │   ├── theme_selection/
│   │   │   ├── theme_selection_screen.dart
│   │   │   └── widgets/
│   │   ├── theme_distribution/
│   │   │   ├── theme_distribution_screen.dart
│   │   │   └── widgets/
│   │   ├── gesture_time/
│   │   │   ├── gesture_time_screen.dart
│   │   │   └── widgets/
│   │   ├── discussion/
│   │   │   ├── discussion_screen.dart
│   │   │   └── widgets/
│   │   ├── voting/
│   │   │   ├── voting_screen.dart
│   │   │   └── widgets/
│   │   ├── result/
│   │   │   ├── result_screen.dart
│   │   │   └── widgets/
│   │   ├── settings/
│   │   │   ├── settings_screen.dart
│   │   │   └── widgets/
│   │   └── rules/
│   │       └── rules_screen.dart
│   └── widgets/
│       ├── common/
│       │   ├── app_button.dart
│       │   ├── app_card.dart
│       │   ├── countdown_timer.dart
│       │   └── player_avatar.dart
│       └── dialogs/
│           ├── confirmation_dialog.dart
│           └── info_dialog.dart
└── services/
    ├── timer_service.dart
    ├── audio_service.dart
    └── storage_service.dart
```

---

## 2. データモデル設計

### 2.1 コアモデル

#### 2.1.1 Player
```dart
/// プレイヤー情報を表すモデル
class Player {
  final String id;
  final String name;
  final String theme;
  final bool isWolf;
  int? votedForIndex;
  
  Player({
    required this.id,
    required this.name,
    required this.theme,
    required this.isWolf,
    this.votedForIndex,
  });
  
  Player copyWith({
    String? id,
    String? name,
    String? theme,
    bool? isWolf,
    int? votedForIndex,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      theme: theme ?? this.theme,
      isWolf: isWolf ?? this.isWolf,
      votedForIndex: votedForIndex ?? this.votedForIndex,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'theme': theme,
    'isWolf': isWolf,
    'votedForIndex': votedForIndex,
  };
  
  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    theme: json['theme'],
    isWolf: json['isWolf'],
    votedForIndex: json['votedForIndex'],
  );
}
```

#### 2.1.2 ThemePair
```dart
/// お題のペア（市民用とウルフ用）
class ThemePair {
  final String id;
  final String category;
  final String majorityTheme;
  final String minorityTheme;
  final bool isCustom;
  
  ThemePair({
    required this.id,
    required this.category,
    required this.majorityTheme,
    required this.minorityTheme,
    this.isCustom = false,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'majorityTheme': majorityTheme,
    'minorityTheme': minorityTheme,
    'isCustom': isCustom,
  };
  
  factory ThemePair.fromJson(Map<String, dynamic> json) => ThemePair(
    id: json['id'],
    category: json['category'],
    majorityTheme: json['majorityTheme'],
    minorityTheme: json['minorityTheme'],
    isCustom: json['isCustom'] ?? false,
  );
}
```

#### 2.1.3 GameState
```dart
/// ゲーム全体の状態を管理
enum GamePhase {
  home,
  playerSetup,
  themeSelection,
  themeDistribution,
  gestureTime,
  discussion,
  voting,
  result,
}

class GameState {
  final GamePhase currentPhase;
  final int playerCount;
  final List<Player> players;
  final ThemePair? selectedTheme;
  final int currentPlayerIndex;
  final int gestureRound;
  final Map<int, int> votes; // playerIndex -> votedForPlayerIndex
  final GameSettings settings;
  final int? distributionPlayerIndex; // お題配布中のプレイヤー
  final bool isThemeVisible; // お題が表示されているか
  
  GameState({
    this.currentPhase = GamePhase.home,
    this.playerCount = 4,
    this.players = const [],
    this.selectedTheme,
    this.currentPlayerIndex = 0,
    this.gestureRound = 1,
    this.votes = const {},
    required this.settings,
    this.distributionPlayerIndex,
    this.isThemeVisible = false,
  });
  
  GameState copyWith({
    GamePhase? currentPhase,
    int? playerCount,
    List<Player>? players,
    ThemePair? selectedTheme,
    int? currentPlayerIndex,
    int? gestureRound,
    Map<int, int>? votes,
    GameSettings? settings,
    int? distributionPlayerIndex,
    bool? isThemeVisible,
  }) {
    return GameState(
      currentPhase: currentPhase ?? this.currentPhase,
      playerCount: playerCount ?? this.playerCount,
      players: players ?? this.players,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      gestureRound: gestureRound ?? this.gestureRound,
      votes: votes ?? this.votes,
      settings: settings ?? this.settings,
      distributionPlayerIndex: distributionPlayerIndex ?? this.distributionPlayerIndex,
      isThemeVisible: isThemeVisible ?? this.isThemeVisible,
    );
  }
  
  // ヘルパーメソッド
  int get wolfCount {
    if (playerCount <= 4) return 1;
    if (playerCount <= 6) return 1;
    return 2; // 7-8人の場合、設定で変更可能
  }
  
  bool get allPlayersVoted => votes.length == playerCount;
  
  Player? get currentPlayer {
    if (currentPlayerIndex < players.length) {
      return players[currentPlayerIndex];
    }
    return null;
  }
}
```

#### 2.1.4 GameSettings
```dart
/// ゲーム設定
class GameSettings {
  final int gestureDuration; // 秒
  final int discussionDuration; // 秒
  final bool soundEnabled;
  final bool musicEnabled;
  final bool darkMode;
  final String language; // 'ja' or 'en'
  final int wolfCountFor7to8Players; // 7-8人の時のウルフ数
  
  GameSettings({
    this.gestureDuration = 15,
    this.discussionDuration = 180, // 3分
    this.soundEnabled = true,
    this.musicEnabled = false,
    this.darkMode = false,
    this.language = 'ja',
    this.wolfCountFor7to8Players = 2,
  });
  
  GameSettings copyWith({
    int? gestureDuration,
    int? discussionDuration,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? darkMode,
    String? language,
    int? wolfCountFor7to8Players,
  }) {
    return GameSettings(
      gestureDuration: gestureDuration ?? this.gestureDuration,
      discussionDuration: discussionDuration ?? this.discussionDuration,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      wolfCountFor7to8Players: wolfCountFor7to8Players ?? this.wolfCountFor7to8Players,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'gestureDuration': gestureDuration,
    'discussionDuration': discussionDuration,
    'soundEnabled': soundEnabled,
    'musicEnabled': musicEnabled,
    'darkMode': darkMode,
    'language': language,
    'wolfCountFor7to8Players': wolfCountFor7to8Players,
  };
  
  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
    gestureDuration: json['gestureDuration'] ?? 15,
    discussionDuration: json['discussionDuration'] ?? 180,
    soundEnabled: json['soundEnabled'] ?? true,
    musicEnabled: json['musicEnabled'] ?? false,
    darkMode: json['darkMode'] ?? false,
    language: json['language'] ?? 'ja',
    wolfCountFor7to8Players: json['wolfCountFor7to8Players'] ?? 2,
  );
}
```

#### 2.1.5 GameHistory
```dart
/// ゲームの履歴（オプション機能）
class GameHistory {
  final String id;
  final DateTime playedAt;
  final List<String> playerNames;
  final String category;
  final String majorityTheme;
  final String minorityTheme;
  final bool citizenWon;
  final List<int> wolfIndices;
  
  GameHistory({
    required this.id,
    required this.playedAt,
    required this.playerNames,
    required this.category,
    required this.majorityTheme,
    required this.minorityTheme,
    required this.citizenWon,
    required this.wolfIndices,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'playedAt': playedAt.toIso8601String(),
    'playerNames': playerNames,
    'category': category,
    'majorityTheme': majorityTheme,
    'minorityTheme': minorityTheme,
    'citizenWon': citizenWon,
    'wolfIndices': wolfIndices,
  };
  
  factory GameHistory.fromJson(Map<String, dynamic> json) => GameHistory(
    id: json['id'],
    playedAt: DateTime.parse(json['playedAt']),
    playerNames: List<String>.from(json['playerNames']),
    category: json['category'],
    majorityTheme: json['majorityTheme'],
    minorityTheme: json['minorityTheme'],
    citizenWon: json['citizenWon'],
    wolfIndices: List<int>.from(json['wolfIndices']),
  );
}
```

---

## 3. 状態管理設計

### 3.1 Riverpod Provider構成

```dart
// lib/presentation/providers/game_state_provider.dart

/// ゲーム設定のProvider
final gameSettingsProvider = StateNotifierProvider<GameSettingsNotifier, GameSettings>((ref) {
  return GameSettingsNotifier();
});

/// ゲーム状態のProvider
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  final settings = ref.watch(gameSettingsProvider);
  return GameStateNotifier(settings);
});

/// お題データのProvider
final themesProvider = Provider<List<ThemePair>>((ref) {
  return ref.watch(themeRepositoryProvider).getAllThemes();
});

/// カテゴリー別お題のProvider
final themesByCategoryProvider = Provider.family<List<ThemePair>, String>((ref, category) {
  return ref.watch(themeRepositoryProvider).getThemesByCategory(category);
});

/// カスタムお題のProvider
final customThemesProvider = StateNotifierProvider<CustomThemesNotifier, List<ThemePair>>((ref) {
  return CustomThemesNotifier(ref.watch(themeRepositoryProvider));
});

/// お気に入りお題のProvider（オプション）
final favoriteThemesProvider = StateNotifierProvider<FavoriteThemesNotifier, List<String>>((ref) {
  return FavoriteThemesNotifier(ref.watch(settingsRepositoryProvider));
});
```

### 3.2 GameStateNotifier

```dart
class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier(GameSettings settings) 
    : super(GameState(settings: settings));
  
  /// プレイヤー数を設定
  void setPlayerCount(int count) {
    if (count < 3 || count > 8) return;
    
    final players = List.generate(
      count,
      (index) => Player(
        id: 'player_$index',
        name: 'プレイヤー${index + 1}',
        theme: '',
        isWolf: false,
      ),
    );
    
    state = state.copyWith(
      playerCount: count,
      players: players,
    );
  }
  
  /// プレイヤー名を更新
  void updatePlayerName(int index, String name) {
    final updatedPlayers = [...state.players];
    updatedPlayers[index] = updatedPlayers[index].copyWith(name: name);
    state = state.copyWith(players: updatedPlayers);
  }
  
  /// お題を選択
  void selectTheme(ThemePair theme) {
    state = state.copyWith(selectedTheme: theme);
  }
  
  /// ゲーム開始（お題配布フェーズへ）
  void startGame() {
    _assignThemesAndWolves();
    state = state.copyWith(
      currentPhase: GamePhase.themeDistribution,
      distributionPlayerIndex: 0,
      isThemeVisible: false,
    );
  }
  
  /// お題とウルフを割り当て
  void _assignThemesAndWolves() {
    if (state.selectedTheme == null) return;
    
    final theme = state.selectedTheme!;
    final wolfCount = _calculateWolfCount();
    
    // ランダムにウルフを選出
    final playerIndices = List.generate(state.playerCount, (i) => i);
    playerIndices.shuffle();
    final wolfIndices = playerIndices.take(wolfCount).toList();
    
    // プレイヤーにお題を割り当て
    final updatedPlayers = state.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final isWolf = wolfIndices.contains(index);
      
      return player.copyWith(
        theme: isWolf ? theme.minorityTheme : theme.majorityTheme,
        isWolf: isWolf,
      );
    }).toList();
    
    state = state.copyWith(players: updatedPlayers);
  }
  
  int _calculateWolfCount() {
    if (state.playerCount <= 4) return 1;
    if (state.playerCount <= 6) return 1;
    return state.settings.wolfCountFor7to8Players;
  }
  
  /// お題を表示
  void showTheme() {
    state = state.copyWith(isThemeVisible: true);
  }
  
  /// お題確認完了、次のプレイヤーへ
  void confirmTheme() {
    final nextIndex = (state.distributionPlayerIndex ?? 0) + 1;
    
    if (nextIndex >= state.playerCount) {
      // 全員確認完了、ジェスチャータイムへ
      state = state.copyWith(
        currentPhase: GamePhase.gestureTime,
        currentPlayerIndex: 0,
        distributionPlayerIndex: null,
        isThemeVisible: false,
      );
    } else {
      // 次のプレイヤーへ
      state = state.copyWith(
        distributionPlayerIndex: nextIndex,
        isThemeVisible: false,
      );
    }
  }
  
  /// 次のプレイヤーへ（ジェスチャータイム）
  void nextPlayer() {
    final nextIndex = state.currentPlayerIndex + 1;
    
    if (nextIndex >= state.playerCount) {
      // 1周目完了
      if (state.gestureRound == 1) {
        // 2周目の選択画面を表示（実装は画面側で）
        state = state.copyWith(currentPlayerIndex: nextIndex);
      } else {
        // ディスカッションフェーズへ
        state = state.copyWith(
          currentPhase: GamePhase.discussion,
        );
      }
    } else {
      state = state.copyWith(currentPlayerIndex: nextIndex);
    }
  }
  
  /// 2周目を開始
  void startSecondRound() {
    state = state.copyWith(
      gestureRound: 2,
      currentPlayerIndex: 0,
    );
  }
  
  /// ディスカッションをスキップして投票へ
  void startVoting() {
    state = state.copyWith(
      currentPhase: GamePhase.voting,
      currentPlayerIndex: 0,
      votes: {},
    );
  }
  
  /// 投票を記録
  void vote(int voterIndex, int targetIndex) {
    final updatedVotes = {...state.votes};
    updatedVotes[voterIndex] = targetIndex;
    
    state = state.copyWith(votes: updatedVotes);
    
    // 全員投票完了したら結果フェーズへ
    if (state.allPlayersVoted) {
      state = state.copyWith(currentPhase: GamePhase.result);
    }
  }
  
  /// 投票結果を集計
  Map<int, int> getVoteResults() {
    final results = <int, int>{};
    
    for (final targetIndex in state.votes.values) {
      results[targetIndex] = (results[targetIndex] ?? 0) + 1;
    }
    
    return results;
  }
  
  /// 最多票のプレイヤーを取得
  List<int> getMostVotedPlayers() {
    final results = getVoteResults();
    if (results.isEmpty) return [];
    
    final maxVotes = results.values.reduce((a, b) => a > b ? a : b);
    return results.entries
        .where((entry) => entry.value == maxVotes)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// 市民が勝利したか判定
  bool didCitizensWin() {
    final mostVoted = getMostVotedPlayers();
    final wolves = state.players
        .asMap()
        .entries
        .where((entry) => entry.value.isWolf)
        .map((entry) => entry.key)
        .toList();
    
    // 最多票にウルフが含まれているか
    return mostVoted.any((index) => wolves.contains(index));
  }
  
  /// ゲームをリセット
  void resetGame() {
    state = GameState(settings: state.settings);
  }
  
  /// プレイヤー設定画面へ戻る
  void backToPlayerSetup() {
    state = state.copyWith(
      currentPhase: GamePhase.playerSetup,
      selectedTheme: null,
      currentPlayerIndex: 0,
      gestureRound: 1,
      votes: {},
    );
  }
}
```

---

## 4. ルーティング設計

### 4.1 GoRouter設定

```dart
// lib/core/router/app_router.dart

final routerProvider = Provider<GoRouter>((ref) {
  final gameState = ref.watch(gameStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/player-setup',
        name: 'playerSetup',
        builder: (context, state) => const PlayerSetupScreen(),
      ),
      GoRoute(
        path: '/theme-selection',
        name: 'themeSelection',
        builder: (context, state) => const ThemeSelectionScreen(),
      ),
      GoRoute(
        path: '/theme-distribution',
        name: 'themeDistribution',
        builder: (context, state) => const ThemeDistributionScreen(),
      ),
      GoRoute(
        path: '/gesture-time',
        name: 'gestureTime',
        builder: (context, state) => const GestureTimeScreen(),
      ),
      GoRoute(
        path: '/discussion',
        name: 'discussion',
        builder: (context, state) => const DiscussionScreen(),
      ),
      GoRoute(
        path: '/voting',
        name: 'voting',
        builder: (context, state) => const VotingScreen(),
      ),
      GoRoute(
        path: '/result',
        name: 'result',
        builder: (context, state) => const ResultScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/rules',
        name: 'rules',
        builder: (context, state) => const RulesScreen(),
      ),
    ],
  );
});
```

---

## 5. UI/UXデザイン

### 5.1 デザインシステム

#### 5.1.1 カラーパレット

```dart
// lib/core/constants/app_colors.dart

class AppColors {
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
```

#### 5.1.2 タイポグラフィ

```dart
// lib/core/constants/app_text_styles.dart

class AppTextStyles {
  // Display (見出し)
  static const displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );
  
  static const displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );
  
  // Headline
  static const headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  // Label (ボタンなど)
  static const labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  // Timer (タイマー表示用の大きなフォント)
  static const timerLarge = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.bold,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  static const timerMedium = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
```

#### 5.1.3 サイズ定義

```dart
// lib/core/constants/app_sizes.dart

class AppSizes {
  // Spacing
  static const spacingXS = 4.0;
  static const spacingS = 8.0;
  static const spacingM = 16.0;
  static const spacingL = 24.0;
  static const spacingXL = 32.0;
  static const spacingXXL = 48.0;
  
  // Border Radius
  static const radiusS = 8.0;
  static const radiusM = 12.0;
  static const radiusL = 16.0;
  static const radiusXL = 24.0;
  static const radiusRound = 999.0;
  
  // Button
  static const buttonHeightS = 40.0;
  static const buttonHeightM = 48.0;
  static const buttonHeightL = 56.0;
  static const buttonMinWidth = 120.0;
  
  // Icon
  static const iconS = 20.0;
  static const iconM = 24.0;
  static const iconL = 32.0;
  static const iconXL = 48.0;
  
  // Avatar
  static const avatarS = 32.0;
  static const avatarM = 48.0;
  static const avatarL = 64.0;
  static const avatarXL = 96.0;
  
  // Card
  static const cardElevation = 2.0;
  static const cardPadding = spacingM;
  
  // Screen Padding
  static const screenPadding = spacingL;
}
```

### 5.2 共通ウィジェット

#### 5.2.1 AppButton

```dart
// lib/presentation/widgets/common/app_button.dart

enum AppButtonType { primary, secondary, outlined, text }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  
  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final height = _getHeight();
    final padding = _getPadding();
    
    Widget button;
    
    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : AppSizes.buttonMinWidth, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          child: _buildChild(context),
        );
        break;
        
      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            minimumSize: Size(fullWidth ? double.infinity : AppSizes.buttonMinWidth, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          child: _buildChild(context),
        );
        break;
        
      case AppButtonType.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : AppSizes.buttonMinWidth, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          child: _buildChild(context),
        );
        break;
        
      case AppButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : AppSizes.buttonMinWidth, height),
            padding: padding,
          ),
          child: _buildChild(context),
        );
        break;
    }
    
    return button;
  }
  
  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: type == AppButtonType.primary || type == AppButtonType.secondary
              ? Colors.white
              : AppColors.primary,
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          SizedBox(width: AppSizes.spacingS),
          Text(text, style: _getTextStyle()),
        ],
      );
    }
    
    return Text(text, style: _getTextStyle());
  }
  
  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.buttonHeightS;
      case AppButtonSize.medium:
        return AppSizes.buttonHeightM;
      case AppButtonSize.large:
        return AppSizes.buttonHeightL;
    }
  }
  
  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(horizontal: AppSizes.spacingM);
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: AppSizes.spacingL);
      case AppButtonSize.large:
        return EdgeInsets.symmetric(horizontal: AppSizes.spacingXL);
    }
  }
  
  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.iconS;
      case AppButtonSize.medium:
        return AppSizes.iconM;
      case AppButtonSize.large:
        return AppSizes.iconL;
    }
  }
  
  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTextStyles.labelMedium;
      case AppButtonSize.medium:
      case AppButtonSize.large:
        return AppTextStyles.labelLarge;
    }
  }
}
```

#### 5.2.2 CountdownTimer

```dart
// lib/presentation/widgets/common/countdown_timer.dart

class CountdownTimer extends ConsumerStatefulWidget {
  final int durationInSeconds;
  final VoidCallback? onComplete;
  final bool autoStart;
  final int? warningThreshold; // 残り秒数の警告閾値
  
  const CountdownTimer({
    Key? key,
    required this.durationInSeconds,
    this.onComplete,
    this.autoStart = true,
    this.warningThreshold = 5,
  }) : super(key: key);
  
  @override
  ConsumerState<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends ConsumerState<CountdownTimer> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  
  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationInSeconds;
    if (widget.autoStart) {
      start();
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        
        // 警告音再生（オプション）
        if (widget.warningThreshold != null && 
            _remainingSeconds == widget.warningThreshold) {
          ref.read(audioServiceProvider).playWarning();
        }
      } else {
        timer.cancel();
        _isRunning = false;
        widget.onComplete?.call();
        ref.read(audioServiceProvider).playComplete();
      }
    });
  }
  
  void pause() {
    _timer?.cancel();
    _isRunning = false;
  }
  
  void reset() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.durationInSeconds;
      _isRunning = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isWarning = widget.warningThreshold != null && 
                      _remainingSeconds <= widget.warningThreshold!;
    
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(AppSizes.spacingL),
      decoration: BoxDecoration(
        color: isWarning 
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: isWarning ? AppColors.warning : AppColors.primary,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            timeString,
            style: AppTextStyles.timerLarge.copyWith(
              color: isWarning ? AppColors.warning : AppColors.primary,
            ),
          ),
          if (_isRunning)
            Padding(
              padding: EdgeInsets.only(top: AppSizes.spacingS),
              child: LinearProgressIndicator(
                value: _remainingSeconds / widget.durationInSeconds,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  isWarning ? AppColors.warning : AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## 6. サービス設計

### 6.1 AudioService

```dart
// lib/services/audio_service.dart

class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  bool _soundEnabled = true;
  bool _musicEnabled = false;
  
  Future<void> initialize() async {
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }
  
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }
  
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _bgmPlayer.stop();
    }
  }
  
  Future<void> playTap() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('sounds/tap.mp3'));
  }
  
  Future<void> playWarning() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('sounds/warning.mp3'));
  }
  
  Future<void> playComplete() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('sounds/complete.mp3'));
  }
  
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('sounds/success.mp3'));
  }
  
  Future<void> playBGM() async {
    if (!_musicEnabled) return;
    await _bgmPlayer.play(AssetSource('sounds/bgm.mp3'));
  }
  
  void dispose() {
    _sfxPlayer.dispose();
    _bgmPlayer.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  service.initialize();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});
```

### 6.2 StorageService

```dart
// lib/services/storage_service.dart

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
    return list.map((item) => ThemePair.fromJson(item)).toList();
  }
  
  // Favorite Themes
  Future<void> saveFavoriteThemeIds(List<String> ids) async {
    await _prefs.setStringList('favorite_themes', ids);
  }
  
  List<String> loadFavoriteThemeIds() {
    return _prefs.getStringList('favorite_themes') ?? [];
  }
  
  // Game History
  Future<void> saveGameHistory(List<GameHistory> history) async {
    final json = jsonEncode(history.map((h) => h.toJson()).toList());
    await _prefs.setString('game_history', json);
  }
  
  List<GameHistory> loadGameHistory() {
    final json = _prefs.getString('game_history');
    if (json == null) return [];
    
    final list = jsonDecode(json) as List;
    return list.map((item) => GameHistory.fromJson(item)).toList();
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});
```

---

## 7. お題データ設計

### 7.1 お題データ構造

```dart
// lib/data/data_sources/themes/default_themes.dart

final List<ThemePair> defaultThemes = [
  // 動物カテゴリー
  ThemePair(
    id: 'animal_001',
    category: '動物',
    majorityTheme: '犬',
    minorityTheme: '猫',
  ),
  ThemePair(
    id: 'animal_002',
    category: '動物',
    majorityTheme: 'ライオン',
    minorityTheme: 'トラ',
  ),
  ThemePair(
    id: 'animal_003',
    category: '動物',
    majorityTheme: 'ペンギン',
    minorityTheme: 'アザラシ',
  ),
  ThemePair(
    id: 'animal_004',
    category: '動物',
    majorityTheme: 'ゾウ',
    minorityTheme: 'サイ',
  ),
  ThemePair(
    id: 'animal_005',
    category: '動物',
    majorityTheme: 'ウサギ',
    minorityTheme: 'ネズミ',
  ),
  
  // スポーツカテゴリー
  ThemePair(
    id: 'sport_001',
    category: 'スポーツ',
    majorityTheme: '野球',
    minorityTheme: 'テニス',
  ),
  ThemePair(
    id: 'sport_002',
    category: 'スポーツ',
    majorityTheme: 'サッカー',
    minorityTheme: 'バスケ',
  ),
  ThemePair(
    id: 'sport_003',
    category: 'スポーツ',
    majorityTheme: 'スキー',
    minorityTheme: 'スノボ',
  ),
  ThemePair(
    id: 'sport_004',
    category: 'スポーツ',
    majorityTheme: 'ゴルフ',
    minorityTheme: 'ボウリング',
  ),
  ThemePair(
    id: 'sport_005',
    category: 'スポーツ',
    majorityTheme: '水泳',
    minorityTheme: 'ダイビング',
  ),
  
  // 職業カテゴリー
  ThemePair(
    id: 'job_001',
    category: '職業',
    majorityTheme: '料理人',
    minorityTheme: 'パティシエ',
  ),
  ThemePair(
    id: 'job_002',
    category: '職業',
    majorityTheme: '医者',
    minorityTheme: '看護師',
  ),
  ThemePair(
    id: 'job_003',
    category: '職業',
    majorityTheme: '教師',
    minorityTheme: '保育士',
  ),
  ThemePair(
    id: 'job_004',
    category: '職業',
    majorityTheme: '警察官',
    minorityTheme: '消防士',
  ),
  ThemePair(
    id: 'job_005',
    category: '職業',
    majorityTheme: '歌手',
    minorityTheme: 'ダンサー',
  ),
  
  // 動作カテゴリー
  ThemePair(
    id: 'action_001',
    category: '動作',
    majorityTheme: '泳ぐ',
    minorityTheme: '溺れる',
  ),
  ThemePair(
    id: 'action_002',
    category: '動作',
    majorityTheme: '走る',
    minorityTheme: '逃げる',
  ),
  ThemePair(
    id: 'action_003',
    category: '動作',
    majorityTheme: '食べる',
    minorityTheme: '飲む',
  ),
  ThemePair(
    id: 'action_004',
    category: '動作',
    majorityTheme: '笑う',
    minorityTheme: '泣く',
  ),
  ThemePair(
    id: 'action_005',
    category: '動作',
    majorityTheme: '投げる',
    minorityTheme: '蹴る',
  ),
  
  // その他カテゴリー
  ThemePair(
    id: 'other_001',
    category: 'その他',
    majorityTheme: 'ラーメン',
    minorityTheme: 'うどん',
  ),
  ThemePair(
    id: 'other_002',
    category: 'その他',
    majorityTheme: 'コーヒー',
    minorityTheme: '紅茶',
  ),
  ThemePair(
    id: 'other_003',
    category: 'その他',
    majorityTheme: '夏',
    minorityTheme: '冬',
  ),
  ThemePair(
    id: 'other_004',
    category: 'その他',
    majorityTheme: '山',
    minorityTheme: '海',
  ),
  ThemePair(
    id: 'other_005',
    category: 'その他',
    majorityTheme: '映画',
    minorityTheme: 'ドラマ',
  ),
];
```

---

## 8. テスト設計

### 8.1 単体テスト

```dart
// test/domain/use_cases/select_wolf_use_case_test.dart

void main() {
  group('SelectWolfUseCase', () {
    late SelectWolfUseCase useCase;
    
    setUp(() {
      useCase = SelectWolfUseCase();
    });
    
    test('3-4人の場合、ウルフは1人', () {
      final result = useCase.execute(playerCount: 4);
      expect(result.length, 1);
    });
    
    test('7-8人の場合、ウルフは1-2人', () {
      final result = useCase.execute(playerCount: 7, wolfCount: 2);
      expect(result.length, 2);
    });
    
    test('ウルフの選出がランダムである', () {
      final results = List.generate(10, (_) => useCase.execute(playerCount: 4));
      final allSame = results.every((r) => r.first == results.first.first);
      expect(allSame, false);
    });
  });
}
```

### 8.2 ウィジェットテスト

```dart
// test/presentation/widgets/countdown_timer_test.dart

void main() {
  testWidgets('CountdownTimer displays correct time', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CountdownTimer(
              durationInSeconds: 60,
              autoStart: false,
            ),
          ),
        ),
      ),
    );
    
    expect(find.text('01:00'), findsOneWidget);
  });
}
```

---

## 9. パフォーマンス最適化

### 9.1 最適化ポイント

1. **状態管理の最適化**
   - 必要な部分のみ再ビルド
   - `select`や`family`の活用

2. **画像アセットの最適化**
   - 適切なサイズの画像を使用
   - WebPフォーマットの利用

3. **レイアウトの最適化**
   - `const` コンストラクタの使用
   - 不要な再ビルドを避ける

4. **メモリ管理**
   - リソースの適切な解放
   - 大きなリストは`ListView.builder`を使用

---

## 10. セキュリティ考慮事項

### 10.1 データ保護

1. **ローカルストレージ**
   - 個人を特定できる情報は保存しない
   - ゲーム設定とカスタムお題のみ保存

2. **権限**
   - 不要な権限は要求しない
   - ストレージアクセスは最小限

---

## 変更履歴

| 日付 | バージョン | 変更内容 | 担当者 |
|------|-----------|---------|-------|
| 2025-12-06 | 1.0.0 | 初版作成 | - |
