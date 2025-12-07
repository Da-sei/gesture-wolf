import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/app_button.dart';
import '../../widgets/countdown_timer.dart';
import '../../providers/game_state_provider.dart';
import '../../providers/game_settings_provider.dart';

/// ディスカッション画面
class DiscussionScreen extends ConsumerWidget {
  const DiscussionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final settings = ref.watch(gameSettingsProvider);
    final currentRound = gameState.gestureRound;
    final totalRounds = settings.gestureRounds;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.discussion),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ディスカッション',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                '誰がウルフか話し合おう！',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacingXXL),

              // タイマー
              CountdownTimer(
                duration: Duration(seconds: settings.discussionDuration),
                onComplete: () {
                  // タイマー完了後に投票へ
                  ref.read(gameStateProvider.notifier).startVoting();
                  context.go('/voting');
                },
              ),

              const SizedBox(height: AppSizes.spacingXXL),

              // ヒント
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: AppSizes.spacingS),
                        Text(
                          'ディスカッションのヒント',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingS),
                    Text(
                      '・ジェスチャーの違いに注目しましょう\n・お題について質問してみましょう\n・怪しい人の理由を考えましょう',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // プレイヤー数表示
              Text(
                'プレイヤー: ${gameState.players.length}人 / ウルフ: ${gameState.wolfCount}人',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),

              // 投票へ進むボタン
              AppButton(
                text: '投票へ',
                onPressed: () {
                  ref.read(gameStateProvider.notifier).startVoting();
                  context.go('/voting');
                },
                width: double.infinity,
                height: AppSizes.buttonHeightL,
              ),

              // 次ラウンドへ（未完了の場合のみ）
              if (currentRound < totalRounds) ...[
                const SizedBox(height: AppSizes.spacingM),
                AppButton(
                  text: '第${currentRound + 1}ラウンドへ',
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).startSecondRound();
                    context.go('/gesture-time');
                  },
                  width: double.infinity,
                  height: AppSizes.buttonHeightL,
                  isOutlined: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
