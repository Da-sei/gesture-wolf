# ジェスチャーウルフ - API仕様書

## 1. 概要

本ドキュメントでは、ジェスチャーウルフアプリの内部API（状態管理、サービス、リポジトリ）の仕様を定義します。
このアプリはオフライン動作のため、外部APIは使用しません。

---

## 2. 状態管理API (Riverpod Providers)

### 2.1 GameStateProvider

**目的**: ゲーム全体の状態を管理

#### 2.1.1 Provider定義
```dart
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  final settings = ref.watch(gameSettingsProvider);
  return GameStateNotifier(settings);
});
```

#### 2.1.2 公開メソッド

##### setPlayerCount
プレイヤー数を設定し、プレイヤーリストを初期化

**シグネチャ**:
```dart
void setPlayerCount(int count)
```

**パラメータ**:
- `count` (int): プレイヤー数 (3-8)

**副作用**:
- `GameState.playerCount`を更新
- `GameState.players`を初期化（デフォルト名で）

**例外**:
- なし（範囲外の値は無視）

**使用例**:
```dart
ref.read(gameStateProvider.notifier).setPlayerCount(4);
```

---

##### updatePlayerName
特定のプレイヤーの名前を更新

**シグネチャ**:
```dart
void updatePlayerName(int index, String name)
```

**パラメータ**:
- `index` (int): プレイヤーのインデックス (0始まり)
- `name` (String): 新しい名前

**副作用**:
- `GameState.players[index].name`を更新

**使用例**:
```dart
ref.read(gameStateProvider.notifier).updatePlayerName(0, '太郎');
```

---

##### selectTheme
ゲームのお題を選択

**シグネチャ**:
```dart
void selectTheme(ThemePair theme)
```

**パラメータ**:
- `theme` (ThemePair): 選択されたお題ペア

**副作用**:
- `GameState.selectedTheme`を更新

**使用例**:
```dart
final theme = ThemePair(
  id: 'animal_001',
  category: '動物',
  majorityTheme: '犬',
  minorityTheme: '猫',
);
ref.read(gameStateProvider.notifier).selectTheme(theme);
```

---

##### startGame
ゲームを開始（お題配布フェーズへ遷移）

**シグネチャ**:
```dart
void startGame()
```

**パラメータ**: なし

**副作用**:
- ウルフをランダムに選出
- 各プレイヤーにお題を割り当て
- `GameState.currentPhase`を`themeDistribution`に変更
- `GameState.distributionPlayerIndex`を0に設定

**前提条件**:
- `selectedTheme`が設定済み
- `players`が設定済み

**使用例**:
```dart
ref.read(gameStateProvider.notifier).startGame();
```

---

##### showTheme
現在のプレイヤーにお題を表示

**シグネチャ**:
```dart
void showTheme()
```

**パラメータ**: なし

**副作用**:
- `GameState.isThemeVisible`をtrueに設定

**使用例**:
```dart
ref.read(gameStateProvider.notifier).showTheme();
```

---

##### confirmTheme
お題確認完了、次のプレイヤーまたは次のフェーズへ

**シグネチャ**:
```dart
void confirmTheme()
```

**パラメータ**: なし

**副作用**:
- `distributionPlayerIndex`をインクリメント
- 全員確認済みの場合、`currentPhase`を`gestureTime`に変更
- `isThemeVisible`をfalseに設定

**使用例**:
```dart
ref.read(gameStateProvider.notifier).confirmTheme();
```

---

##### nextPlayer
ジェスチャータイムで次のプレイヤーへ

**シグネチャ**:
```dart
void nextPlayer()
```

**パラメータ**: なし

**副作用**:
- `currentPlayerIndex`をインクリメント
- 全員終了の場合、処理は画面側で分岐

**使用例**:
```dart
ref.read(gameStateProvider.notifier).nextPlayer();
```

---

##### startSecondRound
ジェスチャーの2周目を開始

**シグネチャ**:
```dart
void startSecondRound()
```

**パラメータ**: なし

