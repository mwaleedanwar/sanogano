import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sano_gano/view/pages/home/ad_controller.dart';

import '../../../services/ads_service.dart';

class ShowAd extends StatefulWidget {
  final int index;
  final AdScreen adScreen;
  const ShowAd({
    super.key,
    required this.index,
    required this.adScreen,
  });
  @override
  ShowAdState createState() => ShowAdState();
}

class ShowAdState extends State<ShowAd> {
  int get adIndex => widget.index ~/ 10;
  Rx<NativeAd?> _ad = Rx<NativeAd?>(null);
  NativeAd? get ad => _ad.value;
  NativeAd? testAd;
  AdController adController = Get.find<AdController>();
  @override
  void initState() {
    NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      request: AdRequest(),
      factoryId: 'listTile',
      listener: NativeAdListener(
        onAdLoaded: (loadedAd) {
          testAd = loadedAd as NativeAd;
          print("ad loaded");
          setState(() {});
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
    // _ad.value = adController.getAd(widget.adScreen, adIndex);
    // 2.seconds.delay().then((value) {
    //   if (mounted && _ad.value == null) setState(() {});
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return testAd != null ? ShowAdWidget(ad: testAd!) : SizedBox.shrink();
    // return Obx(() {
    //   return _ad.value != null
    //       ? ShowAdWidget(ad: _ad.value!)
    //       : FutureBuilder<NativeAd?>(
    //           future: adController.createAd(widget.adScreen, adIndex),
    //           builder: (context, snapshot) {
    //             if (!snapshot.hasData) {
    //               print("no ad");
    //               _ad.value = null;
    //               return SizedBox.shrink();
    //             }
    //             print("building ad");
    //             _ad.value = snapshot.data;
    //             return ShowAdWidget(ad: _ad.value!);
    //           },
    //         );
    //   // : ShowAdWidget(ad: _ad.value!);
    // });
  }
}

class ShowAdWidget extends StatelessWidget {
  NativeAd ad;
  ShowAdWidget({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      child: AdWidget(
        ad: ad,
      ),
    );
  }
}

enum AdScreen { home, hashtag, trending }
