import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/activity_controller.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/helpers/scroll_focus_controller_helper.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/view/pages/activity/activity.dart';
import 'package:sano_gano/view/pages/health/health.dart';
import 'package:sano_gano/view/pages/home/home.dart';
import 'package:sano_gano/view/pages/profile/profile.dart';
import 'package:sano_gano/view/pages/search/search.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

class RootPage extends StatefulWidget {
  static String id = 'home';
  final bool isNewUser;

  const RootPage({Key? key, this.isNewUser = false}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  String? profileURL;
  var scrollController = ScrollController();
  var uc = Get.find<UserController>();

  int _currentIndex = 0;

  List<Widget> tabs = [];
  PageController? _pageController;

  @override
  void initState() {
    getUserData();
    Get.put(ActivityController());
    if (widget.isNewUser) {
      _currentIndex = 0;
    }
    _pageController = PageController(initialPage: _currentIndex);
    tabs = [
      HomePage(
        scrollController: scrollController,
      ),
      SearchPage(),
      HealthPage(),
      ActivityPage(),
      ProfilePage(
        userID: Get.find<AuthController>().user!.uid,
        healthCallback: () {
          _onItemTapped(2);
        },
        hideBack: true,
      ),
    ];
    super.initState();
  }

  void getUserData() async {
    var id = Get.find<AuthController>().user!.uid;
    var controller = Get.find<UserController>();
    var cUser = await UserDatabase().getUserNullable(id);
    if (cUser == null) return;
    controller.userModel = cUser;
    if (controller.userModel.profileURL != null) {
      setState(() {
        profileURL = controller.userModel.profileURL;
      });
    }
  }

  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();

  @override
  Widget build(BuildContext context) {
    Widget _buildSVG(Widget icon, double _opacity) {
      return Opacity(
        opacity: _opacity,
        child: icon,
      );
    }

    return Material(
      child: mainBody(_buildSVG),
    );
  }

  Widget mainBody(Widget _buildSVG(Widget icon, double _opacity)) {
    return GetBuilder<TimelineController>(
        init: TimelineController(),
        builder: (controller) => Scaffold(
              body: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: tabs,
              ),
              bottomNavigationBar: BottomNavigationBar(
                elevation: 16,
                enableFeedback: true,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                selectedFontSize: 0,
                selectedIconTheme: IconThemeData(
                  opacity: 1,
                ),
                unselectedIconTheme: IconThemeData(
                  opacity: 0.0,
                ),
                fixedColor: Colors.black,
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                items: [
                  BottomNavigationBarItem(
                    tooltip: "",
                    icon: _buildSVG(homeIcon.copyWith(size: 23),
                        _currentIndex == 0 ? 1 : 0.5),
                    label: "",
                    backgroundColor: Colors.white,
                  ),
                  BottomNavigationBarItem(
                    tooltip: "",
                    icon: _buildSVG(searchTabIcon.copyWith(size: 23),
                        _currentIndex == 1 ? 1 : 0.5),
                    label: "",
                    backgroundColor: Colors.white,
                  ),
                  BottomNavigationBarItem(
                    tooltip: "",
                    icon: _buildSVG(lifeIcon.copyWith(size: 23),
                        _currentIndex == 2 ? 1 : 0.5),
                    label: "",
                    backgroundColor: Colors.white,
                  ),
                  BottomNavigationBarItem(
                    tooltip: "",
                    icon: _buildSVG(activityDIcon.copyWith(size: 23),
                        _currentIndex == 3 ? 1 : 0.5),
                    label: "",
                    backgroundColor: Colors.white,
                  ),
                  BottomNavigationBarItem(
                    tooltip: "",
                    icon: Opacity(
                      opacity: _currentIndex == 4 ? 1 : 0.5,
                      child: AbsorbPointer(
                        absorbing: true,
                        child: UserAvatar(
                          Get.find<AuthController>().user!.uid,
                          isdisabledTap: true,
                          radius: 14,
                        ),
                      ),
                    ),
                    label: "",
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ));
  }

  void _onItemTapped(index) {
    if (_currentIndex == 0 && index == 0) {
      scrollController.animateTo(0.0,
          duration: 500.milliseconds, curve: Curves.ease);
    } else {
      setState(() {
        _currentIndex = index;
        _pageController!.jumpToPage(index);
      });
    }
    switch (index) {
      case 0:
        sfc.resetSearchFieldFocus();

        break;
      case 1:
        sfc.increaseSearchFieldFocus();

        break;

      case 2:
        sfc.resetSearchFieldFocus();
        sfc.scrollHealthPageToTop();
        break;
      case 3:
        sfc.resetSearchFieldFocus();
        sfc.animateAllActivityControllersToTopOfPage();
        break;
      case 4:
        sfc.resetSearchFieldFocus();
        if (sfc.profilePageScrollController.hasClients)
          sfc.profilePageScrollController.animateTo(
              sfc.profilePageScrollController.initialScrollOffset,
              duration: 200.milliseconds,
              curve: Curves.easeIn);
        break;
      default:
    }
  }
}