**副作用**:
- `gestureRound`を2に設定
- `currentPlayerIndex`を0にリセット

**使用例**:
```dart
ref.read(gameStateProvider.notifier).startSecondRound();
```

---

##### startVoting
投票フェーズを開始

**シグネチャ**:
```dart
void startVoting()
```

**パラメータ**: なし

**副作用**:
- `currentPhase`を`voting`に変更
- `currentPlayerIndex`を0にリセット
- `votes`を空のMapで初期化

**使用例**:
```dart
ref.read(gameStateProvider.notifier).startVoting();
```

---

##### vote
プレイヤーの投票を記録

**シグネチャ**:
```dart
void vote(int voterIndex, int targetIndex)
```

**パラメータ**:
- `voterIndex` (int): 投票するプレイヤーのインデックス
- `targetIndex` (int): 投票対象のプレイヤーのインデックス

**副作用**:
- `votes[voterIndex]`に`targetIndex`を設定
- 全員投票完了の場合、`currentPhase`を`result`に変更

**使用例**:
```dart
ref.read(gameStateProvider.notifier).vote(0, 2);
```

---

##### getVoteResults
投票結果を集計

**シグネチャ**:
```dart
Map<int, int> getVoteResults()
```

**パラメータ**: なし

**戻り値**:
- `Map<int, int>`: プレイヤーインデックス → 得票数

**使用例**:
```dart
final results = ref.read(gameStateProvider.notifier).getVoteResults();
// 例: {0: 1, 2: 3} → プレイヤー0が1票、プレイヤー2が3票
```

---

##### getMostVotedPlayers
最多票のプレイヤーを取得

**シグネチャ**:
```dart
List<int> getMostVotedPlayers()
```

**パラメータ**: なし

**戻り値**:
- `List<int>`: 最多票のプレイヤーインデックスのリスト（同票の場合複数）

**使用例**:
```dart
final mostVoted = ref.read(gameStateProvider.notifier).getMostVotedPlayers();
// 例: [2] または [1, 3]（同票の場合）
```

---

##### didCitizensWin
市民が勝利したか判定

**シグネチャ**:
```dart
bool didCitizensWin()
```

**パラメータ**: なし

**戻り値**:
- `bool`: 市民が勝利した場合true、ウルフが勝利した場合false

**ロジック**:
- 最多票のプレイヤーにウルフが含まれている → 市民勝利
- 最多票のプレイヤーが全て市民 → ウルフ勝利

**使用例**:
```dart
final citizensWon = ref.read(gameStateProvider.notifier).didCitizensWin();
```

---

##### resetGame
ゲームを初期状態にリセット

**シグネチャ**:
```dart
void resetGame()
```

**パラメータ**: なし

**副作用**:
- `GameState`を初期状態に戻す（設定は保持）

**使用例**:
```dart
ref.read(gameStateProvider.notifier).resetGame();
```

---

##### backToPlayerSetup
プレイヤー設定画面に戻る（設定を保持）

**シグネチャ**:
```dart
void backToPlayerSetup()
```

**パラメータ**: なし

**副作用**:
- `currentPhase`を`playerSetup`に変更
- ゲーム進行状態をリセット（プレイヤー情報は保持）

**使用例**:
```dart
ref.read(gameStateProvider.notifier).backToPlayerSetup();
```

---

### 2.2 GameSettingsProvider

**目的**: ゲーム設定を管理

#### 2.2.1 Provider定義
```dart
final gameSettingsProvider = StateNotifierProvider<GameSettingsNotifier, GameSettings>((ref) {
  return GameSettingsNotifier(ref.watch(storageServiceProvider));
});
```

#### 2.2.2 公開メソッド

##### updateGestureDuration
ジェスチャー時間を更新

**シグネチャ**:
```dart
void updateGestureDuration(int seconds)
```

**パラメータ**:
- `seconds` (int): ジェスチャー時間（10-30秒）

**副作用**:
- `GameSettings.gestureDuration`を更新
- 設定をローカルストレージに保存

