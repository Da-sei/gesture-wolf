import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/player_setup/player_setup_screen.dart';
import '../../presentation/screens/theme_selection/theme_selection_screen.dart';
import '../../presentation/screens/theme_distribution/theme_distribution_screen.dart';
import '../../presentation/screens/gesture_time/gesture_time_screen.dart';
import '../../presentation/screens/discussion/discussion_screen.dart';
import '../../presentation/screens/voting/voting_screen.dart';
import '../../presentation/screens/result/result_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/rules/rules_screen.dart';

/// ルーティング設定プロバイダー
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/player-setup',
        name: 'playerSetup',
        builder: (context, state) => const PlayerSetupScreen(),
      ),
      GoRoute(
        path: '/theme-selection',
        name: 'themeSelection',
        builder: (context, state) => const ThemeSelectionScreen(),
      ),
      GoRoute(
        path: '/theme-distribution',
        name: 'themeDistribution',
        builder: (context, state) => const ThemeDistributionScreen(),
      ),
      GoRoute(
        path: '/gesture-time',
        name: 'gestureTime',
        builder: (context, state) => const GestureTimeScreen(),
      ),
      GoRoute(
        path: '/discussion',
        name: 'discussion',
        builder: (context, state) => const DiscussionScreen(),
      ),
      GoRoute(
        path: '/voting',
        name: 'voting',
        builder: (context, state) => const VotingScreen(),
      ),
      GoRoute(
        path: '/result',
        name: 'result',
        builder: (context, state) => const ResultScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/rules',
        name: 'rules',
        builder: (context, state) => const RulesScreen(),
      ),
    ],
  );
});
