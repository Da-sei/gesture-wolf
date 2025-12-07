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

/// ジェスチャータイム画面
class GestureTimeScreen extends ConsumerStatefulWidget {
  const GestureTimeScreen({super.key});

  @override
  ConsumerState<GestureTimeScreen> createState() => _GestureTimeScreenState();
}

class _GestureTimeScreenState extends ConsumerState<GestureTimeScreen> {
  bool _isGesturing = false;

  void _startGesture() {
    setState(() {
      _isGesturing = true;
    });
  }

  void _completeGesture() {
    final gameState = ref.read(gameStateProvider);
    final settings = ref.read(gameSettingsProvider);
    
    if (gameState.currentGesturingPlayerIndex < gameState.players.length - 1) {
      // 次のプレイヤーへ
      ref.read(gameStateProvider.notifier).nextGesturingPlayer();
      setState(() {
        _isGesturing = false;
      });
    } else {
      // 全員完了
      if (gameState.gestureRound < settings.gestureRounds) {
        // 次のラウンドへ
        ref.read(gameStateProvider.notifier).startSecondRound();
        setState(() {
          _isGesturing = false;
        });
      } else {
        // ディスカッションへ
        context.go('/discussion');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final settings = ref.watch(gameSettingsProvider);
    final currentRound = gameState.gestureRound;
    final totalRounds = settings.gestureRounds;
    final currentPlayer = gameState.players[gameState.currentGesturingPlayerIndex];
    final playerProgress = gameState.currentGesturingPlayerIndex + 1;
    final totalPlayers = gameState.players.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('第${currentRound}ラウンド / 全${totalRounds}ラウンド - ${AppStrings.gestureTime}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            children: [
                // プレイヤー情報
                Container(
                  padding: const EdgeInsets.all(AppSizes.spacingL),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentPlayer.name,
                        style: AppTextStyles.displaySmall,
                      ),
                      const SizedBox(height: AppSizes.spacingS),
                      Text(
                        'のターン',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXL),

                // 進捗表示
                LinearProgressIndicator(
                  value: playerProgress / totalPlayers,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: AppSizes.spacingS),
                Text(
                  '$playerProgress / $totalPlayers',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXL),

                if (!_isGesturing) ...[
                  // 準備画面
                  const SizedBox(height: AppSizes.spacingXL),
                  Text(
                    '準備はいいですか？',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: AppSizes.spacingXL),
                  AppButton(
                    text: 'ジェスチャー開始',
                    onPressed: _startGesture,
                    width: double.infinity,
                    height: AppSizes.buttonHeightL,
                  ),
                  const SizedBox(height: AppSizes.spacingXL),
                ] else ...[
                  // ジェスチャー中
                  Text(
                    '第${currentRound}ラウンド',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  Text(
                    'ジェスチャーでお題を伝えよう！',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spacingXL),

                  // タイマー
                  CountdownTimer(
                    duration: Duration(seconds: settings.gestureDuration),
                    onComplete: () {
                      // タイマー完了後は手動で次へ
                    },
                    showControls: false,
                  ),

                  const Spacer(),

                  // 次へボタン
                  AppButton(
                    text: gameState.currentGesturingPlayerIndex < gameState.players.length - 1
                        ? '次のプレイヤーへ'
                        : (gameState.gestureRound < settings.gestureRounds
                            ? '次のラウンドへ'
                            : 'ディスカッションへ'),
                    onPressed: _completeGesture,
                    width: double.infinity,
                    height: AppSizes.buttonHeightL,
                  ),
                  const SizedBox(height: AppSizes.spacingXL),
                ],
              ],
            ),
          ),
        ),
    );
  }
}
