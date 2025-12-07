import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 広告サービス
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  /// AdMobを初期化
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// 広告ユニットID
  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2196054972001278/2279886813'; // Android本番
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2196054972001278/2279886813'; // iOS本番
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// インタースティシャル広告をロード
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          print('インタースティシャル広告がロードされました');
        },
        onAdFailedToLoad: (error) {
          print('インタースティシャル広告のロードに失敗: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// インタースティシャル広告を表示
  Future<void> showInterstitialAd({VoidCallback? onAdDismissed}) async {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('広告が表示されました');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('広告が閉じられました');
          ad.dispose();
          _isAdLoaded = false;
          _interstitialAd = null;
          onAdDismissed?.call();
          // 次の広告をプリロード
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('広告の表示に失敗: $error');
          ad.dispose();
          _isAdLoaded = false;
          _interstitialAd = null;
          onAdDismissed?.call();
          // 次の広告をプリロード
          loadInterstitialAd();
        },
      );
      await _interstitialAd!.show();
    } else {
      print('広告がまだロードされていません');
      onAdDismissed?.call();
      // 広告がロードされていない場合は再ロード
      loadInterstitialAd();
    }
  }

  /// リソースの解放
  void dispose() {
    _interstitialAd?.dispose();
  }
}
