import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:sano_gano/controllers/search_controller.dart';
import 'package:sano_gano/view/pages/search/recent_searches.dart';
import 'package:sano_gano/view/pages/search/recipe_search_screen.dart';
import 'package:sano_gano/view/pages/search/workout_search_screen.dart';

import '../../../controllers/helpers/scroll_focus_controller_helper.dart';
import 'build_user_search.dart';
import 'hashtags_search_screen.dart';

class SearchScreenBody extends StatelessWidget {
  SearchScreenBody({super.key});
  SearchController sc = Get.find<SearchController>();
  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();
  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: [
        GestureType.onTap,
        GestureType.onPanUpdateAnyDirection,
      ],
      child: Obx(() {
        return Scaffold(
          appBar: sfc.showRecent
              ? null
              : AppBar(
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  leadingWidth: 0,
                  titleSpacing: 0,
                  title: TabBar(
                      onTap: (activeScreen) {
                        sc.clearSearchField();
                        sc.setCurrentScreen = activeScreen;
                      },
                      labelPadding: EdgeInsets.zero,
                      labelStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      indicatorColor:
                          Get.isDarkMode ? Colors.white : Colors.black,
                      unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 12),
                      labelColor: Get.isDarkMode ? Colors.white : Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      isScrollable: false,
                      tabs: [
                        Tab(
                          height: 30,
                          text: "Accounts",
                        ),
                        Tab(
                          height: 30,
                          text: "Hashtags",
                        ),
                        Tab(
                          height: 30,
                          text: "Recipes",
                        ),
                        Tab(
                          height: 30,
                          text: "Workouts",
                        ),
                      ]),
                ),
          body: sfc.showRecent
              ? RecentSearches()
              : TabBarView(children: [
                  AccountsSearchScreen(),
                  HashTagsSearchScreen(),
                  RecipeSearchScreen(),
                  WorkoutSearchScreen(),
                ]),
        );
      }),
    );
  }
}