**使用例**:
```dart
ref.read(gameSettingsProvider.notifier).updateGestureDuration(20);
```

---

##### updateDiscussionDuration
ディスカッション時間を更新

**シグネチャ**:
```dart
void updateDiscussionDuration(int seconds)
```

**パラメータ**:
- `seconds` (int): ディスカッション時間（60-300秒）

**使用例**:
```dart
ref.read(gameSettingsProvider.notifier).updateDiscussionDuration(180);
```

---

##### toggleSound
効果音のON/OFFを切り替え

**シグネチャ**:
```dart
void toggleSound(bool enabled)
```

**パラメータ**:
- `enabled` (bool): 効果音を有効にするか

**副作用**:
- `GameSettings.soundEnabled`を更新
- `AudioService.setSoundEnabled()`を呼び出し

**使用例**:
```dart
ref.read(gameSettingsProvider.notifier).toggleSound(true);
```

---

##### toggleMusic
BGMのON/OFFを切り替え

**シグネチャ**:
```dart
void toggleMusic(bool enabled)
```

**パラメータ**:
- `enabled` (bool): BGMを有効にするか

**副作用**:
- `GameSettings.musicEnabled`を更新
- `AudioService.setMusicEnabled()`を呼び出し

**使用例**:
```dart
ref.read(gameSettingsProvider.notifier).toggleMusic(false);
```

---

##### toggleDarkMode
ダークモードのON/OFFを切り替え

**シグネチャ**:
```dart
void toggleDarkMode(bool enabled)
```

**パラメータ**:
- `enabled` (bool): ダークモードを有効にするか

**使用例**:
```dart
ref.read(gameSettingsProvider.notifier).toggleDarkMode(true);
```

---

##### setLanguage
言語を設定

**シグネチャ**:
```dart
void setLanguage(String language)
```

**パラメータ**:
- `language` (String): 言語コード ('ja' または 'en')

**使用例**:
```dart
ref.read(gameSettingsProvider.notifier).setLanguage('ja');
```

---

##### setWolfCountFor7to8Players
7-8人の時のウルフ数を設定

**シグネチャ**:
```dart
void setWolfCountFor7to8Players(int count)
```

**パラメータ**:
- `count` (int): ウルフ数（1または2）

**使用例**:
```dart
ref.read(gameSettingsProvider.notifier).setWolfCountFor7to8Players(2);
```

---

### 2.3 ThemeProvider

**目的**: お題データを提供

#### 2.3.1 Provider定義

##### themesProvider
全お題を取得

```dart
final themesProvider = Provider<List<ThemePair>>((ref) {
  return ref.watch(themeRepositoryProvider).getAllThemes();
});
```

**使用例**:
```dart
final themes = ref.watch(themesProvider);
```

---

##### themesByCategoryProvider
カテゴリー別お題を取得

```dart
final themesByCategoryProvider = Provider.family<List<ThemePair>, String>((ref, category) {
  return ref.watch(themeRepositoryProvider).getThemesByCategory(category);
});
```

**パラメータ**:
- `category` (String): カテゴリー名

**使用例**:
```dart
final animalThemes = ref.watch(themesByCategoryProvider('動物'));
```

---

##### categoriesProvider
全カテゴリーを取得

```dart
final categoriesProvider = Provider<List<String>>((ref) {
  return ref.watch(themeRepositoryProvider).getCategories();
});
```

**使用例**:
```dart
final categories = ref.watch(categoriesProvider);
```

---

### 2.4 CustomThemesProvider

**目的**: カスタムお題を管理

#### 2.4.1 Provider定義
```dart
final customThemesProvider = StateNotifierProvider<CustomThemesNotifier, List<ThemePair>>((ref) {
  return CustomThemesNotifier(ref.watch(themeRepositoryProvider));
});
```

#### 2.4.2 公開メソッド

##### addCustomTheme
カスタムお題を追加

**シグネチャ**:
```dart
Future<void> addCustomTheme(ThemePair theme)
```

