import 'dart:async';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/const/theme.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/stream_feed_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/services/notificationService.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/pages/chat/chat_page.dart';
import 'package:sano_gano/view/pages/home/image_test.dart';
import 'package:sano_gano/view/pages/home/pagination_widget.dart';
import 'package:sano_gano/view/widgets/create_post.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_feed/stream_feed.dart';
import 'package:badges/badges.dart' as badges;

import '../chat/chat_home_page.dart';

class HomePage extends StatefulWidget {
  final ScrollController scrollController;

  HomePage({Key? key, required this.scrollController}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  var scroll = ScrollController();
  var db = Database();
  int? page;
  final _box = GetStorage();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    page = -1;

    scroll = widget.scrollController;
  }

  var cuid = Get.find<AuthController>().user!.uid;
  var controller = Get.find<UserController>();
  TabController? _tabController;
  var stackIndex = 0;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildHomePageUI();
  }

  var newactivitiesCount = 0;
  Widget buildHomePageUI() {
    return GetBuilder<StreamFeedController>(
      init: StreamFeedController(),
      initState: (_) {
        if (sc.loaded) {
          sc.paginated = null;
          sc.initPagination();
        }
      },
      autoRemove: false,
      builder: (feedController) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: createPostIcon,
              onPressed: () async {
                var res = await Get.to<bool>(() => CreatePost());
                if (res ?? false) reloader = 1;
                feedController.update();
              },
            ),
            title: GestureDetector(
              onTap: () {
                scroll.animateTo(0.0,
                    duration: 500.milliseconds, curve: Curves.easeIn);
              },
              child: Image.asset(
                "assets/images/logo.png",
                width: Get.width * 0.30,
                height: 34.6,
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: Get.width * 0.02),
                child: StreamBuilder<int>(
                    stream: StreamChat.of(context)
                        .client
                        .state
                        .unreadChannelsStream,
                    builder: (context, snapshot) {
                      return InkWell(
                        onTap: () {
                          Get.to(() => ChatHomePage());
                        },
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: badges.Badge(
                            elevation: 0,
                            badgeColor: Colors.transparent,
                            // Get.isDarkMode ? Colors.black : Colors.white,
                            padding: EdgeInsets.all(3),
                            position: BadgePosition.center(),
                            showBadge: snapshot.hasData && snapshot.data != 0,
                            badgeContent: snapshot.hasData && snapshot.data != 0
                                ? Text(
                                    snapshot.data! > 99
                                        ? "99+"
                                        : snapshot.data.toString(),
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  )
                                : null,
                            child: messangerIcon,
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(
                width: Get.width * 0.02,
              ),
            ],
            centerTitle: true,
          ),
          body: (uc.auth.isNew)
              ? Container()
              : !sc.loaded
                  ? Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : buildTimeline(),
        );
      },
    );
  }

  var reloader = 0;
  var uc = Get.find<UserController>();
  var sc = Get.put(StreamFeedController());
  Widget buildTimeline() {
    return PaginatedTimeline(
      scrollController: widget.scrollController,
    );
  }

  List<PostModel> allPosts = [];
  DocumentSnapshot<Object?>? lastDoc;
  Future<List<PostModel>> pageFetch(int offset) async {
    List<PostModel> posts = [];
    // if (sc.getIDLT(sc.paginated!.next!) == null) return [];
    var p = await sc.timelineFeed!.getPaginatedEnrichedActivities(
      limit: 50, ranking: 'time', offset: offset,
      flags: EnrichmentFlags().withRecentReactions().withReactionCounts(),

      // filter: Filter().idLessThan(sc.getIDLT(sc.paginated!.next!)!),
    );
    sc.paginated = p;

    posts = p.results!
        .map((e) => PostModel.fromActivity(activityEnriched: e))
        .toList();

    allPosts = posts;
    return posts;
  }

  List<PostModel> getCachedPosts() {
    var v = _box.read(Get.find<AuthController>().user!.uid);
    if (v == null) {
      print("cached items are null");

      return [];
    }
    print("getting cached items");
    var list = v as List;
    print(list.length);
    return list.map((e) => PostModel.fromMap(e)).toList();
  }
}

class TimelineController extends GetxController {
  ScrollController scrollController = ScrollController();
}

class NewActivityIndicator extends StatefulWidget {
  final VoidCallback postTapCallback;

  const NewActivityIndicator({
    Key? key,
    required this.postTapCallback,
  }) : super(key: key);

  @override
  State<NewActivityIndicator> createState() => _NewActivityIndicatorState();
}

class _NewActivityIndicatorState extends State<NewActivityIndicator> {
  var sc = Get.find<StreamFeedController>();
  var newactivitiesCount = 0;
  resetActivityCounter() {
    newactivitiesCount = 0;
    sc.update();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // sc.timelineFeed!.subscribe((message) {
  //   //   log("firing timeline subscription event");
  //   //   if (message != null) {
  //   //     newactivitiesCount =
  //   //         newactivitiesCount + (message.newActivities?.length ?? 0);
  //   //     setState(() {});
  //   //   }
  //   // });
  // }

  @override
  Widget build(BuildContext context) {
    if (newactivitiesCount <= 0) return Container();
    return InkWell(
      onTap: () {
        resetActivityCounter();
        widget.postTapCallback();
      },
      child: Container(
        height: 30,
        color: messageColor,
        child: Center(
          child: Text(
            "$newactivitiesCount new posts",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
