import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/app_button.dart';
import '../../providers/theme_provider.dart';
import '../../providers/game_state_provider.dart';

/// お題選択画面
class ThemeSelectionScreen extends ConsumerStatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  ConsumerState<ThemeSelectionScreen> createState() =>
      _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends ConsumerState<ThemeSelectionScreen> {
  String? _selectedCategory;

  void _onNext() {
    // カテゴリからランダムにお題を選択
    final themes = _selectedCategory == null
        ? ref.read(themesProvider)
        : ref.read(themesByCategoryProvider(_selectedCategory!));
    
    if (themes.isEmpty) return;
    
    final randomTheme = themes[DateTime.now().millisecondsSinceEpoch % themes.length];
    ref.read(gameStateProvider.notifier).selectTheme(randomTheme);
    context.go('/theme-distribution');
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.themeSelection),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/player-setup'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 説明テキスト
              Text(
                'カテゴリを選択すると、ランダムにお題が選ばれます',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXL),

              // カテゴリー選択
              Text(
                AppStrings.category,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSizes.spacingM),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSizes.spacingM,
                    mainAxisSpacing: AppSizes.spacingM,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _CategoryCard(
                        label: 'すべて',
                        isSelected: _selectedCategory == null,
                        onTap: () {
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                      );
                    }
                    
                    final category = categories[index - 1];
                    return _CategoryCard(
                      label: category,
                      isSelected: _selectedCategory == category,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
