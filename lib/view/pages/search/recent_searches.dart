import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/search/searched_item.dart';

import '../../../controllers/recent_search_controller.dart';
import '../../../controllers/user_controller.dart';

class RecentSearches extends StatelessWidget {
  RecentSearches({Key? key}) : super(key: key);
  RecentSearchController rc = Get.find<RecentSearchController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 16,
                ),
                Text(
                  "Recent",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                TextButton(
                    onPressed: () {
                      Get.to(() => RecentSearchesFull());
                    },
                    child: Text(
                      "See All",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  width: 8,
                )
              ],
            ),
            rc.recentSearchList!.isEmpty
                ? Center(child: SizedBox.shrink())
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: rc.recentSearchList!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SearchedItemWidget(
                        // onTap: () {},
                        model: rc.recentSearchList![index],
                        withDeletion: true,
                      );
                    },
                  )
            // StreamBuilder<QuerySnapshot>(
            //     stream:
            //         db.recentSearchesQuery(uc.currentUid).limit(15).snapshots(),
            //     builder: (context, snapshot) {
            //       if (!snapshot.hasData) {
            //         return Center(
            //           child: CircularProgressIndicator.adaptive(),
            //         );
            //       }
            //       var items = snapshot.data!.docs
            //           .map((e) => SearchedItemModel.fromFirestore(e))
            //           .toList();
            //       return ;
            //     }),
          ],
        ),
      );
    });
  }
}

class RecentSearchesFull extends StatefulWidget {
  const RecentSearchesFull({Key? key}) : super(key: key);

  @override
  State<RecentSearchesFull> createState() => _RecentSearchesFullState();
}

class _RecentSearchesFullState extends State<RecentSearchesFull> {
  Database db = Database();
  UserController uc = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
        title: "Recent Searches",
        iconButton: TextButton(
          onPressed: () async {
            await db.recentSearches(uc.currentUid).get().then((value) async {
              for (var element in value.docs) {
                await element.reference.delete();
              }
            });
          },
          child: Text(
            "Clear All",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: PaginateFirestore(
        onEmpty: Container(),
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        //item builder type is compulsory.
        itemBuilder: (_, docs, index) {
          var model = SearchedItemModel.fromFirestoreDoc(docs[index]);
          return SearchedItemWidget(
            // onTap: () {},
            model: model,
            withDeletion: true,
          );
        },
        // orderBy is compulsory to enable pagination
        query: db.recentSearchesQuery(uc.currentUid),
        itemBuilderType: PaginateBuilderType.listView,
        // to fetch real-time data
        isLive: true,
      ),

      // StreamBuilder<QuerySnapshot>(
      //     stream: db.recentSearchesQuery(uc.currentUid).limit(15).snapshots(),
      //     builder: (context, snapshot) {
      //       if (!snapshot.hasData) {
      //         return Center(
      //           child: CircularProgressIndicator.adaptive(),
      //         );
      //       }
      //       var items = snapshot.data!.docs
      //           .map((e) => SearchedItemModel.fromFirestore(e))
      //           .toList();
      //       return ListView.builder(
      //         physics: BouncingScrollPhysics(),
      //         shrinkWrap: true,
      //         itemCount: items.length,
      //         itemBuilder: (BuildContext context, int index) {
      //           return SearchedItemWidget(
      //             onTap: () {},
      //             model: items[index],
      //             withDeletion: true,
      //           );
      //         },
      //       );
      //     }),
    );
  }
}
