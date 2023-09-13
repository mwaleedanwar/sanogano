import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/helpers/scroll_focus_controller_helper.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:stream_feed/stream_feed.dart';

import '../../../controllers/stream_feed_controller.dart';
import '../home/any_feed_pagination.dart';

class TrendingPosts extends StatefulWidget {
  const TrendingPosts({Key? key}) : super(key: key);

  @override
  _TrendingPostsState createState() => _TrendingPostsState();
}

class _TrendingPostsState extends State<TrendingPosts> {
  var sc = Get.find<StreamFeedController>();
  FlatFeed get trendingFeed => sc.feedClient.flatFeed("grand");
  var friendList = <String>[];
  var uc = Get.find<UserController>();
  ScrollAndFocusControllerHelper sffc =
      Get.find<ScrollAndFocusControllerHelper>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
        centerTitle: true,
        title: "Trending",
      ),
      body: AnyFeedPagination(
        feed: sc.feedClient.flatFeed('grand', 'US'),
        ranking: 'popularity',
        restrictLoadIfTrue: (lastPost) {
          return false;
          // if (lastPost.timestamp == null) return false;
          // return lastPost.timestamp!.isBefore(DateTime.now().subtract(1.days));
        },
      ),
      // Column(
      //   children: [
      //     // PreferredSize(
      //     //   preferredSize: Size(Get.width, 30),
      //     //   child: TabBar(
      //     //     controller: sffc.trendingTabController,
      //     //     isScrollable: false,
      //     //     labelPadding: EdgeInsets.zero,
      //     //     labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      //     //     indicatorColor: Get.isDarkMode ? Colors.white : Colors.black,
      //     //     unselectedLabelStyle:
      //     //         TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
      //     //     labelColor: Get.isDarkMode ? Colors.white : Colors.black,
      //     //     padding: EdgeInsets.zero,
      //     //     tabs: [
      //     //       Tab(
      //     //         text: "All",
      //     //       ),
      //     //       Tab(
      //     //         text: "Friends",
      //     //       ),
      //     //     ],
      //     //   ),
      //     // ),
      //     AnyFeedPagination(
      //       feed: sc.feedClient.flatFeed('grand', 'US'),
      //       ranking: 'popularity',
      //       restrictLoadIfTrue: (lastPost) {
      //         if (lastPost.timestamp == null) return false;
      //         return lastPost.timestamp!
      //             .isBefore(DateTime.now().subtract(1.days));
      //       },
      //     ),
      //     // Expanded(
      //     //     child: TabBarView(
      //     //   controller: sffc.trendingTabController,
      //     //   children: [
      //     //     AnyFeedPagination(
      //     //       feed: sc.feedClient.flatFeed('grand', 'US'),
      //     //       ranking: 'popularity',
      //     //       restrictLoadIfTrue: (lastPost) {
      //     //         if (lastPost.timestamp == null) return false;
      //     //         return lastPost.timestamp!
      //     //             .isBefore(DateTime.now().subtract(1.days));
      //     //       },
      //     //     ),
      //     //     AnyFeedPagination(
      //     //       feed: sc.friendFeed!,
      //     //       ranking: 'popularity',
      //     //       restrictLoadIfTrue: (lastPost) {
      //     //         if (lastPost.timestamp == null) return false;
      //     //         return lastPost.timestamp!
      //     //             .isBefore(DateTime.now().subtract(1.days));
      //     //       },
      //     //       // feedFilter: ,
      //     //     ),
      //     //   ],
      //     // ))
      //   ],
      // ),
    );
  }
}

// * junk code

// var db = Database();
//   var today = DateTime.now().subtract(1.days).add(1.hours);

//   var sortMode = LeaderboardFilterOptions.ALL;
//   sort(LeaderboardFilterOptions _sortMode) {
//     sortMode = _sortMode;
//     setState(() {});
//   }

//   Query get query {
//     switch (sortMode) {
//       case LeaderboardFilterOptions.ALL:
//         log("All query");
//         return db.postsCollection
//             .where('timestamp',
//                 isGreaterThan: DateTime.now().millisecondsSinceEpoch)
//             // .orderBy('timestamp', descending: true);
//             .orderBy('likeCount', descending: true);

