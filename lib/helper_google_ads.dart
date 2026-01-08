import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Use test ad unit ID for development, replace with your real ad unit ID for production
      // For testing: 'ca-app-pub-3940256099942544/6300978111'
      return 'ca-app-pub-1703656518984505/7382211623';
    } else if (Platform.isIOS) {
      // Use test ad unit ID for development, replace with your real ad unit ID for production
      // For testing: 'ca-app-pub-3940256099942544/2934735716'
      return 'ca-app-pub-1703656518984505/8564782427';
    } else {
      throw UnsupportedError("Plataforma no compatible");
    }
  }

  /// Crea y carga un banner ad
  /// Retorna el BannerAd creado. El listener debe manejar los eventos de carga
  static BannerAd loadBannerAd({
    AdSize? adSize,
    required BannerAdListener listener,
  }) {
    final bannerAd = BannerAd(
      size: adSize ?? AdSize.banner,
      adUnitId: bannerAdUnitId,
      listener: listener,
      request: const AdRequest(),
    );

    // Inicia la carga del anuncio (asíncrono, el listener notificará cuando esté listo)
    bannerAd.load();
    return bannerAd;
  }
}