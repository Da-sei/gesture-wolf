import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/game_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../providers/game_state_provider.dart';

/// お題配布画面
class ThemeDistributionScreen extends ConsumerWidget {
  const ThemeDistributionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final currentPlayer = gameState.currentPlayer;

    if (gameState.currentPhase != GamePhase.themeDistribution) {
      return Scaffold(
        body: Center(
          child: AppButton(
            text: 'ゲームを開始',
            onPressed: () {
              ref.read(gameStateProvider.notifier).startGame();
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.themeDistribution),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // プレイヤー名
              Text(
                currentPlayer?.name ?? '',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                'お題を確認してください',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXXL),

              // お題カード（表示/非表示）
              if (!gameState.isThemeVisible) ...[
                AppCard(
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Center(
                      child: Icon(
                        Icons.visibility_off,
                        size: 48,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXL),
                AppButton(
                  text: 'お題を表示',
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).showTheme();
                  },
                  width: double.infinity,
                  height: AppSizes.buttonHeightL,
                ),
              ] else ...[
                AppCard(
                  backgroundColor: currentPlayer?.isWolf == true
                      ? AppColors.wolfColor.withOpacity(0.1)
                      : AppColors.citizenColor.withOpacity(0.1),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentPlayer?.isWolf == true ? 'あなたはウルフです' : 'あなたは市民です',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: currentPlayer?.isWolf == true
                                ? AppColors.wolfColor
                                : AppColors.citizenColor,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingL),
                        Text(
                          currentPlayer?.theme ?? '',
                          style: AppTextStyles.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXL),
                AppButton(
                  text: '確認しました',
                  onPressed: () {
                    final notifier = ref.read(gameStateProvider.notifier);
                    notifier.confirmTheme();
                    
                    // 次のプレイヤーへ
                    if (gameState.currentPlayerIndex < gameState.players.length - 1) {
                      notifier.nextPlayer();
                    } else {
                      // 全員確認完了
                      context.go('/gesture-time');
                    }
                  },
                  width: double.infinity,
                  height: AppSizes.buttonHeightL,
                ),
              ],

              const SizedBox(height: AppSizes.spacingXL),
              // 進捗表示
              Text(
                '${gameState.currentPlayerIndex + 1} / ${gameState.players.length}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