//       case LeaderboardFilterOptions.FRIENDS:
//         log("FRIENDS ");

//         return db.postsCollection
//             .where('timestamp',
//                 isGreaterThanOrEqualTo: today.millisecondsSinceEpoch)
//             .orderBy('likeCount', descending: true);
//       // .orderBy(
//       //   'timestamp',
//       // );
//       //  .orderBy('likeCount', descending: true);

//       default:
//         log("default ");

//         return db.postsCollection
//             .where('timestamp',
//                 isGreaterThanOrEqualTo: today.millisecondsSinceEpoch)
//             // .orderBy('timestamp', descending: true)
//             .orderBy('likeCount', descending: true);
//     }
//   }
// body: GetBuilder<PostController>(
//   init: PostController(),
//   initState: (_) {},
//   builder: (controller) {
//     return Container(
//       child: StreamBuilder(
//           stream: Stream.value(sortMode),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState != ConnectionState.done) {
//               return Center(
//                 child: CircularProgressIndicator.adaptive(),
//               );
//             }
//             if (sortMode == LeaderboardFilterOptions.FRIENDS)
//               return AnyFeedPagination(
//                 feed: sc.friendFeed!,
//                 ranking: 'popularity',
//               );

//             return AnyFeedPagination(
//               feed: sc.feedClient.flatFeed('grand', 'US'),
//               ranking: 'popularity',
//             );
//           }),
//     );
//   },
// ),

//  AppBar(
//   leading: backIcon,
//   centerTitle: true,
//   title: Center(
//     child: Text(
//       "Trending ${sortMode == LeaderboardFilterOptions.FRIENDS ? "Among Friends" : ''}",
//       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//     ),
//   ),
//   elevation: 0,
//   actions: [
//     PopupMenuButton<LeaderboardFilterOptions>(
//       icon: filterDIcon.copyWith(size: 23),
//       onSelected: (value) => sort(value),
//       itemBuilder: (context) => [
//         PopupMenuItem<LeaderboardFilterOptions>(
//           value: LeaderboardFilterOptions.ALL,
//           child: Text("All"),
//         ),
//         PopupMenuItem<LeaderboardFilterOptions>(
//           value: LeaderboardFilterOptions.FRIENDS,
//           child: Text("Friends"),
//         ),
//       ],
//     ),
//   ],
// ),
// appBar: CustomAppBar(
//   back: true,
//   title: "Trending",
//
// ),

// iconButton: PopupMenuButton<LeaderboardFilterOptions>(
//   icon: filterDIcon.copyWith(size: 23),
//   onSelected: (value) => sort(value),
//   itemBuilder: (context) => [
//     PopupMenuItem<LeaderboardFilterOptions>(
//       value: LeaderboardFilterOptions.ALL,
//       child: Text("All"),
//     ),
//     PopupMenuItem<LeaderboardFilterOptions>(
//       value: LeaderboardFilterOptions.FRIENDS,
//       child: Text("Friends"),
//     ),
//   ],
// ),

//   PaginatedActivities<dynamic, dynamic, dynamic, dynamic>? paginated;

//   var sc = Get.find<StreamFeedController>();

//   List<PostModel> allPosts = [];
//   DocumentSnapshot<Object?>? lastDoc;
//   Future<List<PostModel>> pageFetch(int offset) async {
//     try {
//       List<PostModel> posts = [];
//       var p = await trendingFeed.getPaginatedEnrichedActivities(
//         limit: 10,
//         ranking: 'popularity',
//         offset: offset,
//       );
//       paginated = p;

