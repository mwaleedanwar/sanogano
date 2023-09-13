import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/leaderboard_controller.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/trending_hashtags.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/popular_posts.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/trending_recipes.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/trending_users.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/trending_workouts.dart';
import 'package:sano_gano/view/pages/activity/trending_screen.dart';
import 'package:sano_gano/view/widgets/user_menu_options.dart';

class LeaderBoardPage extends StatefulWidget {
  @override
  _LeaderBoardPageState createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  LeaderboardFilterOptions selectedMode = LeaderboardFilterOptions.ALL;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Container(
        color: Get.isDarkMode ? Colors.black : Colors.white,
        child: Scaffold(
          appBar: CustomAppBar(
            back: true,
            title: "Leaderboard",
          ),
          body: GetX<LeaderBoardController>(
              init: LeaderBoardController(),
              builder: (controller) {
                return Column(
                  children: [
                    PreferredSize(
                      preferredSize: Size.fromHeight(30.0),
                      child: Container(
                        color: Get.isDarkMode ? Colors.black : Colors.white,
                        child: TabBar(
                          isScrollable: false,
                          labelPadding: EdgeInsets.zero,
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                          indicatorColor:
                              Get.isDarkMode ? Colors.white : Colors.black,
                          unselectedLabelStyle: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 12),
                          labelColor:
                              Get.isDarkMode ? Colors.white : Colors.black,
                          padding: EdgeInsets.zero,
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
                              text: "Posts",
                            ),
                            Tab(
                              height: 30,
                              text: "Recipes",
                            ),
                            Tab(
                              height: 30,
                              text: "Workouts",
                            ),
                          ],
                        ),
                      ),
                    ),
                    !controller.isLoading
                        ? Expanded(
                            child: TabBarView(children: [
                              TrendingUsers(),
                              TrendingHashtags(),
                              PopularPost(),
                              TrendingRecipes(),
                              TrendingWorkouts(),
                            ]),
                          )
                        : Center(
                            child: SpinKitRotatingCircle(
                              color: Colors.black,
                              size: 50.0,
                            ),
                          )
                  ],
                );
              }),
        ),
      ),
    );
  }
}





//* removed code
// selectedMode == LeaderboardFilterOptions.ALL
//                         ? 
  // : FutureBuilder<FriendListResponse>(
  //                           future: FollowDatabase().getFriendList(id),
  //                           builder: (context, snapshot) {
  //                             if (!snapshot.hasData)
  //                               return Center(
  //                                 child: CircularProgressIndicator(),
  //                               );

  //                             var filtered = usersList
  //                                 .where((element) => snapshot.data!.friends
  //                                     .contains(element!.id))
  //                                 .toList();
  //                             filtered.add(_myUser);
  //                             filtered.sort((a, b) =>
  //                                 b!.followers!.compareTo(a!.followers!));

  //                             var myindex = filtered.indexWhere(
  //                                 (element) => element!.id == _myUser!.id);
  //                             return Stack(
  //                               children: [
  //                                 Positioned.fill(
  //                                   top: 1,
  //                                   left: 3,
  //                                   right: 3,
  //                                   bottom: Get.height * 0.06,
  //                                   child: ListView.builder(
  //                                       shrinkWrap: false,
  //                                       itemCount: filtered.length * 2,
  //                                       itemBuilder: (_, index) {
  //                                         UserModel _user = filtered[0]!;

  //                                         if (_index < 10) {
  //                                           return _buildUserTile(
  //                                               _user, index + 1);
  //                                         } else {
  //                                           return _user.id != id
  //                                               ? _buildUserTile(
  //                                                   _user, index + 1)
  //                                               : Container();
  //                                         }
  //                                       }),
  //                                 ),
  //                                 Positioned(
  //                                     bottom: 5,
  //                                     left: 0,
  //                                     right: 0,
  //                                     child: Container(
  //                                         margin:
  //                                             EdgeInsets.fromLTRB(3, 0, 3, 3),
  //                                         decoration: BoxDecoration(
  //                                           border: Border.all(
  //                                               color: standardContrastColor,
  //                                               width: 1),
  //                                         ),
  //                                         child: _buildMyTile(
  //                                             _myUser ?? UserModel(),
  //                                             myindex + 1)))
  //                               ],
  //                             );
  //                           })
  ///app bar
  ///
  ///      // iconButton: buildFilterOptions(
              //   icon: filterIcon,
              //   onSelectCallback: (result) {
              //     if (result != null) {
              //       selectedMode = result;
              //     }
              //     print(result);
              //     setState(() {});
              //   },
              // ),
// CustomAppBar(
            //   back: true,
            //   title: "LeaderBoard",
            //   iconButton: InkWell(
            //     onTap: () {},
            //     child: Padding(
            //       padding: const EdgeInsets.all(15.0),
            //       child: CustomIcon("assets/icons/filter.svg", 20),
            //     ),
            //   ),

            // )