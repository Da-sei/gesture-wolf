import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/game_state.dart';
import '../../data/models/player.dart';
import '../../data/models/theme_pair.dart';
import '../../domain/use_cases/select_wolf_use_case.dart';
import '../../domain/use_cases/calculate_votes_use_case.dart';
import '../../domain/use_cases/determine_winner_use_case.dart';
import 'game_settings_provider.dart';

/// ゲーム状態のProvider
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  final settings = ref.watch(gameSettingsProvider);
  return GameStateNotifier(settings);
});

/// ゲーム状態の管理
class GameStateNotifier extends StateNotifier<GameState> {
  final _selectWolfUseCase = SelectWolfUseCase();
  final _calculateVotesUseCase = CalculateVotesUseCase();
  final _determineWinnerUseCase = DetermineWinnerUseCase();

  GameStateNotifier(settings) : super(GameState(settings: settings));

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
    if (index < 0 || index >= state.players.length) return;

    final updatedPlayers = List<Player>.from(state.players);
    updatedPlayers[index] = updatedPlayers[index].copyWith(name: name);
    state = state.copyWith(players: updatedPlayers);
  }

  /// お題を選択
  void selectTheme(ThemePair theme) {
    state = state.copyWith(selectedTheme: theme);
  }

  /// ゲーム開始（お題配布フェーズへ）
  void startGame() {
    if (state.selectedTheme == null) return;

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
    final wolfCount = state.wolfCount;

    // ランダムにウルフを選出
    final wolfIndices = _selectWolfUseCase.execute(
      playerCount: state.playerCount,
      wolfCount: wolfCount,
    );

    // プレイヤーにお題を割り当て
    final updatedPlayers = <Player>[];
    for (var i = 0; i < state.players.length; i++) {
      final player = state.players[i];
      final isWolf = wolfIndices.contains(i);

      updatedPlayers.add(
        player.copyWith(
          theme: isWolf ? theme.minorityTheme : theme.majorityTheme,
          isWolf: isWolf,
        ),
      );
    }

    state = state.copyWith(players: updatedPlayers);
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
    state = state.copyWith(currentPlayerIndex: nextIndex);
  }

  /// 2周目を開始
  void startSecondRound() {
    state = state.copyWith(
      gestureRound: state.gestureRound + 1,
      currentGesturingPlayerIndex: 0,
    );
  }

  /// ジェスチャー中の次のプレイヤーへ
  void nextGesturingPlayer() {
    final nextIndex = state.currentGesturingPlayerIndex + 1;
    if (nextIndex < state.players.length) {
      state = state.copyWith(currentGesturingPlayerIndex: nextIndex);
    }
  }

  /// ジェスチャータイムを開始
  void startGestureTime() {
    state = state.copyWith(
      currentPhase: GamePhase.gestureTime,
      currentGesturingPlayerIndex: 0,
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
    if (voterIndex < 0 || voterIndex >= state.playerCount) return;
    if (targetIndex < 0 || targetIndex >= state.playerCount) return;

    final updatedVotes = Map<int, int>.from(state.votes);
    updatedVotes[voterIndex] = targetIndex;

    state = state.copyWith(votes: updatedVotes);

    // 全員投票完了したら結果フェーズへ
    if (state.allPlayersVoted) {
      state = state.copyWith(currentPhase: GamePhase.result);
    }
  }

  /// 投票結果を集計
  Map<int, int> getVoteResults() {
    return _calculateVotesUseCase.execute(state.votes);
  }

  /// 最多票のプレイヤーを取得
  List<int> getMostVotedPlayers() {
    final results = getVoteResults();
    return _calculateVotesUseCase.getMostVoted(results);
  }

  /// 市民が勝利したか判定
  bool didCitizensWin() {
    final mostVoted = getMostVotedPlayers();
    final wolves = <int>[];
    for (var i = 0; i < state.players.length; i++) {
      if (state.players[i].isWolf) {
        wolves.add(i);
      }
    }

    return _determineWinnerUseCase.execute(
      mostVotedIndices: mostVoted,
      wolfIndices: wolves,
    );
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

  /// フェーズを変更
  void setPhase(GamePhase phase) {
    state = state.copyWith(currentPhase: phase);
  }
}
