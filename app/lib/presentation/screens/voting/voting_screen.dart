import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/player_avatar.dart';
import '../../providers/game_state_provider.dart';

/// 投票画面
class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({super.key});

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  int _currentVoterIndex = 0;
  int? _selectedPlayerIndex;

  void _selectPlayer(int index) {
    setState(() {
      _selectedPlayerIndex = index;
    });
  }

  void _confirmVote() {
    if (_selectedPlayerIndex == null) return;
    
    ref.read(gameStateProvider.notifier).vote(_currentVoterIndex, _selectedPlayerIndex!);
    
    final gameState = ref.read(gameStateProvider);
    if (_currentVoterIndex < gameState.players.length - 1) {
      // 次のプレイヤーへ
      setState(() {
        _currentVoterIndex++;
        _selectedPlayerIndex = null;
      });
    } else {
      // 全員投票完了、結果画面へ
      context.go('/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final currentVoter = gameState.players[_currentVoterIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.voting),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 現在の投票者
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  children: [
                    PlayerAvatar(
                      name: currentVoter.name,
                      size: 48,
                    ),
                    const SizedBox(width: AppSizes.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentVoter.name,
                            style: AppTextStyles.headlineMedium,
                          ),
                          Text(
                            '誰がウルフだと思いますか？',
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
              const SizedBox(height: AppSizes.spacingL),

              // 進捗表示
              LinearProgressIndicator(
                value: _currentVoterIndex / gameState.players.length,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                '${_currentVoterIndex + 1} / ${gameState.players.length}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXL),

              // プレイヤーリスト
              Expanded(
                child: ListView.builder(
                  itemCount: gameState.players.length,
                  itemBuilder: (context, index) {
                    final player = gameState.players[index];
                    final isCurrentVoter = index == _currentVoterIndex;
                    final isSelected = _selectedPlayerIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
                      child: AppCard(
                        backgroundColor: isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : (isCurrentVoter
                                ? AppColors.textSecondaryLight.withOpacity(0.3)
                                : AppColors.surfaceLight),
                        onTap: isCurrentVoter ? null : () => _selectPlayer(index),
                        child: Row(
                          children: [
                            PlayerAvatar(
                              name: player.name,
                              size: 48,
                            ),
                            const SizedBox(width: AppSizes.spacingM),
                            Expanded(
                              child: Text(
                                player.name,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: isCurrentVoter
                                      ? AppColors.textSecondaryLight
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            if (isCurrentVoter)
                              Text(
                                '（あなた）',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              )
                            else if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 32,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSizes.spacingL),

              // 確定ボタン
              AppButton(
                text: '投票を確定',
                onPressed: _selectedPlayerIndex == null ? null : _confirmVote,
                width: double.infinity,
                height: AppSizes.buttonHeightL,
                isDisabled: _selectedPlayerIndex == null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
