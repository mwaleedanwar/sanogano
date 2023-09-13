import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/services/follow_database.dart';
import 'package:sano_gano/utils/database.dart';

class SuggestionsController extends GetxController {
  UserController uc = Get.find<UserController>();
  AuthController ac = Get.find<AuthController>();
  Database db = Database();
  FollowDatabase followDatabase = FollowDatabase();
  Rx<List<String>?> _mutualFriendsSuggestions = Rx<List<String>?>([]);
  List<String>? get mutualFriendsSuggestions => _mutualFriendsSuggestions.value;

  RxBool _loading = true.obs;
  bool get loading => _loading.value;

  Future<List<String>?> getMutualFriendsSuggestions() async {
    _loading.value = true;
    try {
      FriendListResponse currentUserResponse =
          await followDatabase.getFriendList(ac.user!.uid);
      List<String> currentUserFriends = currentUserResponse.friends;
      List<String> currentUserFollowers = currentUserResponse.followers;
      List<String> currentUserFollowing = currentUserResponse.following;
      List<String> mutualFriendsToReturn = [];

      for (String friend in currentUserFriends) {
        List<String> friendFollowers =
            (await followDatabase.getFollowerList(friend));
        List<String> friendFollowing =
            (await followDatabase.getFollowingList(friend));
        //* if friend and current user have same follower, add to mutual friends
        for (String follower in friendFollowers) {
          // if (currentUserFollowing.contains(follower)) {
          mutualFriendsToReturn.add(follower);
          // }
        }
        //* if friend and current user have same following, add to mutual friends
        for (String following in friendFollowing) {
          // if (currentUserFollowers.contains(following)) {
          mutualFriendsToReturn.add(following);
          // }
        }
      }

      //* remove duplicates
      mutualFriendsToReturn = mutualFriendsToReturn.toSet().toList();
      //* remove current user's friends [that are already friends]
      for (var friend in currentUserFriends) {
        print(friend);
        mutualFriendsToReturn.remove(friend);
      }
      for (var friend in currentUserFollowers) {
        mutualFriendsToReturn.remove(friend);
      }
      for (var friend in currentUserFollowing) {
        mutualFriendsToReturn.remove(friend);
      }
      if (mutualFriendsToReturn.contains(ac.user!.uid)) {
        mutualFriendsToReturn.remove(ac.user!.uid);
      }
      _mutualFriendsSuggestions.value = mutualFriendsToReturn;
      _loading.value = false;
      return mutualFriendsToReturn;
    } on Exception catch (e) {
      print(e);
      _loading.value = false;
      return [];
    }
  }

  @override
  void onInit() {
    getMutualFriendsSuggestions();
    super.onInit();
  }
}
