import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/search_controller.dart';

class ScrollAndFocusControllerHelper extends GetxController
    with GetTickerProviderStateMixin {
  //Focs Nodes and variables
  Rx<FocusNode> _focus = FocusNode().obs;
  FocusNode get focus => _focus.value;
  RxInt _haveFocus = 0.obs;
  int get haveFocus => _haveFocus.value;
  RxBool _showRecent = true.obs;
  bool get showRecent => _showRecent.value;

  //Health Page Scroll Controllers
  Rx<ScrollController> _healthPageScrollController = ScrollController().obs;
  ScrollController get healthPageScrollController =>
      _healthPageScrollController.value;
  //Profile Page Scroll Controllers
  Rx<ScrollController> _profilePageScrollController = ScrollController().obs;
  ScrollController get profilePageScrollController =>
      _profilePageScrollController.value;
  Rx<ScrollController> _othersPageController = ScrollController().obs;
  ScrollController get othersPageController => _othersPageController.value;

  //Activity Page Scroll Controllers
  Rx<ScrollController> _allActivityScrollController = ScrollController().obs;
  ScrollController get allActivityScrollController =>
      _allActivityScrollController.value;
  Rx<ScrollController> _activityFollowScrollController = ScrollController().obs;
  ScrollController get activityFollowScrollController =>
      _activityFollowScrollController.value;
  Rx<ScrollController> _activityLikesScrollController = ScrollController().obs;
  ScrollController get activityLikesScrollController =>
      _activityLikesScrollController.value;
  Rx<ScrollController> _activityTaggedsScrollController =
      ScrollController().obs;
  ScrollController get activityTaggedScrollController =>
      _activityTaggedsScrollController.value;
  Rx<ScrollController> _activityCommentsScrollController =
      ScrollController().obs;
  ScrollController get activityCommentScrollController =>
      _activityCommentsScrollController.value;

  //Activity Page Tab Controllers
  late Rx<TabController> _activityTabController;
  late Rx<TabController> _tagsTabController;
  late Rx<TabController> _trendingTabController;
  TabController get activityTabController => _activityTabController.value;
  TabController get tagsTabController => _tagsTabController.value;
  TabController get trendingTabController => _trendingTabController.value;

// controllers
  SearchController sc = Get.find<SearchController>();
  @override
  void onInit() {
    _activityTabController =
        Rx<TabController>(TabController(length: 5, vsync: this));
    _tagsTabController =
        Rx<TabController>(TabController(length: 3, vsync: this));
    _trendingTabController =
        Rx<TabController>(TabController(length: 2, vsync: this));
    super.onInit();
  }

  @override
  void onReady() {
    activityTabController.addListener(() {});
    _focus.value.addListener(() {
      if (_focus.value.hasFocus) {
        sc.setIsSearchActive = true;
        _showRecent.value = false;
      } else {
        sc.setIsSearchActive = false;
      }
    });
  }

  //Functions

  void animateAllActivityControllersToTopOfPage() {
    animateControllerToStartOfPage(allActivityScrollController);
    animateControllerToStartOfPage(activityFollowScrollController);
    animateControllerToStartOfPage(activityLikesScrollController);
    animateControllerToStartOfPage(activityTaggedScrollController);
    animateControllerToStartOfPage(activityCommentScrollController);
  }

  void scrollHealthPageToTop() {
    if (_healthPageScrollController.value.hasClients) {
      _healthPageScrollController.value.animateTo(
          healthPageScrollController.position.minScrollExtent,
          duration: 500.milliseconds,
          curve: Curves.easeOut);
    }
  }

  void increaseSearchFieldFocus() {
    _haveFocus.value++;
    if (haveFocus > 1) {
      _showRecent.value = false;
      _focus.value.requestFocus();
    } else {
      _focus.value.unfocus();
    }
  }

  void resetSearchFieldFocus() {
    _haveFocus.value = 0;
    _showRecent.value = true;
  }

  void animateControllerToStartOfPage(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.animateTo(scrollController.position.minScrollExtent,
          duration: 250.milliseconds, curve: Curves.easeIn);
    }
  }

  void requestTextFieldFocus() {
    print("requesting focus");

    _focus.value.requestFocus();
  }
}
