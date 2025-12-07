import 'dart:math';

/// ウルフをランダムに選出するユースケース
class SelectWolfUseCase {
  /// ウルフのインデックスを取得
  /// 
  /// [playerCount] プレイヤー数
  /// [wolfCount] ウルフ数（nullの場合自動計算）
  List<int> execute({
    required int playerCount,
    int? wolfCount,
  }) {
    // ウルフ数を計算
    final count = wolfCount ?? _calculateWolfCount(playerCount);

    // プレイヤーインデックスをシャッフル
    final indices = List.generate(playerCount, (i) => i);
    indices.shuffle(Random());

    // 最初のcount個を返す
    return indices.take(count).toList();
  }

  int _calculateWolfCount(int playerCount) {
    if (playerCount <= 4) return 1;
    if (playerCount <= 6) return 1;
    return 2; // 7-8人の場合、デフォルトは2
  }
}
