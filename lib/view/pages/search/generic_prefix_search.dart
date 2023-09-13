import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/user.dart';
import '../../../services/algolia_search.dart';
import '../../widgets/user_header_tile.dart';

class GenericPrefixSearch extends StatefulWidget {
  final Widget onEmpty;
  final List<String>? onlyShow;
  // final Widget Function(BuildContext, List<DocumentSnapshot<Object?>>, int)?
  //     itemBuilder;
  final Function(UserModel) onSelect;

  const GenericPrefixSearch({
    Key? key,
    required this.onEmpty,
    required this.onSelect,
    // this.itemBuilder,
    this.onlyShow,
  }) : super(
          key: key,
        );

  @override
  State<GenericPrefixSearch> createState() => _GenericPrefixSearchState();
}

class _GenericPrefixSearchState extends State<GenericPrefixSearch> {
  Rx<TextEditingController> _searchController = TextEditingController().obs;
  TextEditingController get searchController => _searchController.value;
  Rx<List<AlgoliaObjectSnapshot>?> _hitsList =
      Rx<List<AlgoliaObjectSnapshot>?>([]);
  List<AlgoliaObjectSnapshot>? get hitsList => _hitsList.value;
  final Algolia _algoliaApp = AlgoliaApplication.algolia;

  @override
  void initState() {
    super.initState();

    searchController.addListener(() async {
      EasyDebounce.debounce('create-post-search-debounce', 700.milliseconds,
          () async {
        await _getSearchResult(searchController.text).then((value) {
          if (widget.onlyShow != null) {
            print(widget.onlyShow);
            _hitsList.value = value!
                .where((element) => widget.onlyShow!.contains(element.objectID))
                .toList();
          } else {
            _hitsList.value = value;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          height: Get.height,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoSearchTextField(
                    controller: searchController,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                (hitsList!.isEmpty && searchController.text.isEmpty)
                    ? widget.onEmpty
                    : (hitsList!.isEmpty && searchController.text.isNotEmpty)
                        ? SizedBox.shrink()
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: hitsList!.length,
                            itemBuilder: (context, index) {
                              var user =
                                  UserModel.fromJson(hitsList![index].data);

                              return UserHeaderTile(
                                onTap: () => widget.onSelect(user),
                                onSelect: (p0) {
                                  widget.onSelect(user);
                                },
                                uid: user.id!,
                                disableProfileOpening: true,
                                userModel: user,
                                viewFollow: false,
                                withFollowers: false,
                                searchMode: false,
                                isFromSearch: false,
                              );
                            },
                          ),
              ],
            ),
          ),
        ));
  }

  Future<List<AlgoliaObjectSnapshot>?> _getSearchResult(
    String input,
  ) async {
    AlgoliaQuery query = _algoliaApp.instance
        .index("Users")
        .query(input)
        .setOffset(0)
        .setHitsPerPage(25);

    if (input.length > 0) {
      try {
        AlgoliaQuerySnapshot querySnap = await query.getObjects();
        var results = querySnap.hits;
        var hits = results;

        return hits;
      } on AlgoliaError catch (e) {
        print(e.error.toString());
        return [];
      }
    } else {
      return [];
    }
  }
}


// class GenericPrefixSearch extends StatefulWidget {
//   final CollectionReference collectionReference;
//   final String fieldName;
//   final String? orderBy;
//   final Widget onEmpty;
//   final Future<bool> Function(DocumentSnapshot, int)? specialConditonOnEachItem;
//   final FutureOr<List<String>>? evaluateAndRemoveThese;
//   final Widget Function(BuildContext, List<DocumentSnapshot<Object?>>, int)?
//       itemBuilder;
//   final Function(DocumentSnapshot) onSelect;

//   const GenericPrefixSearch({
//     Key? key,
//     required this.collectionReference,
//     required this.fieldName,
//     this.orderBy,
//     required this.onEmpty,
//     required this.onSelect,
//     this.itemBuilder,
//     this.evaluateAndRemoveThese,
//     this.specialConditonOnEachItem,
//   }) : super(
//           key: key,
//         );

//   @override
//   State<GenericPrefixSearch> createState() => _GenericPrefixSearchState();
// }

// class _GenericPrefixSearchState extends State<GenericPrefixSearch> {
//   Rx<TextEditingController> _searchController = TextEditingController().obs;
//   TextEditingController get searchController => _searchController.value;
//   Rx<List<AlgoliaObjectSnapshot>?> _hitsList =
//       Rx<List<AlgoliaObjectSnapshot>?>([]);
//   List<AlgoliaObjectSnapshot>? get hitsList => _hitsList.value;
//   final Algolia _algoliaApp = AlgoliaApplication.algolia;

//   @override
//   void initState() {
//     super.initState();

//     searchController.addListener(() async {
//       EasyDebounce.debounce('create-post-search-debounce', 700.milliseconds,
//           () async {
//         await _getSearchResult(searchController.text).then((value) {
//           print("getting search results ${value!.length}");
//           _hitsList.value = value;
//         });
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Container(
//           height: Get.height,
//           child: SingleChildScrollView(
//             physics: ClampingScrollPhysics(),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: CupertinoSearchTextField(
//                     controller: searchController,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: hitsList!.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                                     dense: true,
//                                     onTap: () => widget.onSelect(docs[index]),
//                                     leading: Icon(Icons.numbers_sharp),
//                                     title: Text(
//                                       docs[index].get(widget.fieldName),
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }

//   Future<List<AlgoliaObjectSnapshot>?> _getSearchResult(
//     String input,
//   ) async {
//     AlgoliaQuery query = _algoliaApp.instance
//         .index("Users")
//         .query(input)
//         .setOffset(0)
//         .setHitsPerPage(25);

//     if (input.length > 0) {
//       try {
//         AlgoliaQuerySnapshot querySnap = await query.getObjects();
//         var results = querySnap.hits;
//         var hits = results;

//         return hits;
//       } on AlgoliaError catch (e) {
//         print(e.error.toString());
//         return [];
//       }
//     } else {
//       return [];
//     }
//   }
// }



// //junk

// // StreamBuilder<String>(
// //                     stream:
// //                         Stream.value(searchController.text).asBroadcastStream(),
// //                     builder: (context, snapshot) {
// //                       if (snapshot.connectionState != ConnectionState.done)
// //                         return Center(
// //                           child: CircularProgressIndicator.adaptive(),
// //                         );
// //                       if (searchController.text.isEmpty) {
// //                         return widget.onEmpty;
// //                       }
// //                       return PaginateFirestore(
// //                         onEmpty: Container(),

// //                         shrinkWrap: true,
// //                         //item builder type is compulsory.
// //                         itemBuilder: (context, docs, index) {
// //                           if (filters.isNotEmpty) {
// //                             if (filters.contains(docs[index].id))
// //                               return SizedBox.shrink();
// //                           }
// //                           if (widget.specialConditonOnEachItem != null) {
// //                             return FutureBuilder<bool>(
// //                               future: widget.specialConditonOnEachItem!(
// //                                   docs[index], index),
// //                               initialData: false,
// //                               builder: (BuildContext context,
// //                                   AsyncSnapshot snapshot) {
// //                                 if (widget.itemBuilder != null &&
// //                                     snapshot.data == true) {
// //                                   return widget.itemBuilder!(
// //                                       context, docs, index);
// //                                 }
// //                                 if (snapshot.data) {
// //                                   Map<String, dynamic> data = docs[index].data()
// //                                       as Map<String, dynamic>;
// //                                   return ListTile(
// //                                     dense: true,
// //                                     onTap: () => widget.onSelect(docs[index]),
// //                                     leading: Icon(Icons.numbers_sharp),
// //                                     title: Text(
// //                                       docs[index].get(widget.fieldName),
// //                                       style: TextStyle(
// //                                           fontWeight: FontWeight.bold),
// //                                     ),
// //                                   );
// //                                 }
// //                                 return SizedBox.shrink();
// //                               },
// //                             );
// //                           }

// //                           if (widget.itemBuilder != null) {
// //                             return widget.itemBuilder!(context, docs, index);
// //                           }

// //                           Map<String, dynamic> data =
// //                               docs[index].data() as Map<String, dynamic>;
// //                           return ListTile(
// //                             dense: true,
// //                             onTap: () => widget.onSelect(docs[index]),
// //                             leading: Icon(Icons.numbers_sharp),
// //                             title: Text(
// //                               docs[index].get(widget.fieldName),
// //                               style: TextStyle(fontWeight: FontWeight.bold),
// //                             ),
// //                           );
// //                         },
// //                         // orderBy is compulsory to enable pagination
// //                         query: getQuery(searchController.text),
// //                         //Change types accordingly
// //                         itemBuilderType: PaginateBuilderType.listView,
// //                         // to fetch real-time data
// //                         isLive: true,
// //                       );
// //                     })

//  // Query getQuery(String search) {
//   //   if (widget.orderBy != null && widget.orderBy != widget.fieldName) {
//   //     return widget.collectionReference
//   //         .where(widget.fieldName,
//   //             isGreaterThanOrEqualTo: searchController.text)
//   //         .where(widget.fieldName,
//   //             isLessThanOrEqualTo: getStringUpperBound(searchController.text))
//   //         .orderBy(widget.fieldName)
//   //         .orderBy(widget.orderBy!);
//   //   } else {
//   //     return widget.collectionReference
//   //         .where(widget.fieldName,
//   //             isGreaterThanOrEqualTo: searchController.text)
//   //         .where(widget.fieldName,
//   //             isLessThanOrEqualTo: getStringUpperBound(searchController.text))
//   //         .orderBy(widget.fieldName);
//   //   }
//   // }


//   //   getFilters();
//   // List<String> filters = [];
//   // getFilters() async {
//   //   if (widget.evaluateAndRemoveThese != null) {
//   //     filters = await widget.evaluateAndRemoveThese!;
//   //   }
//   // }
