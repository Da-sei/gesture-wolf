/// 投票を集計するユースケース
class CalculateVotesUseCase {
  /// 投票結果を集計
  /// 
  /// [votes] 投票者インデックス → 投票先インデックス
  /// Returns プレイヤーインデックス → 得票数
  Map<int, int> execute(Map<int, int> votes) {
    final results = <int, int>{};

    for (final targetIndex in votes.values) {
      results[targetIndex] = (results[targetIndex] ?? 0) + 1;
    }

    return results;
  }

  /// 最多票のプレイヤーインデックスを取得
  List<int> getMostVoted(Map<int, int> voteResults) {
    if (voteResults.isEmpty) return [];

    final maxVotes = voteResults.values.reduce((a, b) => a > b ? a : b);
    return voteResults.entries
        .where((entry) => entry.value == maxVotes)
        .map((entry) => entry.key)
        .toList();
  }
}