**パラメータ**:
- `theme` (ThemePair): 追加するお題

**副作用**:
- カスタムお題リストに追加
- ローカルストレージに保存

**使用例**:
```dart
await ref.read(customThemesProvider.notifier).addCustomTheme(
  ThemePair(
    id: 'custom_001',
    category: 'カスタム',
    majorityTheme: 'カレー',
    minorityTheme: 'シチュー',
    isCustom: true,
  ),
);
```

---

##### removeCustomTheme
カスタムお題を削除

**シグネチャ**:
```dart
Future<void> removeCustomTheme(String themeId)
```

**パラメータ**:
- `themeId` (String): 削除するお題のID

**使用例**:
```dart
await ref.read(customThemesProvider.notifier).removeCustomTheme('custom_001');
```

---

### 2.5 FavoriteThemesProvider (オプション)

**目的**: お気に入りお題を管理

#### 2.5.1 Provider定義
```dart
final favoriteThemesProvider = StateNotifierProvider<FavoriteThemesNotifier, List<String>>((ref) {
  return FavoriteThemesNotifier(ref.watch(settingsRepositoryProvider));
});
```

#### 2.5.2 公開メソッド

##### toggleFavorite
お気に入りの追加/削除を切り替え

**シグネチャ**:
```dart
Future<void> toggleFavorite(String themeId)
```

**パラメータ**:
- `themeId` (String): お題のID

**使用例**:
```dart
await ref.read(favoriteThemesProvider.notifier).toggleFavorite('animal_001');
```

---

##### isFavorite
お題がお気に入りかチェック

**シグネチャ**:
```dart
bool isFavorite(String themeId)
```

**パラメータ**:
- `themeId` (String): お題のID

**戻り値**:
- `bool`: お気に入りならtrue

**使用例**:
```dart
final isFav = ref.read(favoriteThemesProvider.notifier).isFavorite('animal_001');
```

---

## 3. サービスAPI

### 3.1 AudioService

**目的**: 音声再生を管理

#### 3.1.1 メソッド

##### initialize
サービスを初期化

**シグネチャ**:
```dart
Future<void> initialize()
```

**使用例**:
```dart
await audioService.initialize();
```

---

##### playTap
タップ音を再生

**シグネチャ**:
```dart
Future<void> playTap()
```

**前提条件**:
- `soundEnabled`がtrue

**使用例**:
```dart
await ref.read(audioServiceProvider).playTap();
```

---

##### playWarning
警告音を再生（タイマー残り少ない時）

**シグネチャ**:
```dart
Future<void> playWarning()
```

**使用例**:
```dart
await ref.read(audioServiceProvider).playWarning();
```

---

##### playComplete
完了音を再生（タイマー終了時）

**シグネチャ**:
```dart
Future<void> playComplete()
```

**使用例**:
```dart
await ref.read(audioServiceProvider).playComplete();
```

---

##### playSuccess
成功音を再生（勝利時など）

**シグネチャ**:
```dart
Future<void> playSuccess()
```

**使用例**:
```dart
await ref.read(audioServiceProvider).playSuccess();
```

---

##### playBGM
BGMを再生

**シグネチャ**:
```dart
Future<void> playBGM()
```

**前提条件**:
- `musicEnabled`がtrue

**使用例**:
```dart
await ref.read(audioServiceProvider).playBGM();
```

---

##### stopBGM
BGMを停止

**シグネチャ**:
```dart
Future<void> stopBGM()
```

**使用例**:
```dart
await ref.read(audioServiceProvider).stopBGM();
```

---

##### setSoundEnabled
効果音の有効/無効を設定

**シグネチャ**:
```dart
void setSoundEnabled(bool enabled)
```

**パラメータ**:
- `enabled` (bool): 効果音を有効にするか

**使用例**:
```dart
ref.read(audioServiceProvider).setSoundEnabled(true);
```

---

##### setMusicEnabled
BGMの有効/無効を設定

**シグネチャ**:
```dart
void setMusicEnabled(bool enabled)
```

