import 'dart:convert';

import 'package:algolia/algolia.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/utils/local_database.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

import '../../../controllers/search_controller.dart';
import '../../../models/workoutModel.dart';
import '../../widgets/comments_page.dart';
import '../../widgets/hashtag_screen.dart';
import '../../widgets/view_recipe.dart';
import '../../widgets/view_workout.dart';
import '../notFoundPages/workout_not_found.dart';

enum SearchedItemType { USER, HASHTAG, RECIPE, WORKOUT }

class SearchedItemModel {
  DateTime timeOfSearch;
  String searchTerm;
  SearchedItemType type;
  String id;
  Map<String, dynamic> snapshotJson;

  SearchedItemModel(
      {required this.timeOfSearch,
      required this.searchTerm,
      required this.type,
      required this.id,
      required this.snapshotJson});

  Map<String, dynamic> toMap() {
    return {
      'objectId': id,
      'id': id,
      'timeOfSearch': timeOfSearch,
      'searchTerm': searchTerm,
      'type': type.index,
      'snapshotJson': snapshotJson,
    };
  }

  factory SearchedItemModel.fromFirestore(QueryDocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map<String, dynamic>;
    // if (data == null) return null;
    return SearchedItemModel(
      id: snapshot.id,
      timeOfSearch: DateTime.fromMillisecondsSinceEpoch(
          data['timeOfSearch'].millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch),
      searchTerm: data['searchTerm'],
      type: SearchedItemType.values[data['type']],
      snapshotJson: data['snapshotJson'],
    );
  }
  factory SearchedItemModel.fromFirestoreDoc(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map<String, dynamic>;
    // if (data == null) return null;
    return SearchedItemModel(
      id: snapshot.id,
      timeOfSearch: DateTime.fromMillisecondsSinceEpoch(
          data['timeOfSearch'].millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch),
      searchTerm: data['searchTerm'],
      type: SearchedItemType.values[data['type']],
      snapshotJson: data['snapshotJson'],
    );
  }
}

// class RecentItemAdapter extends TypeAdapter<SearchedItemModel> {
//   @override
//   final int typeId = 0;

//   @override
//   SearchedItemModel read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return SearchedItemModel(
//       id: (fields[0] ?? "") as String,
//       searchTerm: (fields[1] ?? "") as String,
//       type: SearchedItemType.values[(fields[2] ?? 0) as int],
//       snapshotJson: jsonDecode(fields[4] ?? {}.toString()) as Map,
//       timeOfSearch: DateTime.fromMillisecondsSinceEpoch(
//           (fields[3] ?? DateTime.now().millisecondsSinceEpoch) as int),
//     );
//   }

//   @override
//   void write(BinaryWriter writer, SearchedItemModel obj) {
//     writer
//       ..writeByte(0)
//       ..write(obj.id)
//       ..writeByte(1)
//       ..write(obj.searchTerm)
//       ..writeByte(2)
//       ..write(obj.type.index)
//       ..writeByte(3)
//       ..write(obj.timeOfSearch.millisecondsSinceEpoch)
//       ..writeByte(4)
//       ..write(obj.snapshotJson.toString());
//   }

//   @override
//   int get hashCode => typeId.hashCode;

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is SearchedItemModel &&
//           runtimeType == other.runtimeType &&
//           typeId == 0;
// }

class SearchedItemWidget extends StatelessWidget {
  final Widget? child;
  final SearchedItemModel model;
  final bool withDeletion;

  SearchedItemWidget(
      {Key? key, required this.model, this.child, this.withDeletion = false})
      : super(key: key);

