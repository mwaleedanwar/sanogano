import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/pages/follow/follow.dart';
import 'package:sano_gano/view/widgets/cookbook_page.dart';
import 'package:sano_gano/view/widgets/gym_page.dart';
import 'package:sano_gano/view/widgets/saved_posts.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

bool isGymMode = false;

class ProfileImage extends StatelessWidget {
  String profileURL;
  String id;
  String username;
  String name;
  int following;
  int follower;
  Function? healthCallback;
  ProfileImage(this.profileURL, this.id, this.username, this.follower,
      this.following, this.name,
      {this.healthCallback});

  @override
  Widget build(BuildContext context) {
    Widget _buildIcon(Widget icon, String text) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          addHeight(2.5),
          Text(
            text,
            style: TextStyle(fontSize: 10),
          ),
        ],
      );
    }

    Widget _buildFollow(int value, String text) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FollowerTextWidget(
            uid: id,
            numberOnly: true,
            style: TextStyle(fontWeight: FontWeight.bold),
            streamMode: true,
          ),
          addHeight(2.5),
          Text(
            text,
            style: TextStyle(fontSize: 10),
          ),
        ],
      );
    }

    Widget _buildFollowing(int value, String text) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FollowingTextWidget(
              uid: id,
              numberOnly: true,
              style: TextStyle(fontWeight: FontWeight.bold)),
          addHeight(2.5),
          Text(
            text,
            style: TextStyle(fontSize: 10),
          ),
        ],
      );
    }

    return Container(
      width: 230,
      height: 225,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              top: 1,
              child: UserAvatar(
                id,
                isdisabledTap: true,
                radius: 50,
              )
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(50),
              //   child: Container(
              //     width: 100,
              //     height: 100,
              //     decoration: BoxDecoration(color: Colors.grey),
              //     child: profileURL == null
              //         ? CircleAvatar(
              //             backgroundColor: globalColor,
              //             child: Text(
              //               name[0].toUpperCase(),
              //               style: TextStyle(fontSize: 36, color: Colors.white),
              //             ),
              //           )
              //         : OptimizedCacheImage(
              //             imageUrl: profileURL,
              //             placeholder: (context, url) =>
              //                 CircularProgressIndicator(),
              //             errorWidget: (context, url, error) => Icon(Icons.error),
              //           ),
              //   ),
              // ),
              ),
          Positioned(
              top: 60,
              left: 10,
              child: InkWell(
                  onTap: () {
                    onTap(0);
                  },
                  child: _buildFollow(follower, "Followers"))),
          Positioned(
              top: 60,
              right: 10,
              child: InkWell(
                  onTap: () {
                    onTap(1);
                  },
                  child: _buildFollowing(following, "Following"))),
          Positioned(
              top: 105,
              right: 25,
              child: InkWell(
                  onTap: () {
                    if (healthCallback != null) {
                      healthCallback!();
                      isGymMode = true;
                    } else {
                      Get.to(GymPage(
                        username: username,
                        uid: id,
                      ));
                    }
                  },
                  child: _buildIcon(seeGymDIcon, "Gym"))),
          Positioned(
              top: 105,
              left: 25,
              child: Container(
                //color: Colors.red,
                child: InkWell(
                    onTap: () => healthCallback != null
                        ? healthCallback!()
                        : Get.to(CookbookPage(
                            username: username,
                            uid: id,
                          )),
                    child: _buildIcon(seeCookbookDIcon, "Cookbook")),
              )),
          Positioned(
            top: 65,
            bottom: 0,
            child: Container(
              //color: Colors.red,
              child: SizedBox.square(
                child: GestureDetector(
                    onTap: () => Get.to(() => SavedPosts(
                          uid: id,
                        )),
                    child: _buildIcon(seeSavedDIcon, "Saved")),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onTap(int index) {
    Get.to(() => FollowPage(
          id,
          username,
          tabNumber: index,
        ));
    // Get.find<FollowController>().following.clear();
    // Get.find<FollowController>().followers.clear();
  }
}