**パラメータ**:
- `enabled` (bool): BGMを有効にするか

**副作用**:
- falseの場合、BGMを停止

**使用例**:
```dart
ref.read(audioServiceProvider).setMusicEnabled(false);
```

---

### 3.2 StorageService

**目的**: ローカルストレージを管理

#### 3.2.1 メソッド

##### saveSettings
設定を保存

**シグネチャ**:
```dart
Future<void> saveSettings(GameSettings settings)
```

**パラメータ**:
- `settings` (GameSettings): 保存する設定

**使用例**:
```dart
await ref.read(storageServiceProvider).saveSettings(settings);
```

---

##### loadSettings
設定を読み込み

**シグネチャ**:
```dart
GameSettings? loadSettings()
```

**戻り値**:
- `GameSettings?`: 保存された設定（存在しない場合null）

**使用例**:
```dart
final settings = ref.read(storageServiceProvider).loadSettings();
```

---

##### saveCustomThemes
カスタムお題を保存

**シグネチャ**:
```dart
Future<void> saveCustomThemes(List<ThemePair> themes)
```

**パラメータ**:
- `themes` (List<ThemePair>): 保存するカスタムお題リスト

**使用例**:
```dart
await ref.read(storageServiceProvider).saveCustomThemes(customThemes);
```

---

##### loadCustomThemes
カスタムお題を読み込み

**シグネチャ**:
```dart
List<ThemePair> loadCustomThemes()
```

**戻り値**:
- `List<ThemePair>`: 保存されたカスタムお題（存在しない場合空リスト）

**使用例**:
```dart
final customThemes = ref.read(storageServiceProvider).loadCustomThemes();
```

---

##### saveFavoriteThemeIds
お気に入りお題IDを保存

**シグネチャ**:
```dart
Future<void> saveFavoriteThemeIds(List<String> ids)
```

**パラメータ**:
- `ids` (List<String>): お気に入りお題のIDリスト

**使用例**:
```dart
await ref.read(storageServiceProvider).saveFavoriteThemeIds(['animal_001', 'sport_002']);
```

---

##### loadFavoriteThemeIds
お気に入りお題IDを読み込み

**シグネチャ**:
```dart
List<String> loadFavoriteThemeIds()
```

**戻り値**:
- `List<String>`: お気に入りお題のIDリスト

**使用例**:
```dart
final favoriteIds = ref.read(storageServiceProvider).loadFavoriteThemeIds();
```

---

##### saveGameHistory
ゲーム履歴を保存

**シグネチャ**:
```dart
Future<void> saveGameHistory(List<GameHistory> history)
```

**パラメータ**:
- `history` (List<GameHistory>): ゲーム履歴リスト

**使用例**:
```dart
await ref.read(storageServiceProvider).saveGameHistory(history);
```

---

##### loadGameHistory
ゲーム履歴を読み込み

**シグネチャ**:
```dart
List<GameHistory> loadGameHistory()
```

**戻り値**:
- `List<GameHistory>`: ゲーム履歴リスト

**使用例**:
```dart
final history = ref.read(storageServiceProvider).loadGameHistory();
```

---

## 4. リポジトリAPI

### 4.1 ThemeRepository

**目的**: お題データへのアクセスを提供

#### 4.1.1 メソッド

##### getAllThemes
全お題を取得

**シグネチャ**:
```dart
List<ThemePair> getAllThemes()
```

**戻り値**:
- `List<ThemePair>`: デフォルト + カスタムお題の全リスト

**使用例**:
```dart
final allThemes = themeRepository.getAllThemes();
```

---

##### getThemesByCategory
カテゴリー別お題を取得

**シグネチャ**:
```dart
List<ThemePair> getThemesByCategory(String category)
```

**パラメータ**:
- `category` (String): カテゴリー名

**戻り値**:
- `List<ThemePair>`: 指定カテゴリーのお題リスト

**使用例**:
```dart
final animalThemes = themeRepository.getThemesByCategory('動物');
```

