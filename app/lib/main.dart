import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // AdMobを初期化
  await AdService.initialize();
  
  // 最初の広告をプリロード
  AdService().loadInterstitialAd();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
