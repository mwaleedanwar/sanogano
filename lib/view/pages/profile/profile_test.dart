// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:paginate_firestore/paginate_firestore.dart';
// import 'package:sano_gano/controllers/auth_controller.dart';
// import 'package:sano_gano/controllers/postController.dart';
// import 'package:sano_gano/controllers/user_controller.dart';
// import 'package:sano_gano/models/postmodel.dart';
// import 'package:sano_gano/utils/database.dart';
// import 'package:sano_gano/view/global/space.dart';
// import 'package:sano_gano/view/pages/profile/follow_message_profile_buttons.dart';
// import 'package:sano_gano/utils/globalHelperMethods.dart' as helper;
// import 'package:sano_gano/view/widgets/post_widget.dart';

// import 'widgets/profile_image.dart';

// class BuildProfileBody extends StatefulWidget {
//   final String? userID;
//   final VoidCallback? healthCallback;
//   final bool? hideBack;

//   const BuildProfileBody(
//       {Key? key,
//       required this.userID,
//       required this.healthCallback,
//       required this.hideBack})
//       : super(key: key);
//   @override
//   _BuildProfileBodyState createState() => _BuildProfileBodyState();
// }

// class _BuildProfileBodyState extends State<BuildProfileBody>
//     with TickerProviderStateMixin {
//   late TabController primaryTC;
//   late String userID;

//   var scrollControllers = [
//     ScrollController(),
//     ScrollController(),
//     ScrollController(),
//     ScrollController(),
//     ScrollController(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     userID = widget.userID!;
//     primaryTC = TabController(length: 5, vsync: this);
//   }

//   @override
//   void dispose() {
//     primaryTC.dispose();

//     super.dispose();
//   }

//   var postController = Get.put(PostController());
//   var db = Database();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: _buildScaffoldBody());
//   }

//   Widget _buildBioText(String? bio) {
//     if (helper.isNullOrBlank(bio)) {
//       return Container();
//     }
//     if (bio == null) {
//       return Text(
//         "bio",
//         style: TextStyle(color: Colors.grey),
//       );
//     } else {
//       if (bio.length == 0) {
//         return Text(
//           "bio",
//           style: TextStyle(color: Colors.grey),
//         );
//       } else {
//         return Text(
//           bio,
//           softWrap: true,
//           maxLines: 2,
//           style: TextStyle(height: 1.5),
//           textAlign: TextAlign.center,
//         );
//       }
//     }
//   }

//   Widget _buildWebsiteText(String? website) {
//     if (helper.isNullOrBlank(website)) {
//       return Container();
//     }
//     if (website == null) {
//       return Text(
//         "website",
//         style: TextStyle(color: Colors.grey),
//       );
//     } else {
//       if (website.length == 0) {
//         return Text(
//           "website",
//           style: TextStyle(color: Colors.grey),
//         );
//       } else {
//         return Text(
//           website,
//           style: TextStyle(
//             color: Color(0xFF5879EE),
//           ),
//         );
//       }
//     }
//   }

//   Widget _buildScaffoldBody() {
//     final double statusBarHeight = MediaQuery.of(context).padding.top;
//     final double pinnedHeaderHeight =
//         //statusBar height
//         statusBarHeight +
//             //pinned SliverAppBar height in header
//             kToolbarHeight;
//     var format = DateFormat("MMMM d, y");
//     return GetX<UserController>(
//       init: UserController(),
//       initState: (_) {},
//       builder: (UserController controller) {
//         var _myID = Get.find<AuthController>().user!.uid;
//         var _myProfile = true;

//         controller.getCurrentUser(userID);
//         if (controller != null && controller.userModel != null) {
//           var _user = controller.userModel;
//           _myProfile = controller.userModel.id == _myID;

//           return ExtendedNestedScrollView(
//             headerSliverBuilder: (BuildContext c, bool f) {
//               final List<Widget> widgets = <Widget>[];

//               widgets.add(
//                 SliverAppBar(
//                   pinned: true,
//                   // expandedHeight: 200.0,
//                   //title: Text(old ? 'old demo' : 'new demo'),
//                   flexibleSpace: FlexibleSpaceBar(
//                     //centerTitle: true,
//                     collapseMode: CollapseMode.pin,
//                   ),
//                 ),
//               );