---

##### getCategories
全カテゴリーを取得

**シグネチャ**:
```dart
List<String> getCategories()
```

**戻り値**:
- `List<String>`: カテゴリー名のリスト

**使用例**:
```dart
final categories = themeRepository.getCategories();
```

---

##### getRandomTheme
ランダムにお題を取得

**シグネチャ**:
```dart
ThemePair getRandomTheme()
```

**戻り値**:
- `ThemePair`: ランダムに選ばれたお題

**使用例**:
```dart
final randomTheme = themeRepository.getRandomTheme();
```

---

##### getThemeById
IDでお題を取得

**シグネチャ**:
```dart
ThemePair? getThemeById(String id)
```

**パラメータ**:
- `id` (String): お題のID

**戻り値**:
- `ThemePair?`: 該当するお題（見つからない場合null）

**使用例**:
```dart
final theme = themeRepository.getThemeById('animal_001');
```

---

## 5. ユースケースAPI

### 5.1 SelectWolfUseCase

**目的**: ウルフをランダムに選出

#### 5.1.1 メソッド

##### execute
ウルフのインデックスを取得

**シグネチャ**:
```dart
List<int> execute({
  required int playerCount,
  int? wolfCount,
})
```

**パラメータ**:
- `playerCount` (int): プレイヤー数
- `wolfCount` (int?): ウルフ数（nullの場合自動計算）

**戻り値**:
- `List<int>`: ウルフのプレイヤーインデックスリスト

**ロジック**:
```
if wolfCount == null:
  if playerCount <= 4: wolfCount = 1
  else if playerCount <= 6: wolfCount = 1
  else: wolfCount = 2

プレイヤーインデックスをシャッフル
最初のwolfCount個を返す
```

**使用例**:
```dart
final selectWolfUseCase = SelectWolfUseCase();
final wolfIndices = selectWolfUseCase.execute(playerCount: 4);
// 例: [2] → プレイヤー2がウルフ
```

---

### 5.2 CalculateVotesUseCase

**目的**: 投票を集計

#### 5.2.1 メソッド

##### execute
投票結果を集計

**シグネチャ**:
```dart
Map<int, int> execute(Map<int, int> votes)
```

**パラメータ**:
- `votes` (Map<int, int>): 投票者インデックス → 投票先インデックス

**戻り値**:
- `Map<int, int>`: プレイヤーインデックス → 得票数

**使用例**:
```dart
final calculateVotesUseCase = CalculateVotesUseCase();
final votes = {0: 2, 1: 2, 2: 1, 3: 2}; // プレイヤー2に3票
final results = calculateVotesUseCase.execute(votes);
// 結果: {1: 1, 2: 3}
```

---

### 5.3 DetermineWinnerUseCase

**目的**: 勝者を判定

#### 5.3.1 メソッド

##### execute
市民が勝利したか判定

**シグネチャ**:
```dart
bool execute({
  required List<int> mostVotedIndices,
  required List<int> wolfIndices,
})
```

**パラメータ**:
- `mostVotedIndices` (List<int>): 最多票のプレイヤーインデックスリスト
- `wolfIndices` (List<int>): ウルフのプレイヤーインデックスリスト

**戻り値**:
- `bool`: 市民が勝利した場合true

**ロジック**:
```
if mostVotedIndices内にwolfIndicesの要素が1つでも含まれている:
  return true (市民勝利)
else:
  return false (ウルフ勝利)
```

**使用例**:
```dart
final determineWinnerUseCase = DetermineWinnerUseCase();
final citizensWon = determineWinnerUseCase.execute(
  mostVotedIndices: [2],
  wolfIndices: [2],
);
// 結果: true（ウルフを当てた）
```

---

## 6. イベント/コールバック

### 6.1 タイマーイベント

#### onTimerTick
タイマーが1秒経過するたびに呼ばれる

**シグネチャ**:
```dart
void Function(int remainingSeconds)?
```

**パラメータ**:
- `remainingSeconds` (int): 残り秒数