  final db = Database();
  final cuid = Get.find<UserController>().currentUid;
  SearchController sc = Get.find<SearchController>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(child: child ?? buildChild(context)),
        ],
      ),
    );
  }

  Widget buildChild(BuildContext context) {
    switch (model.type) {
      case SearchedItemType.USER:
        {
          return Padding(
            padding: const EdgeInsets.only(left: 1.0),
            child: UserHeaderTile(
              uid: model.id,
              gapAfterAvatar: 15,
              viewTrailing: true,
              trailing: !withDeletion
                  ? null
                  : IconButton(
                      onPressed: () async {
                        await db.recentSearches(cuid).doc(model.id).delete();
                      },
                      icon: xDIcon),
            ),
          );
        }
      case SearchedItemType.HASHTAG:
        {
          return Padding(
            padding: const EdgeInsets.only(left: 2.1),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.numbers_sharp,
                  size: 26,
                  color: Colors.black,
                ),
              ),
              visualDensity: VisualDensity(horizontal: 0, vertical: -1),
              contentPadding: EdgeInsets.only(
                  left: Get.width * 0.030,
                  right: Get.width * 0.02,
                  top: 0,
                  bottom: 0),
              trailing: !withDeletion
                  ? null
                  : IconButton(
                      onPressed: () async {
                        await db.recentSearches(cuid).doc(model.id).delete();
                      },
                      icon: xDIcon),
              dense: true,
              // horizontalTitleGap: ,
              minVerticalPadding: 0,

              onTap: () => Get.to(() => HashtagsScreen(
                    hashtag: model.id,
                    sortMode: SortMode.new_to_old,
                  )),
              title: Text(
                model.id,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: Text(
                model.snapshotJson['hitCount'].toString() +
                    " Post${model.snapshotJson['hitCount'] == 1 ? '' : 's'}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }

      case SearchedItemType.RECIPE:
        {
          RecipeModel? recipe = RecipeModel.fromMap(model.snapshotJson);
          return recipe.recipeId == null
              ? SizedBox.shrink()
              : ListTile(
                  visualDensity: VisualDensity(horizontal: 0, vertical: -1),
                  contentPadding: EdgeInsets.only(
                      left: Get.width * 0.040,
                      right: Get.width * 0.02,
                      top: 0,
                      bottom: 0),
                  trailing: !withDeletion
                      ? null
                      : IconButton(
                          onPressed: () async {
                            await db
                                .recentSearches(cuid)
                                .doc(model.id)
                                .delete();
                          },
                          icon: xDIcon),
                  onTap: () => Get.to(ViewRecipe(
                      // recipeUid: recipe.recipeId,
                      recipeModel: recipe)),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.network(
                      recipe.recipeCoverURL ?? "",
                      fit: BoxFit.cover,
                      height: Get.width * 0.1,
                      width: Get.width * 0.1,
                    ),
                  ),
                  title: Text(
                    recipe.recipeName ?? "No Name",
                    maxLines: 2,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UsernameWidget(
                        uid: recipe.ownerId!,
                      ),
                      Text(
                        recipe.saveCount.toString() +
                            " Save${recipe.saveCount == 1 ? '' : 's'}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
        }

      case SearchedItemType.WORKOUT:
        {
          WorkoutModel? workout = WorkoutModel.fromMap(model.snapshotJson);

          return workout.workoutId == null
              ? SizedBox.shrink()
              : ListTile(
                  visualDensity: VisualDensity(horizontal: 0, vertical: -1),
                  contentPadding: EdgeInsets.only(
                      left: Get.width * 0.040,
                      right: Get.width * 0.02,
                      top: 0,
                      bottom: 0),
                  trailing: !withDeletion
                      ? null
                      : IconButton(
                          onPressed: () async {
                            await db
                                .recentSearches(cuid)
                                .doc(model.id)
                                .delete();
                          },
                          icon: xDIcon),
                  onTap: () async {
                    bool isExist = await sc.getWorkout(workout.workoutId!);
                    if (isExist) {
                      Get.to(() => ViewWorkout(
                            workoutModel: workout,
                          ));
                    } else {
                      Get.to(() => WorkoutNotFound());
                    }
                    //   Get.to(ViewWorkout(
                    //   workoutModel: workout,
                    // ));
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.network(
                      workout.workoutCoverURL!,
                      fit: BoxFit.cover,
                      height: Get.width * 0.1,
                      width: Get.width * 0.1,
                    ),
                  ),
                  title: Text(
                    workout.workoutName!,
                    maxLines: 2,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UsernameWidget(
                        uid: workout.ownerId!,
                      ),
                      Text(
                        workout.saveCount.toString() +
                            " Save${workout.saveCount == 1 ? '' : 's'}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
        }

      default:
        {
          return Container();
        }
    }
  }
}
