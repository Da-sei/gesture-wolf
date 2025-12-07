import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/ad_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/player_avatar.dart';
import '../../providers/game_state_provider.dart';

/// 結果画面
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // 結果画面表示時に広告を表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdService().showInterstitialAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final voteResultsMap = ref.read(gameStateProvider.notifier).getVoteResults();
    final citizensWon = ref.read(gameStateProvider.notifier).didCitizensWin();

    // 最多票プレイヤー
    final mostVoted = ref.read(gameStateProvider.notifier).getMostVotedPlayers();

    // 投票結果をリスト化
    final voteResults = voteResultsMap.entries
        .map((e) => {'playerIndex': e.key, 'voteCount': e.value})
        .toList()
      ..sort((a, b) => (b['voteCount'] as int).compareTo(a['voteCount'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.result),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            children: [
              // 勝敗表示
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingXL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: citizensWon
                        ? [AppColors.citizenColor, AppColors.citizenColor.withOpacity(0.7)]
                        : [AppColors.wolfColor, AppColors.wolfColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: Column(
                  children: [
                    Text(
                      citizensWon ? '市民の勝利！' : 'ウルフの勝利！',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    Text(
                      citizensWon
                          ? 'ウルフを見破りました！'
                          : 'ウルフは逃げ切りました！',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingXL),

              // ウルフ公開
              Text(
                'ウルフは...',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSizes.spacingM),
              ...gameState.players
                  .where((player) => player.isWolf)
                  .map((wolf) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
                        child: AppCard(
                          backgroundColor: AppColors.wolfColor.withOpacity(0.1),
                          child: Row(
                            children: [
                              PlayerAvatar(
                                name: wolf.name,
                                isWolf: true,
                                size: 48,
                              ),
                              const SizedBox(width: AppSizes.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wolf.name,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'お題: ${wolf.theme}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),

              const SizedBox(height: AppSizes.spacingXL),

              // 投票結果
              Text(
                '投票結果',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSizes.spacingM),
              Expanded(
                child: ListView.builder(
                  itemCount: voteResults.length,
                  itemBuilder: (context, index) {
                    final entry = voteResults[index];
                    final playerIndex = entry['playerIndex'] as int;
                    final voteCount = entry['voteCount'] as int;
                    final player = gameState.players[playerIndex];
                    final isMostVoted = mostVoted.contains(playerIndex);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
                      child: AppCard(
                        backgroundColor: isMostVoted
                            ? AppColors.accent.withOpacity(0.1)
                            : AppColors.surfaceLight,
                        child: Row(
                          children: [
                            PlayerAvatar(
                              name: player.name,
                              isWolf: player.isWolf,
                              size: 40,
                            ),
                            const SizedBox(width: AppSizes.spacingM),
                            Expanded(
                              child: Text(
                                player.name,
                                style: AppTextStyles.bodyLarge,
                              ),
                            ),
                            Text(
                              '$voteCount票',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isMostVoted
                                    ? AppColors.accent
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSizes.spacingL),

              // アクションボタン
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'もう一度',
                      onPressed: () {
                        ref.read(gameStateProvider.notifier).resetGame();
                        context.go('/player-setup');
                      },
                      height: AppSizes.buttonHeightL,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: AppButton(
                      text: 'ホームへ',
                      onPressed: () {
                        ref.read(gameStateProvider.notifier).resetGame();
                        context.go('/');
                      },
                      height: AppSizes.buttonHeightL,
                      isOutlined: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
