import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-5415015545263230/8662755749';
    } else if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/3986624511'
          : 'ca-app-pub-5415015545263230/9107239185';
    }
    throw UnsupportedError("Unsupported platform");
  }
}

class AdService {
  static Future<void> init() async {
    List<String> testDeviceIds = [
      'E74E7E410FACDA7137B831CC2710E68E',
      '74CB5949-5D24-4167-880B-B923BE9B3743'
    ];

    await MobileAds.instance.initialize();
    RequestConfiguration configuration =
        RequestConfiguration(testDeviceIds: testDeviceIds);
    MobileAds.instance.updateRequestConfiguration(configuration);
  }
}
