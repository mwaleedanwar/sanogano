import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/helpers/scroll_focus_controller_helper.dart';
import 'package:sano_gano/controllers/postController.dart';
import 'package:sano_gano/utils/database.dart';

class ProfileBody extends StatelessWidget {
  final String uid;

  ProfileBody({Key? key, required this.uid}) : super(key: key);
  ScrollController _allTabController = ScrollController();
  ScrollController _mediaTabController = ScrollController();
  ScrollController _recipeTabController = ScrollController();
  ScrollController _workoutTabController = ScrollController();
  ScrollController _taggedTabController = ScrollController();
  PostController postController = Get.find<PostController>();
  Database db = Database();
  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();

  @override
  Widget build(BuildContext context) {
    String _myID = uid == Get.find<AuthController>().user!.uid
        ? Get.find<AuthController>().user!.uid
        : uid;

    return Column(
      children: <Widget>[
        SizedBox(
          height: 50,
          child: AppBar(
            elevation: 0.0,
            // backgroundColor: Colors.white,//TODO fix dark theme
            bottom: TabBar(
              onTap: (value) {
                animatePageToTop(value);
              },
              automaticIndicatorColorAdjustment: true,
              indicatorColor:
                  Get.isDarkMode == true ? Colors.white : Colors.black,
              labelPadding: EdgeInsets.symmetric(horizontal: 5),
              // labelColor: Colors.black,
              //indicatorColor: Colors.black,
              labelStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
              tabs: [
                Tab(
                  text: "All",
                ),
                Tab(
                  text: "Media",
                ),
                Tab(
                  text: "Recipe",
                ),
                Tab(
                  text: "Workout",
                ),
                Tab(
                  text: "Tagged",
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: TabBarView(
              physics: ClampingScrollPhysics(),
              children: [
                postController.getPaginatedPosts(
                    db.postsCollection
                        .where('ownerId', isEqualTo: _myID)
                        .orderBy('timestamp', descending: true),
                    scrollController: _allTabController),
                postController.getPaginatedPosts(
                  db.postsCollection
                      .where('ownerId', isEqualTo: _myID)
                      .where('hasMedia', isEqualTo: true)
                      // .orderBy('hasMedia',
                      //     descending: true)
                      .orderBy('timestamp', descending: true),
                  scrollController: _mediaTabController,
                ),
                postController.getPaginatedPosts(
                  db.postsCollection
                      .where('ownerId', isEqualTo: _myID)
                      .where('attachedRecipeId', isNotEqualTo: "")
                      .orderBy('attachedRecipeId', descending: true)
                      .orderBy('timestamp', descending: true),
                  scrollController: _recipeTabController,
                ),
                postController.getPaginatedPosts(
                  db.postsCollection
                      .where('ownerId', isEqualTo: _myID)
                      .where('attachedWorkoutId', isNotEqualTo: "")
                      .orderBy('attachedWorkoutId', descending: true)
                      .orderBy(
                        'timestamp',
                        descending: true,
                      ),
                  scrollController: _workoutTabController,
                ),
                postController.getPaginatedPosts(
                  db.postsCollection
                      .where('taggedUsers', arrayContains: _myID)
                      .orderBy('timestamp'),
                  scrollController: _taggedTabController,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void animatePageToTop(int index) {
    switch (index) {
      case 0:
        sfc.animateControllerToStartOfPage(_allTabController);
        break;
      case 1:
        sfc.animateControllerToStartOfPage(_mediaTabController);
        break;
      case 2:
        sfc.animateControllerToStartOfPage(_recipeTabController);
        break;
      case 3:
        sfc.animateControllerToStartOfPage(_workoutTabController);
        break;
      case 4:
        sfc.animateControllerToStartOfPage(_taggedTabController);
        break;

      default:
        sfc.animateControllerToStartOfPage(sfc.profilePageScrollController);
    }
  }
}
