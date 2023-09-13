import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/suggestions_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

class SuggestedFriends extends StatefulWidget {
  const SuggestedFriends({Key? key}) : super(key: key);

  @override
  _SuggestedFriendsState createState() => _SuggestedFriendsState();
}

class _SuggestedFriendsState extends State<SuggestedFriends> {
  var uid = Get.find<UserController>().currentUid;
  @override
  Widget build(BuildContext context) {
    return GetX<SuggestionsController>(
        init: SuggestionsController(),
        builder: (suggestionsController) {
          return Scaffold(
            appBar: CustomAppBar(
              back: true,
              title: "Suggestions",
            ),
            body: suggestionsController.loading
                ? Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(
                          height: 5,
                        ),
                    itemCount:
                        suggestionsController.mutualFriendsSuggestions!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return UserHeaderTile(
                        viewTrailing: true,
                        isFromSearch: false,
                        viewFollow: true,
                        uid: suggestionsController
                            .mutualFriendsSuggestions![index],
                        gapAfterAvatar: 10,
                        subtitle: FutureBuilder<int>(
                            future: UserDatabase().getMutualFriendsCount(
                                suggestionsController
                                    .mutualFriendsSuggestions![index]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text(
                                  '',
                                );
                              }
                              int mutualFriends = snapshot.data ?? 0;

                              return Text(
                                mutualFriends.toString() +
                                    " mutual friend${mutualFriends == 1 ? '' : 's'}",
                                style: TextStyle(color: Colors.grey[500]),
                              );
                            }),
                      );
                    }),
          );
        });
  }
}