//       posts = p.results!
//           .map((e) => PostModel.fromActivity(activityEnriched: e))
//           .toList();
//       // print(offset);
//       // page = (offset / 10).round();
//       // QuerySnapshot<Object?> docs;
//       // if (page == 0) {
//       //   docs = await db
//       //       .timelinesCollection(cuid)
//       //       .orderBy('timestamp', descending: true)
//       //       .limit(10)
//       //       .get();
//       //   if (docs.docs.isEmpty) return [];
//       //   lastDoc = docs.docs.last;
//       //   if (docs.docs.isEmpty) return [];
//       // } else {
//       //   docs = await db
//       //       .timelinesCollection(cuid)
//       //       .orderBy('timestamp', descending: true)
//       //       .startAfterDocument(lastDoc!)
//       //       .limit(10)
//       //       .get();
//       //   lastDoc = docs.docs.last;
//       // }
//       // posts = await db.getAllPostsFromIDs(docs.docs.map((e) => e.id).toList());
//       // allPosts.addAll(posts);
//       // uc.postCache = allPosts;
//       // // if (page == 0) {
//       // //   if (posts.isNotEmpty) {
//       // //     await _box.write('postCache', posts.map((e) => e.toMap()).toList());
//       // //   }
//       // // }
//       log(p.results!.map((e) => e.score).toList().toString());
//       if (friendList.isNotEmpty ||
//           sortMode == LeaderboardFilterOptions.FRIENDS) {
//         return posts
//             .where((element) => friendList.contains(element.ownerId))
//             .toList();
//       }
//       return posts;
//     } catch (e) {
//       log(e.toString());
//       return [];
//     }
//   }

//   List<DocumentSnapshot<Object?>> alldocs = [];
//   List<PostModel> sortPosts() {
//     List<PostModel> posts = [];
//     for (var doc in alldocs) {
//       posts.add(PostModel.fromMap(doc.data() as Map<String, dynamic>));
//     }
//     posts.sort((a, b) {
//       return b.likeCount!.compareTo(a.likeCount!);
//     });
//     return posts;
//   }

//   Widget getPaginatedPosts(Query query,
//       {Widget Function(BuildContext, List<DocumentSnapshot<Object?>>, int)?
//           optionalChildBuilder,
//       Key? key,
//       bool isGrid = false,
//       bool showEmpty = false,
//       List<String> filterOutList = const [],
//       ScrollController? scrollController}) {
//     // print("filter out list inside pagination");
//     // print(filterOutList);
//     return PaginateFirestore(
//       key: key,
//       physics: ClampingScrollPhysics(),
//       onEmpty: Container(),
//       // showEmpty
//       //     ? Container()
//       //     : Center(
//       //         child: Text("No Posts"),
//       //       ),
//       shrinkWrap: true,
//       allowImplicitScrolling: true,
//       scrollController: scrollController,
//       //item builder type is compulsory.
//       itemBuilder: optionalChildBuilder ??
//           (_, docs, index) {
//             alldocs = docs;

//             if (docs.isEmpty) return Container();
//             allPosts = sortPosts();
//             //Map data = alldocs[index].data();
//             var post = allPosts[index];

//             if (isGrid) {
//               if (post.isTextPost)
//                 return Container(
//                   child: Center(child: Text("Text")),
//                 );
//               if (post.videoMode!) return Container();

//               // return FutureBuilder(
//               //   future: ImagePickerServices.getImageThumbnail(
//               //       post.postAttachmentUrl),
//               //   builder: (BuildContext context, AsyncSnapshot snapshot) {
//               //     if (!snapshot.hasData) return Container();
//               //     return Image.file(snapshot.data);
//               //   },
//               // );
//               return OptimizedCacheImage(
//                 imageUrl: post.postAttachmentUrl!,
//                 height: Get.width * 0.3,
//                 width: Get.width * 0.3,
//                 fit: BoxFit.cover,
//               );
//             }
//             if (filterOutList.isNotEmpty) {
//               print("filtering");
//               if (filterOutList.contains(post.ownerId)) {
//                 print("filtered ${post.ownerId}");
//                 return Container();
//               }
//             }
//             return Container(
//               child: PostWidget(
//                 postModel: post,
//                 postId: post.postId,
//               ),
//             );
//           },
//       // orderBy is compulsory to enable pagination
//       query: query,
//       //Change types accordingly
//       itemBuilderType:
//           isGrid ? PaginateBuilderType.gridView : PaginateBuilderType.listView,
//       // to fetch real-time data
//       isLive: true,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//       ),
//     );
//   }
// }
