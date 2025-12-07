import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/app_button.dart';
import '../../providers/game_state_provider.dart';

/// プレイヤー設定画面
class PlayerSetupScreen extends ConsumerStatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  ConsumerState<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends ConsumerState<PlayerSetupScreen> {
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    final gameState = ref.read(gameStateProvider);
    for (int i = 0; i < gameState.playerCount; i++) {
      final controller = TextEditingController(
        text: gameState.players.length > i ? gameState.players[i].name : '',
      );
      _controllers.add(controller);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updatePlayerCount(int count) {
    final currentCount = _controllers.length;
    
    if (count > currentCount) {
      // コントローラー追加
      for (int i = currentCount; i < count; i++) {
        _controllers.add(TextEditingController());
      }
    } else if (count < currentCount) {
      // コントローラー削除
      for (int i = currentCount - 1; i >= count; i--) {
        _controllers[i].dispose();
        _controllers.removeAt(i);
      }
    }
    
    ref.read(gameStateProvider.notifier).setPlayerCount(count);
  }

  void _onNext() {
    // プレイヤー名を保存
    for (int i = 0; i < _controllers.length; i++) {
      final name = _controllers[i].text.trim();
      if (name.isNotEmpty) {
        ref.read(gameStateProvider.notifier).updatePlayerName(i, name);
      }
    }
    
    context.go('/theme-selection');
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.playerSetup),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // プレイヤー数選択
              Text(
                AppStrings.playerCount,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSizes.spacingM),
              Row(
                children: List.generate(6, (index) {
                  final count = index + 3; // 3-8人
                  final isSelected = count == gameState.playerCount;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => _updatePlayerCount(count),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$count人',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSizes.spacingXL),

              // プレイヤー名入力
              Text(
                AppStrings.playerName,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSizes.spacingM),
              Expanded(
                child: ListView.builder(
                  itemCount: _controllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
                      child: TextField(
                        controller: _controllers[index],
                        decoration: InputDecoration(
                          labelText: 'プレイヤー ${index + 1}',
                          hintText: 'プレイヤー${index + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 次へボタン
              const SizedBox(height: AppSizes.spacingL),
              AppButton(
                text: AppStrings.next,
                onPressed: _onNext,
                width: double.infinity,
                height: AppSizes.buttonHeightL,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