//* junk 
   // body: ListView.separated(
            //         separatorBuilder: (context, index) => SizedBox(
            //           height: 5,
            //         ),
            //         itemCount: currentUserSuggestions.length,
            //         itemBuilder: (BuildContext context, int index) {
            //           return FutureBuilder<UserMutualResponse>(
            //               future: UserDatabase()
            //                   .getUserWithFriends(currentUserSuggestions[index]),
            //               builder: (context, snapshot) {
            //                 if (!snapshot.hasData) return Container();
            //                 var user = snapshot.data!.user;
            //                 var friendlist = snapshot.data!.friends;
            //                 int mutualCount = friendlist
            //                     .toSet()
            //                     .intersection(currentUserFriends.toSet())
            //                     .toList()
            //                     .length;
            //                 return UserHeaderTile(
            //                   uid: user.id!,
            //                   gapAfterAvatar: 10,
            //                   subtitle: Column(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Text(
            //                         user.name!,
            //                         style: TextStyle(color: Colors.grey[500]),
            //                       ),
            //                       Text(
            //                         mutualCount.toString() +
            //                             " mutual friend${mutualCount == 1 ? '' : 's'}",
            //                         style: TextStyle(color: Colors.grey[500]),
            //                       ),
            //                     ],
            //                   ),
            //                   viewTrailing: true,
            //                   trailing: Row(
            //                     mainAxisSize: MainAxisSize.min,
            //                     children: [
            //                       IconButton(
            //                           onPressed: () async {
            //                             showLoading();
            //                             await controller.followUser(user.id!, uid);
            //                             await sugegstionRef
            //                                 .doc(currentUserSuggestions[index])
            //                                 .delete();
            //                             hideLoading();
            //                             currentUserSuggestions.removeAt(index);
            //                             //await filtered[index].reference.delete();
            //                             setState(() {});
            //                           },
            //                           icon: checkmarkDIcon),
            //                       IconButton(
            //                           onPressed: () async {
            //                             currentUserSuggestions.removeAt(index);
            //                             // await filtered[index].reference.delete();
            //                             setState(() {});
            //                           },
            //                           icon: xDIcon),
            //                     ],
            //                   ),
            //                 );
            //               });
            //         },
            //       ),
            // body: FutureBuilder<void>(
            //     future: getData(),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return Center(child: CircularProgressIndicator.adaptive());
            //       }
            //       return ListView.separated(
            //         separatorBuilder: (context, index) => SizedBox(
            //           height: 5,
            //         ),
            //         itemCount: currentUserSuggestions.length,
            //         itemBuilder: (BuildContext context, int index) {
            //           return FutureBuilder<UserMutualResponse>(
            //               future: UserDatabase()
            //                   .getUserWithFriends(currentUserSuggestions[index]),
            //               builder: (context, snapshot) {
            //                 if (!snapshot.hasData) return Container();
            //                 var user = snapshot.data!.user;
            //                 var friendlist = snapshot.data!.friends;
            //                 int mutualCount = friendlist
            //                     .toSet()
            //                     .intersection(currentUserFriends.toSet())
            //                     .toList()
            //                     .length;
            //                 return UserHeaderTile(
            //                   uid: user.id!,
            //                   gapAfterAvatar: 10,
            //                   subtitle: Column(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Text(
            //                         user.name!,
            //                         style: TextStyle(color: Colors.grey[500]),
            //                       ),
            //                       Text(
            //                         mutualCount.toString() +
            //                             " mutual friend${mutualCount == 1 ? '' : 's'}",
            //                         style: TextStyle(color: Colors.grey[500]),
            //                       ),
            //                     ],
            //                   ),
            //                   viewTrailing: true,
            //                   trailing: Row(
            //                     mainAxisSize: MainAxisSize.min,
            //                     children: [
            //                       IconButton(
            //                           onPressed: () async {
            //                             showLoading();
            //                             await controller.followUser(user.id!, uid);
            //                             await sugegstionRef
            //                                 .doc(currentUserSuggestions[index])
            //                                 .delete();
            //                             hideLoading();
            //                             currentUserSuggestions.removeAt(index);
            //                             //await filtered[index].reference.delete();
            //                             setState(() {});
            //                           },
            //                           icon: checkmarkDIcon),
            //                       IconButton(
            //                           onPressed: () async {
            //                             currentUserSuggestions.removeAt(index);
            //                             // await filtered[index].reference.delete();
            //                             setState(() {});
            //                           },
            //                           icon: xDIcon),
            //                     ],
            //                   ),
            //                 );
            //               });
            //         },
            //       );
            //     }),

            // StreamBuilder<QuerySnapshot>(
            //     stream: Database()
            //         .suggestionsCollection(uid)
            //         .orderBy('suggested')
            //         .limit(100)
            //         .snapshots(),
            //     builder: (BuildContext context,
            //         AsyncSnapshot<QuerySnapshot> parentSnapshot) {
            //       if (!parentSnapshot.hasData)
            //         return Center(
            //           child: CircularProgressIndicator(),
            //         );
            //       var filtered = parentSnapshot.data.docs;
            //       filtered = filtered
            //           .where((element) =>
            //               currentUserFollowingss.contains(element.id))
            //           .toList();
            //       var suggestions = filtered.map((e) => e.id).toList();

            //       return ListView.separated(
            //         separatorBuilder: (context, index) => SizedBox(
            //           height: 5,
            //         ),
            //         itemCount: suggestions.length,
            //         itemBuilder: (BuildContext context, int index) {
            //           return FutureBuilder<UserMutualResponse>(
            //               future: UserDatabase()
            //                   .getUserWithFriends(suggestions[index]),
            //               builder: (context, snapshot) {
            //                 if (!snapshot.hasData) return Container();
            //                 var user = snapshot.data.user;
            //                 var friendlist = snapshot.data.friends;
            //                 int mutualCount = friendlist
            //                     .toSet()
            //                     .union(currentUserFriends.toSet())
            //                     .toList()
            //                     .length;
            //                 return UserHeaderTile(
            //                   uid: user.id,
            //                   gapAfterAvatar: 10,
            //                   subtitle: Column(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Text(
            //                         user.name,
            //                         style: TextStyle(color: Colors.grey[500]),
            //                       ),
            //                       Text(
            //                         mutualCount.toString() +
            //                             " mutual friend${mutualCount == 1 ? '' : 's'}",
            //                         style: TextStyle(color: Colors.grey[500]),
            //                       ),
            //                     ],
            //                   ),
            //                   viewTrailing: true,
            //                   trailing: Row(
            //                     mainAxisSize: MainAxisSize.min,
            //                     children: [
            //                       IconButton(
            //                           onPressed: () async {
            //                             await controller.followUser(user.id, uid);
            //                             await filtered[index].reference.delete();
            //                           },
            //                           icon: checkmarkDIcon),
            //                       IconButton(
            //                           onPressed: () async {
            //                             await filtered[index].reference.delete();
            //                           },
            //                           icon: xDIcon),
            //                     ],
            //                   ),
            //                 );
            //               });
            //         },
            //       );
            //     },
            //   ),

            // PaginateFirestore(
            //   onEmpty: Center(
            //     child: Text("No Suggestions"),
            //   ),
            //   shrinkWrap: true,
            //   //item builder type is compulsory.
            //   itemBuilder:(_, docs, index) {
            //     return FutureBuilder<UserModel>(
            //         future: UserDatabase().getUser(documentSnapshot.id),
            //         builder: (context, snapshot) {
            //           if (!snapshot.hasData) return Container();
            //           var user = snapshot.data;
            //           return UserHeaderTile(
            //             uid: user.id,
            //             subtitle: Column(children: [
            //               Text(user.username),

            //             ],),
            //             viewTrailing: true,
            //             trailing: Row(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 IconButton(onPressed: () {}, icon: Icon(Icons.check)),
            //                 IconButton(
            //                     onPressed: () async {
            //                       await documentSnapshot.reference.delete();
            //                     },
            //                     icon: Icon(Icons.close)),
            //               ],
            //             ),
            //           );
            //         });
            //   },
            //   // orderBy is compulsory to enable pagination
            //   query: Database().suggestionsCollection(uid).orderBy('suggested'),
            //   //Change types accordingly
            //   itemBuilderType: PaginateBuilderType.listView,
            //   // to fetch real-time data
            //   isLive: true,
            // ),


            // CollectionReference get sugegstionRef => database.suggestionsCollection(uid);
  // var database = Database();
  // Future<void> getData() async {
  //   var db = FollowDatabase();
  //   currentUserFriends = (await db.getFriendList(uid)).friends;
  //   currentUserFollowings = await db.getFollowingList(uid);
  //   var suggestionDocs = await database
  //       .suggestionsCollection(uid)
  //       .orderBy('suggested')
  //       .limit(100)
  //       .get();

  //   currentUserSuggestions = suggestionDocs.docs.map((e) => e.id).toList();
  //   currentUserSuggestions.removeWhere((element) {
  //     return currentUserFollowings.contains(element);
  //   });
  //   currentUserSuggestions.removeWhere((element) {
  //     return currentUserFriends.contains(element);
  //   });
  // }