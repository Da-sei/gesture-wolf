/// 勝者を判定するユースケース
class DetermineWinnerUseCase {
  /// 市民が勝利したか判定
  /// 
  /// [mostVotedIndices] 最多票のプレイヤーインデックスリスト
  /// [wolfIndices] ウルフのプレイヤーインデックスリスト
  /// Returns 市民が勝利した場合true
  bool execute({
    required List<int> mostVotedIndices,
    required List<int> wolfIndices,
  }) {
    // 最多票にウルフが含まれているか
    return mostVotedIndices.any((index) => wolfIndices.contains(index));
  }
}
