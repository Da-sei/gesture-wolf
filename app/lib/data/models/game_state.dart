import 'player.dart';
import 'theme_pair.dart';
import 'game_settings.dart';

/// ゲームフェーズ
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

/// ゲーム全体の状態を管理
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
  final int currentGesturingPlayerIndex; // ジェスチャー中のプレイヤー

  const GameState({
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
    this.currentGesturingPlayerIndex = 0,
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
    int? currentGesturingPlayerIndex,
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
      distributionPlayerIndex:
          distributionPlayerIndex ?? this.distributionPlayerIndex,
      isThemeVisible: isThemeVisible ?? this.isThemeVisible,
      currentGesturingPlayerIndex:
          currentGesturingPlayerIndex ?? this.currentGesturingPlayerIndex,
    );
  }

  // ヘルパーメソッド
  int get wolfCount {
    if (playerCount <= 4) return 1;
    if (playerCount <= 6) return 1;
    return settings.wolfCountFor7to8Players; // 7-8人の場合
  }

  bool get allPlayersVoted => votes.length == playerCount;

  Player? get currentPlayer {
    if (currentPlayerIndex < players.length) {
      return players[currentPlayerIndex];
    }
    return null;
  }

  List<Player> get wolves => players.where((p) => p.isWolf).toList();

  List<Player> get citizens => players.where((p) => !p.isWolf).toList();
}