---

#### onTimerComplete
タイマーが終了した時に呼ばれる

**シグネチャ**:
```dart
void Function()?
```

---

#### onTimerWarning
タイマーが警告閾値に達した時に呼ばれる

**シグネチャ**:
```dart
void Function(int remainingSeconds)?
```

**パラメータ**:
- `remainingSeconds` (int): 残り秒数

---

### 6.2 ゲームフェーズ変更イベント

#### onPhaseChanged
ゲームフェーズが変更された時に呼ばれる

**シグネチャ**:
```dart
void Function(GamePhase newPhase)?
```

**パラメータ**:
- `newPhase` (GamePhase): 新しいフェーズ

---

## 7. エラーハンドリング

### 7.1 エラー型

#### ValidationError
入力検証エラー

**プロパティ**:
- `message` (String): エラーメッセージ
- `field` (String): エラーが発生したフィールド名

**例**:
```dart
throw ValidationError(
  message: 'プレイヤー数は3-8人である必要があります',
  field: 'playerCount',
);
```

---

#### StorageError
ストレージアクセスエラー

**プロパティ**:
- `message` (String): エラーメッセージ
- `originalError` (Object?): 元のエラー

**例**:
```dart
throw StorageError(
  message: '設定の保存に失敗しました',
  originalError: e,
);
```

---

### 7.2 エラーハンドリングパターン

```dart
try {
  await ref.read(gameStateProvider.notifier).startGame();
} catch (e) {
  if (e is ValidationError) {
    // バリデーションエラーの処理
    showErrorDialog(e.message);
  } else if (e is StorageError) {
    // ストレージエラーの処理
    showErrorDialog('データの保存に失敗しました');
  } else {
    // その他のエラー
    showErrorDialog('予期しないエラーが発生しました');
  }
}
```

---

## 8. データフロー図

### 8.1 ゲーム開始フロー

```
[UI] setPlayerCount(4)
  → [GameStateNotifier] プレイヤーリスト初期化
  → [GameState] 更新
  → [UI] 再描画

[UI] selectTheme(theme)
  → [GameStateNotifier] お題選択
  → [GameState] 更新

[UI] startGame()
  → [GameStateNotifier] 
    → [SelectWolfUseCase] ウルフ選出
    → [GameStateNotifier] お題割り当て
    → [GameState] フェーズ変更
  → [UI] お題配布画面へ遷移
```

---

### 8.2 投票フロー

```
[UI] vote(voterIndex, targetIndex)
  → [GameStateNotifier] 投票記録
  → [GameState] votes更新
  
全員投票完了時:
  → [GameStateNotifier] 
    → [CalculateVotesUseCase] 集計
    → [DetermineWinnerUseCase] 勝者判定
    → [GameState] フェーズ変更(result)
  → [UI] 結果画面へ遷移
```

---

## 9. パフォーマンス考慮事項

### 9.1 状態の最適化

- **部分的な監視**: `select`を使用して必要な部分のみ監視
```dart
final playerCount = ref.watch(gameStateProvider.select((s) => s.playerCount));
```

- **family providerのキャッシュ**: 同じパラメータで再利用

---

### 9.2 メモリ管理

- **大きなリストの処理**: `ListView.builder`を使用
- **画像のキャッシュ**: `CachedNetworkImage`（不要、ローカルのみ）
- **Providerの適切な破棄**: `ref.onDispose`で cleanup

---

## 10. セキュリティ考慮事項

### 10.1 データの検証

すべてのユーザー入力に対してバリデーションを実施:
- プレイヤー数: 3-8
- プレイヤー名: 最大20文字
- タイマー時間: 指定範囲内

### 10.2 ローカルストレージ

- 個人情報は保存しない
- ゲームデータのみを保存
- SharedPreferencesを使用（暗号化不要）

---

## 変更履歴

| 日付 | バージョン | 変更内容 | 担当者 |
|------|-----------|---------|-------|
| 2025-12-06 | 1.0.0 | 初版作成 | - |
