import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../widgets/app_button.dart';

/// ホーム画面
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // タイトルロゴ
                Image.asset(
                  'assets/images/title_icon.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSizes.spacingS),

                // メニューボタン
                AppButton(
                  text: 'ゲーム開始',
                  onPressed: () => context.go('/player-setup'),
                  backgroundColor: Colors.white,
                  textColor: AppColors.primary,
                  width: double.infinity,
                  height: AppSizes.buttonHeightL,
                ),
                const SizedBox(height: AppSizes.spacingM),
                AppButton(
                  text: 'ルール説明',
                  onPressed: () => context.go('/rules'),
                  backgroundColor: Colors.white,
                  textColor: AppColors.primary,
                  width: double.infinity,
                  height: AppSizes.buttonHeightL,
                ),
                const SizedBox(height: AppSizes.spacingM),
                AppButton(
                  text: '設定',
                  onPressed: () => context.go('/settings'),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  textColor: Colors.white,
                  width: double.infinity,
                  height: AppSizes.buttonHeightL,
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
