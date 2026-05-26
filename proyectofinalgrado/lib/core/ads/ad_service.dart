import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // IDs de prueba de Google — sustituir por los reales antes de publicar
  // TODO: cambiar al ID real cuando AdMob active la cuenta
  // static const _rewardedAdUnitId = 'ca-app-pub-1123670132472584/6926759204';
  static const _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  RewardedAd? _ad;
  bool _isLoaded = false;

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<void> init() async {
    if (!isSupported) return;
    await MobileAds.instance.initialize();
  }

  Future<void> load() async {
    if (!isSupported) return;
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoaded = true;
          print('AdMob: anuncio cargado OK');
        },
        onAdFailedToLoad: (error) {
          _isLoaded = false;
          print('AdMob: error al cargar — ${error.code}: ${error.message}');
        },
      ),
    );
  }

  /// Muestra el anuncio rewarded.
  /// [onRewarded] se llama si el usuario lo completa o en plataformas sin ads.
  /// [onNotReady] se llama si el anuncio aún no ha cargado.
  void show({
    required VoidCallback onRewarded,
    VoidCallback? onNotReady,
  }) {
    if (!isSupported) {
      onRewarded(); // Windows/Web: no hay ads, conceder directamente
      return;
    }
    if (!_isLoaded || _ad == null) {
      onNotReady?.call(); // Android pero el ad aún no cargó
      return;
    }

    var earned = false;

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _isLoaded = false;
        load(); // precarga el siguiente
        if (earned) onRewarded(); // ejecutar DESPUÉS de cerrar el anuncio
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _ad = null;
        _isLoaded = false;
        onRewarded();
      },
    );

    _ad!.show(onUserEarnedReward: (_, _) => earned = true);
  }
}
