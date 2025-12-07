import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/app_card.dart';

/// ルール説明画面
class RulesScreen extends ConsumerWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.rules),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          children: [
            // ゲーム概要
            Text(
              'ゲーム概要',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSizes.spacingM),
            AppCard(
              child: Text(
                'ジェスチャーウルフは、3〜8人で遊べるパーティーゲームです。プレイヤーは「市民」と「ウルフ」に分かれ、与えられたお題をジェスチャーで表現します。市民には同じお題が、ウルフには少し違うお題が与えられます。ディスカッションと投票で誰がウルフかを見破りましょう！',
                style: AppTextStyles.bodyMedium,
              ),
            ),
            const SizedBox(height: AppSizes.spacingXL),

            // ゲームの流れ
            Text(
              'ゲームの流れ',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSizes.spacingM),
            _RuleStep(
              number: 1,
              title: 'プレイヤー設定',
              description: 'プレイヤー数（3〜8人）と各プレイヤーの名前を設定します。',
            ),
            _RuleStep(
              number: 2,
              title: 'お題選択',
              description: 'カテゴリーからお題を選びます。市民とウルフで微妙に違うお題が配られます。',
            ),
            _RuleStep(
              number: 3,
              title: 'お題確認',
              description: '各プレイヤーは順番に自分のお題を確認します。他の人に見えないように注意！',
            ),
            _RuleStep(
              number: 4,
              title: 'ジェスチャータイム（第1ラウンド）',
              description: '全員が同時に、自分のお題をジェスチャーで表現します。声を出してはいけません！',
            ),
            _RuleStep(
              number: 5,
              title: 'ジェスチャータイム（第2ラウンド）',
              description: 'もう一度ジェスチャーで表現します。違いに注目しましょう。',
            ),
            _RuleStep(
              number: 6,
              title: 'ディスカッション',
              description: '誰がウルフかを話し合います。お題について質問したり、怪しい人の理由を考えましょう。',
            ),
            _RuleStep(
              number: 7,
              title: '投票',
              description: 'ウルフだと思う人に投票します。',
            ),
            _RuleStep(
              number: 8,
              title: '結果発表',
              description: '投票結果とウルフが公開されます。市民がウルフを見破れば市民の勝利、逃げ切ればウルフの勝利！',
            ),
            const SizedBox(height: AppSizes.spacingXL),

            // 勝利条件
            Text(
              '勝利条件',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSizes.spacingM),
            AppCard(
              backgroundColor: AppColors.citizenColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: AppColors.citizenColor,
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Text(
                        '市民の勝利',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.citizenColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    '最多票を獲得したプレイヤーがウルフだった場合',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            AppCard(
              backgroundColor: AppColors.wolfColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.dangerous,
                        color: AppColors.wolfColor,
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Text(
                        'ウルフの勝利',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.wolfColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    '最多票を獲得したプレイヤーが市民だった場合',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingXL),

            // ヒント
            Text(
              'ゲームのヒント',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSizes.spacingM),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HintItem('ジェスチャーの違いに注目しよう'),
                  _HintItem('お題について具体的に質問してみよう'),
                  _HintItem('ウルフは市民のふりをしよう'),
                  _HintItem('急に話題を変える人は怪しいかも'),
                  _HintItem('ディスカッションで情報を引き出そう'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleStep extends StatelessWidget {
  const _RuleStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final int number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXS),
                  Text(
                    description,
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
    );
  }
}

class _HintItem extends StatelessWidget {
  const _HintItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