//               widgets.add(
//                 SliverList(
//                   delegate: SliverChildListDelegate([
//                     Container(
//                       constraints: BoxConstraints(maxHeight: Get.height * 0.25),
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Positioned(
//                             top: 0,
//                             left: 0,
//                             right: 0,
//                             child: controller.userModel.bannerURL?.isNotEmpty ??
//                                     false
//                                 ? OptimizedCacheImage(
//                                     imageUrl: controller.userModel.bannerURL!,
//                                     height: 120,
//                                     fit: BoxFit.fill,
//                                   )
//                                 : Image.asset(
//                                     "assets/banner.png",
//                                     height: 120,
//                                     fit: BoxFit.fill,
//                                   ),
//                           ),
//                           Positioned(
//                             top: 65,
//                             child: ProfileImage(
//                               _user.profileURL!,
//                               _user.id!,
//                               _user.username!,
//                               _user.followers ?? 0,
//                               _user.following ?? 0,
//                               _user.name!,
//                               healthCallback: widget.healthCallback,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       child: Column(
//                         children: [
//                           Text(
//                             _user.name ?? "Name",
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           addHeight(5.0),
//                           Container(
//                               width: Get.width * 0.8,
//                               child: _buildBioText(_user.bio)),
//                           addHeight(5.0),
//                           _buildWebsiteText(_user.website),
//                           addHeight(7.5),
//                           Text(
//                             "ESTABLISHED " +
//                                 format
//                                     .format(_user.established ?? DateTime.now())
//                                     .toUpperCase(),
//                             style: TextStyle(fontSize: 10),
//                           ),
//                           // addHeight(5),

//                           //Follow And Message For Other Users
//                           !_myProfile
//                               ? UserProfile(
//                                   userID: userID,
//                                   userModel: _user,
//                                 )
//                               : Container(
//                                   padding: EdgeInsets.zero,
//                                 ),
//                         ],
//                       ),
//                     ),
//                   ]),
//                 ),
//               );

//               // widgets.add(
//               //   SliverList(
//               //     delegate: SliverChildBuilderDelegate(
//               //       (BuildContext c, int i) {
//               //         return Container(
//               //           alignment: Alignment.center,
//               //           height: 60.0,
//               //           child: Text('SliverList$i'),
//               //         );
//               //       },
//               //       childCount: 3,
//               //     ),
//               //   ),
//               // );

// //  widgets.add(SliverPersistentHeader(
// //      pinned: true,
// //      floating: false,
// //      delegate: CommonSliverPersistentHeaderDelegate(
// //          Container(
// //            child: primaryTabBar,
// //            //color: Colors.white,
// //          ),
// //          primaryTabBar.preferredSize.height)));
//               return widgets;
//             },
//             //1.[pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)
//             pinnedHeaderSliverHeightBuilder: () {
//               return pinnedHeaderHeight;
//             },
//             //2.[inner scrollables in tabview sync issue](https://github.com/flutter/flutter/issues/21868)
//             onlyOneScrollInBody: true,
//             body: Column(
//               children: <Widget>[
//                 TabBar(
//                   controller: primaryTC,
//                   onTap: (value) {
//                     scrollControllers[value].animateTo(0.0,
//                         duration: Duration(seconds: 1), curve: Curves.easeIn);
//                   },
//                   automaticIndicatorColorAdjustment: true,
//                   indicatorColor:
//                       Get.isDarkMode == true ? Colors.white : Colors.black,
//                   labelPadding: EdgeInsets.symmetric(horizontal: 5),
//                   // labelColor: Colors.black,
//                   //indicatorColor: Colors.black,
//                   labelStyle: TextStyle(
//                       fontSize: 13,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold),
//                   unselectedLabelStyle: TextStyle(
//                     fontSize: 13,
//                     color: Colors.black,
//                   ),
//                   tabs: [
//                     Tab(
//                       text: "All",
//                     ),
//                     Tab(
//                       text: "Media",
//                     ),
//                     Tab(
//                       text: "Recipe",
//                     ),
//                     Tab(
//                       text: "Workout",
//                     ),
//                     Tab(
//                       text: "Tagged",
//                     ),
//                   ],
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     controller: primaryTC,
//                     children: <Widget>[
//                       PaginateFirestore(
//                         physics: ClampingScrollPhysics(),
//                         onEmpty: Center(
//                           child: Text("No Posts"),
//                         ),
//                         shrinkWrap: true,
//                         allowImplicitScrolling: true,

//                         //item builder type is compulsory.
//                         itemBuilder: (_, docs, index) {
//                           Map<String, dynamic> data =
//                               docs[index].data() as Map<String, dynamic>;
//                           var post = PostModel.fromMap(data);

//                           return Container(
//                             child: PostWidget(
//                               postModel: post,
//                               postId: post.postId,
//                             ),
//                           );
//                         },
//                         // orderBy is compulsory to enable pagination
//                         query: db.postsCollection
//                             .where('ownerId', isEqualTo: _myID)
//                             .orderBy('timestamp', descending: true),
//                         //Change types accordingly
//                         itemBuilderType: PaginateBuilderType.listView,
//                         // to fetch real-time data
//                         isLive: true,
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3,
//                         ),
//                       ),

//                       PaginateFirestore(
//                         key: const PageStorageKey<String>('Tab2'),
//                         physics: ClampingScrollPhysics(),
//                         onEmpty: Center(
//                           child: Text("No Posts"),
//                         ),
//                         shrinkWrap: true,
//                         allowImplicitScrolling: true,

//                         //item builder type is compulsory.
//                         itemBuilder: (_, docs, index) {
//                           Map<String, dynamic> data =
//                               docs[index].data() as Map<String, dynamic>;
//                           var post = PostModel.fromMap(data);

//                           return Container(
//                             child: PostWidget(
//                               postModel: post,
//                               postId: post.postId,
//                             ),
//                           );
//                         },
//                         // orderBy is compulsory to enable pagination
//                         query: db.postsCollection
//                             .where('ownerId', isEqualTo: _myID)
//                             .where('postAttachmentUrl', isNotEqualTo: "")
//                             .orderBy('postAttachmentUrl', descending: true)
//                             .orderBy('timestamp', descending: true),
//                         //Change types accordingly
//                         itemBuilderType: PaginateBuilderType.listView,
//                         // to fetch real-time data
//                         isLive: true,
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3,
//                         ),
//                       ),
//                       // BuildPostPagination(
//                       //   db.postsCollection
//                       //       .where('ownerId', isEqualTo: _myID)
//                       //       .where('postAttachmentUrl', isNotEqualTo: "")
//                       //       .orderBy('postAttachmentUrl', descending: true)
//                       //       .orderBy('timestamp', descending: true),
//                       //   scrollController: scrollControllers[1],
//                       //   key: const PageStorageKey<String>('Tab2'),
//                       // ),

//                       postController.getPaginatedPosts(
//                         db.postsCollection
//                             .where('ownerId', isEqualTo: _myID)
//                             .where('attachedRecipeId', isNotEqualTo: "")
//                             .orderBy('attachedRecipeId', descending: true)
//                             .orderBy('timestamp', descending: true),
//                         scrollController: scrollControllers[2],
//                         key: const PageStorageKey<String>('Tab3'),
//                       ),
//                       postController.getPaginatedPosts(
//                         db.postsCollection
//                             .where('ownerId', isEqualTo: _myID)
//                             .where('attachedWorkoutId', isNotEqualTo: "")
//                             .orderBy('attachedWorkoutId', descending: true)
//                             .orderBy(
//                               'timestamp',
//                               descending: true,
//                             ),
//                         scrollController: scrollControllers[3],
//                         key: const PageStorageKey<String>('Tab4'),
//                       ),
//                       postController.getPaginatedPosts(
//                         db.postsCollection
//                             .where('taggedUsers', arrayContains: _myID)
//                             .orderBy('timestamp'),
//                         scrollController: scrollControllers[4],
//                         key: const PageStorageKey<String>('Tab5'),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           );
//         } else {
//           return Center(
//             child: SpinKitCircle(
//               size: 25,
//               color: Colors.black,
//             ),
//           );
//         }
//       },
//     );
//   }
// }
