import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sano_gano/view/pages/home/show_ad.dart';

import '../../../services/ads_service.dart';

class AdController extends GetxController {
  Rx<List<NativeAd?>?> _listOfHomePageAds = Rx<List<NativeAd?>?>([]);
  List<NativeAd?>? get homePageAds => _listOfHomePageAds.value;

  Rx<List<NativeAd?>?> _listOfHashtagAds = Rx<List<NativeAd?>?>([]);
  List<NativeAd?>? get hashtagAds => _listOfHashtagAds.value;

  Rx<List<NativeAd?>?> _trendingScreenAds = Rx<List<NativeAd?>?>([]);
  List<NativeAd?>? get trendingScreenAds => _trendingScreenAds.value;

  NativeAd? getAd(AdScreen adScreen, int index) {
    switch (adScreen) {
      case AdScreen.home:
        if (!_listOfHomePageAds.value!.asMap().containsKey(index - 1)) {
          return null;
        } else {
          return _listOfHomePageAds.value![index - 1];
        }

      case AdScreen.hashtag:
        if (!_listOfHashtagAds.value!.asMap().containsKey(index - 1)) {
          return null;
        } else {
          return _listOfHashtagAds.value![index - 1];
        }

      case AdScreen.trending:
        if (!_trendingScreenAds.value!.asMap().containsKey(index - 1)) {
          return null;
        } else {
          return _trendingScreenAds.value![index - 1];
        }
      default:
        return null;
    }
  }

  Future<NativeAd?> createAd(AdScreen adScreen, int index) async {
    await _makeAd(adScreen);

    switch (adScreen) {
      case AdScreen.home:
        await 1.seconds.delay();
        return _listOfHomePageAds.value![index - 1];
      case AdScreen.hashtag:
        await 1.seconds.delay();

        return _listOfHashtagAds.value![index - 1];
      case AdScreen.trending:
        await 1.seconds.delay();

        return _trendingScreenAds.value![index - 1];
      default:
        return null;
    }
  }

  Future<void> _makeAd(AdScreen screenType) async {
    await NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      request: AdRequest(),
      factoryId: 'listTile',
      listener: NativeAdListener(
        onAdLoaded: (loadedAd) {
          switch (screenType) {
            case AdScreen.home:
              _listOfHomePageAds.value!.add(loadedAd as NativeAd);
              break;
            case AdScreen.hashtag:
              _listOfHashtagAds.value!.add(loadedAd as NativeAd);
              break;
            case AdScreen.trending:
              _trendingScreenAds.value!.add(loadedAd as NativeAd);
              break;
            default:
          }
        },
        onAdWillDismissScreen: (ad) {
          print('Ad will dismiss.');
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void onClose() {
    for (var element in _listOfHomePageAds.value!) {
      element?.dispose();
    }
    for (var element in _listOfHashtagAds.value!) {
      element?.dispose();
    }
    for (var element in _trendingScreenAds.value!) {
      element?.dispose();
    }
    super.onClose();
  }
}
