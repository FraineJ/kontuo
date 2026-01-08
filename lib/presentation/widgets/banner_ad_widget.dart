import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../helper_google_ads.dart';
import '../../../core/theme/app_theme.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize? adSize;
  final bool showBorder;

  const BannerAdWidget({
    super.key,
    this.adSize,
    this.showBorder = true,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (!mounted) return;
    
    setState(() {
      _isAdLoading = true;
      _isAdLoaded = false;
      _bannerAd = null;
    });

    final adSize = widget.adSize ?? AdSize.banner;
    print('Loading banner ad with size: ${adSize.width}x${adSize.height}');
    
    try {
      final bannerAd = AdsHelper.loadBannerAd(
        adSize: adSize,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('Banner ad loaded successfully');
            if (mounted) {
              // Use WidgetsBinding.instance.addPostFrameCallback to avoid layout conflicts
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _bannerAd = ad as BannerAd;
                    _isAdLoaded = true;
                    _isAdLoading = false;
                  });
                }
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            print('Banner ad failed to load: ${error.code} - ${error.message}');
            print('Error domain: ${error.domain}');
            print('Error response info: ${error.responseInfo}');
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isAdLoaded = false;
                    _isAdLoading = false;
                  });
                }
                ad.dispose();
              });
            } else {
              ad.dispose();
            }
          },
          onAdOpened: (ad) {
            print('Banner ad opened');
          },
          onAdClosed: (ad) {
            print('Banner ad closed');
          },
          onAdImpression: (ad) {
            print('Banner ad impression recorded');
          },
        ),
      );

      if (mounted) {
        setState(() {
          _bannerAd = bannerAd;
        });
      }
    } catch (e) {
      print('Exception while loading banner ad: $e');
      if (mounted) {
        setState(() {
          _isAdLoading = false;
          _isAdLoaded = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoading) {
      return Container(
        height: widget.adSize?.height.toDouble() ?? AdSize.banner.height.toDouble(),

        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppTheme.positiveGreen,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    // Get the ad size height, default to standard banner height (50)
    final adSize = widget.adSize ?? AdSize.banner;
    final adHeight = adSize.height.toDouble();
    final adWidth = adSize.width.toDouble();

    return Container(
      width: double.infinity,
      height: adHeight,
      alignment: Alignment.center,
      decoration: widget.showBorder
          ? BoxDecoration(
              color: AppTheme.textPrimary,

            )
          : null,
      child: SizedBox(
        width: adWidth,
        height: adHeight,
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}

