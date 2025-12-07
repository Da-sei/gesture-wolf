import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/game_settings.dart';
import '../../providers/game_settings_provider.dart';

/// 設定画面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gameSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          children: [
            // ゲーム設定
            Text(
              'ゲーム設定',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSizes.spacingM),

            // ジェスチャー時間
            _SettingTile(
              title: 'ジェスチャー時間',
              subtitle: '${settings.gestureDuration}秒',
              onTap: () {
                _showDurationPicker(
                  context,
                  ref,
                  'ジェスチャー時間',
                  settings.gestureDuration,
                  (value) => ref
                      .read(gameSettingsProvider.notifier)
                      .updateGestureDuration(value),
                );
              },
            ),

            // ディスカッション時間
            _SettingTile(
              title: 'ディスカッション時間',
              subtitle: '${settings.discussionDuration ~/ 60}分',
              onTap: () {
                _showDurationPicker(
                  context,
                  ref,
                  'ディスカッション時間',
                  settings.discussionDuration ~/ 60,
                  (value) => ref
                      .read(gameSettingsProvider.notifier)
                      .updateDiscussionDuration(value * 60),
                  isMinutes: true,
                );
              },
            ),

            // 7-8人時のウルフ数
            _SettingTile(
              title: '7-8人時のウルフ数',
              subtitle: '${settings.wolfCountFor7to8Players}人',
              onTap: () {
                _showWolfCountPicker(context, ref, settings);
              },
            ),

            // ジェスチャーのラウンド数
            _SettingTile(
              title: 'ジェスチャーのラウンド数',
              subtitle: '${settings.gestureRounds}周',
              onTap: () {
                _showGestureRoundsPicker(context, ref, settings);
              },
            ),

            const SizedBox(height: AppSizes.spacingXL),

            // サウンド設定
            Text(
              'サウンド設定',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSizes.spacingM),

            SwitchListTile(
              title: const Text('効果音'),
              value: settings.soundEnabled,
              onChanged: (value) {
                ref.read(gameSettingsProvider.notifier).toggleSound(value);
              },
              activeColor: AppColors.primary,
            ),

            SwitchListTile(
              title: const Text('BGM'),
              value: settings.musicEnabled,
              onChanged: (value) {
                ref.read(gameSettingsProvider.notifier).toggleMusic(value);
              },
              activeColor: AppColors.primary,
            ),

            const SizedBox(height: AppSizes.spacingXL),

            // 表示設定
            Text(
              '表示設定',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSizes.spacingM),

            SwitchListTile(
              title: const Text('ダークモード'),
              value: settings.darkMode,
              onChanged: (value) {
                ref.read(gameSettingsProvider.notifier).toggleDarkMode(value);
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showDurationPicker(
    BuildContext context,
    WidgetRef ref,
    String title,
    int currentValue,
    Function(int) onChanged, {
    bool isMinutes = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: isMinutes ? 10 : 60,
            itemBuilder: (context, index) {
              final value = isMinutes ? index + 1 : (index + 1) * 5;
              return ListTile(
                title: Text('$value${isMinutes ? "分" : "秒"}'),
                selected: value == currentValue,
                onTap: () {
                  onChanged(value);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showWolfCountPicker(
    BuildContext context,
    WidgetRef ref,
    GameSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('7-8人時のウルフ数'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('1人'),
              selected: settings.wolfCountFor7to8Players == 1,
              onTap: () {
                ref
                    .read(gameSettingsProvider.notifier)
                    .setWolfCountFor7to8Players(1);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('2人'),
              selected: settings.wolfCountFor7to8Players == 2,
              onTap: () {
                ref
                    .read(gameSettingsProvider.notifier)
                    .setWolfCountFor7to8Players(2);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showGestureRoundsPicker(
    BuildContext context,
    WidgetRef ref,
    GameSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ジェスチャーのラウンド数'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final rounds = index + 1;
            return ListTile(
              title: Text('${rounds}周'),
              selected: settings.gestureRounds == rounds,
              onTap: () {
                ref
                    .read(gameSettingsProvider.notifier)
                    .updateGestureRounds(rounds);
                Navigator.of(context).pop();
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
