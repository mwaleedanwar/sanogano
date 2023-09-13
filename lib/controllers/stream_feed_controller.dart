import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:stream_feed/stream_feed.dart' as sf;
import 'package:stream_feed/stream_feed.dart';

String kDefaultStreamApiKey = "g7auprpewf5u";

class StreamFeedController extends GetxController {
  final uc = Get.find<UserController>();
  var db = Database();
  final feedClient = sf.StreamFeedClient(
    kDefaultStreamApiKey,
    logLevel: sf.Level.SEVERE,
    appId: "1174967",
  );

  FlatFeed? personalFeed;
  FlatFeed? timelineFeed;
  FlatFeed? notificationFeed;
  FlatFeed? friendFeed;
  FlatFeed? trendingFeed;

  @override
  void onInit() {
    init();

    super.onInit();
  }

  // resetActivityCounter() {
  //   newactivitiesCount = 0;
  //   update();
  // }

  // var newactivitiesCount = 0;
  var loaded = false;
  PaginatedActivities<dynamic, dynamic, dynamic, dynamic>? paginated;
  initPagination() async {
    paginated = await timelineFeed!.getPaginatedEnrichedActivities(limit: 10);
  }

  Future<void> init() async {
    try {
      log("Initializing Feed Data");
      await feedClient.setUser(
          sf.User(
              id: uc.userModel.id,
              followersCount: uc.userModel.followers,
              followingCount: uc.userModel.following),
          Token(uc.userModel.feedToken!));

      personalFeed = feedClient.flatFeed("user", uc.currentUid);
      timelineFeed = feedClient.flatFeed("timeline", uc.currentUid);
      notificationFeed = feedClient.flatFeed("notifications", uc.currentUid);
      friendFeed = feedClient.flatFeed("friends", uc.currentUid);

      initPagination();

      // await timelineFeed!.subscribe((message) {
      //   log("firing timeline subscription event");
      //   if (message != null) {
      //     newactivitiesCount =
      //         newactivitiesCount + (message.newActivities?.length ?? 0);
      //     //  update();
      //   }
      // });

      if (!uc.userModel.feedInitializationComplete) {
        await timelineFeed!.follow(personalFeed!);
        await feedClient.flatFeed('grand').follow(personalFeed!);
        await uc.currentUserReference
            .update({'feedInitializationComplete': true});
      }
      loaded = true;
      update();
      log("initialization complete ${feedClient.currentUser?.id} connected");
      return;
    } catch (e) {
      printError(info: e.toString());
    }
  }

  FlatFeed getSomeonesPersonalFeed(String uid) {
    return feedClient.flatFeed("user", uid);
  }

  String? getIDLT(String raw) {
    log(raw);
    if (paginated!.next!.split("&").length < 2) return null;
    var str = paginated!.next!.split("&").toList()[1];

    return str.replaceAll("id_lt=", "");
  }

  Future<void> createPost(PostModel postModel) async {
    try {
      return await db.streamFeedActivities
          .doc(postModel.postId)
          .set(postModel.toMap());
    } catch (e) {
      return null;
    }
  }

  Future<void> deletePost(PostModel postModel) async {
    try {
      await db.streamFeedActivities.doc(postModel.postId).delete();
    } catch (e) {}
  }

  Future<void> followSomeone(String followedId) async {
    try {
      await timelineFeed?.follow(feedClient.flatFeed("user", followedId));
      log("successfulyy followed $followedId");
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> unFollowSomeone(String followedId) async {
    try {
      await timelineFeed?.unfollow(feedClient.flatFeed("user", followedId));
      print("successfully added activity");
    } catch (e) {}
  }

  // Future<void> increasePopularity(String postId) async {
  //   try {
  //     return await db.streamFeedActivities
  //         .doc(postId)
  //         .update({'popularity': FieldValue.increment(1)});
  //   } catch (e) {}
  // }

  // Future<void> decreasePopularity(String postId) async {
  //   try {
  //     return await db.streamFeedActivities
  //         .doc(postId)
  //         .update({'popularity': FieldValue.increment(-1)});

  //     // final set = {
  //     //   'popularity': postModel.popularity - 1,
  //     // };

  //     // await timelineFeed!
  //     //     .updateActivityById(id: postModel.postId, set: set, unset: []);
  //     // log("decrementing popularity");
  //   } catch (e) {}
  // }
}
