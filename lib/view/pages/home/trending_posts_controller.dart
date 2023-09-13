import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:stream_feed/stream_feed.dart';

import '../../../controllers/auth_controller.dart';
import '../../../models/postmodel.dart';
import '../../../utils/local_database.dart';

class TrendingPostsController extends GetxController {
  final FlatFeed feed;
  final Filter? feedFilter;
  final String? ranking;
  final bool Function(PostModel)? restrictLoadIfTrue;

  TrendingPostsController(
      {required this.feed,
      this.ranking,
      this.feedFilter,
      this.restrictLoadIfTrue});

  Rx<List<PostModel>?> _allPosts = Rx<List<PostModel>?>([]);
  List<PostModel>? get allPosts => _allPosts.value;
  set setPosts(List<PostModel>? value) => _allPosts.value = value;

  RxInt _postCount = 0.obs;
  int get postCount => _postCount.value;
  RxBool _loadingFirstTime = true.obs;
  bool get loadingFirstTime => _loadingFirstTime.value;
  RxBool _shouldLoadMore = false.obs;
  bool get shouldLoadMore => _shouldLoadMore.value;
  RxInt _count = 1.obs;
  int get count => _count.value;

  UserController uc = Get.find<UserController>();
  Rx<ScrollController> _scrollController = ScrollController().obs;
  ScrollController get scrollController => _scrollController.value;
  Future<void> getNewsFeed() async {
    try {
      var activities = (await feed.getPaginatedEnrichedActivities(
        limit: 20,
        offset: 0,
        ranking: ranking ?? 'time',
        flags: EnrichmentFlags().withRecentReactions().withReactionCounts(),
        filter: feedFilter,
      ))
          .results!;

      print(activities.map((e) => e.score));
      setPosts = activities
          .map((e) => PostModel.fromActivity(activityEnriched: e))
          .toList();
      await LocalDatabase().addToPostCache(
          allPosts!.map((e) => e.postId).toList(),
          Get.find<AuthController>().user!.uid);
      _postCount.value = allPosts!.length;
      if (restrictLoadIfTrue != null) {
        log('restricting posts');
        _allPosts.value!.removeWhere(
          (element) => restrictLoadIfTrue!(element),
        );
      }

      if (allPosts!.isEmpty) return;
      handleFurtherLoading(allPosts!.last);
    } catch (e) {
      throw e;
    } finally {
      _loadingFirstTime = false.obs;
    }
  }

  void handleFurtherLoading(PostModel lastPost) {
    if (restrictLoadIfTrue != null) {
      if (restrictLoadIfTrue!(lastPost)) {
        _shouldLoadMore = false.obs;
      } else {
        _shouldLoadMore = true.obs;
      }
    }
  }

  @override
  void onInit() {
    feed.subscribe((message) {
      var newPersonal = message!.newActivities!.firstWhere((element) =>
          PostModel.fromActivity(activityEnriched: element).ownerId ==
          uc.currentUid);
      _allPosts.value!
          .insert(0, PostModel.fromActivity(activityEnriched: newPersonal));
    });
    scrollController.addListener(() async {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        try {
          print('loading more');
          if (shouldLoadMore == false) return;
          _count.value = count + 1;
          List<PostModel> posts = [];
          // if (sc.getIDLT(sc.paginated!.next!) == null) return [];
          var p = await feed.getPaginatedEnrichedActivities(
            limit: 20,
            ranking: ranking ?? 'time',
            offset: postCount,
            flags: EnrichmentFlags().withRecentReactions().withReactionCounts(),
            filter: feedFilter,
          );

          posts = p.results!
              .map((e) => PostModel.fromActivity(activityEnriched: e))
              .toList();
          _allPosts.value!.addAll(posts);
          _postCount.value = allPosts!.length;
          if (restrictLoadIfTrue != null) {
            _allPosts.value!.removeWhere(
              (element) => restrictLoadIfTrue!(element),
            );
          }
          handleFurtherLoading(posts.last);
        } catch (e) {
          print(e);
        }
        //at bottom
      }
      if (scrollController.offset <=
              scrollController.position.minScrollExtent &&
          !scrollController.position.outOfRange) {
        //at top
      }
    });

    super.onInit();
  }

  Future<void> onRefresh() async {
    try {
      _shouldLoadMore = true.obs;
      _scrollController.value.animateTo(0,
          duration: Duration(milliseconds: 250), curve: Curves.linear);
      _allPosts.value = [];
      await getNewsFeed();
      return;
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> onReady() async {
    await getNewsFeed();
    super.onReady();
  }
}
