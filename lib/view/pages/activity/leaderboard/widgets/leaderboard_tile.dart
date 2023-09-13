// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/theme.dart';
import 'package:sano_gano/models/hashtag_model.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/models/workoutModel.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/helpers/leaderboard_type.dart';
import 'package:sano_gano/view/widgets/post_widget.dart';

import '../../../../../const/colors.dart';
import '../../../../../const/iconAssetStrings.dart';
import '../../../../../models/postmodel.dart';
import '../../../../../utils/globalHelperMethods.dart';
import '../../../../global/space.dart';
import '../../../../widgets/user_header_tile.dart';

class LeaderBoardTile extends StatelessWidget {
  final int index;
  final LeaderboardType dataType;
  final Map<String, dynamic> data;
  LeaderBoardTile(
      {super.key,
      required this.index,
      required this.dataType,
      required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.isDarkMode ? Colors.black : Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: dataType == LeaderboardType.posts ? 0 : 15),
        child: dataType == LeaderboardType.posts
            ? PostDataTile(post: PostModel.fromMap(data), index: index)
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: Get.width * 0.05,
                    child: AutoSizeText(squeezeNumbers(index)! + ".",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                            color: ThemeColor().getLeaderBoardColor(index),
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
                  addWidth(10),
                  Expanded(child: TileData(dataType: dataType, data: data))
                ],
              ),
      ),
    );
  }
}

class TileData extends StatelessWidget {
  final LeaderboardType dataType;
  final Map<String, dynamic> data;
  const TileData({super.key, required this.dataType, required this.data});

  @override
  Widget build(BuildContext context) {
    switch (dataType) {
      case LeaderboardType.users:
        UserModel user = UserModel.fromMap(data);
        return UserTileData(user: user);
      case LeaderboardType.hashtags:
        HashtagModel hashtag = HashtagModel.fromMap(data);
        return HashtagDataTile(hashtag: hashtag);
      case LeaderboardType.workouts:
        WorkoutModel workout = WorkoutModel.fromMap(data);
        return WorkoutDataTile(workout: workout);
      case LeaderboardType.recipes:
        RecipeModel recipe = RecipeModel.fromMap(data);
        return RecipeDataTile(recipe: recipe);

      default:
        return SizedBox();
    }
  }
}

class UserTileData extends StatelessWidget {
  final UserModel user;
  const UserTileData({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(
          user.id!,
          radius: 14,
        ),
        addWidth(10),
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.username ?? "username",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                user.name ?? "name",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Text(
          user.followers.toString().isNotEmpty
              ? user.followers.toString()
              : "0",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class HashtagDataTile extends StatelessWidget {
  final HashtagModel hashtag;
  const HashtagDataTile({super.key, required this.hashtag});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hashtag.id,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        Text(
            hashtag.hitCount.toString() +
                " Post${hashtag.hitCount == 1 ? '' : 's'}",
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class PostDataTile extends StatelessWidget {
  final PostModel post;
  final int index;
  const PostDataTile({super.key, required this.post, required this.index});

  @override
  Widget build(BuildContext context) {
    return PostWidget(
      postId: post.postId,
      postModel: post,
      popularityIndex: index,
    );
  }
}

class RecipeDataTile extends StatelessWidget {
  final RecipeModel recipe;
  const RecipeDataTile({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: OptimizedCacheImage(
            imageUrl: recipe.recipeCoverURL!,
            imageBuilder: (context, imageProvider) {
              return Container(
                height: 32.5,
                width: 32.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      recipe.recipeCoverURL != defaultRecipeImage ? 5 : 0),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            errorWidget: (context, url, error) =>
                SvgPicture.asset(cookbookDIconAsset, fit: BoxFit.cover),
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.recipeName!,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis),
              ),
              FutureBuilder<UserModel?>(
                  future: Database().getUser(recipe.ownerId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.data == null) {
                      return Text(
                        '',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            overflow: TextOverflow.ellipsis),
                      );
                    }
                    UserModel user = snapshot.data!;
                    return Text(
                      user.username ?? "",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          overflow: TextOverflow.ellipsis),
                    );
                  }),
              Text(
                  recipe.saveCount.toString() +
                      " Save${recipe.saveCount == 1 ? '' : 's'}",
                  style: TextStyle(fontSize: 10, color: Colors.grey))
            ],
          ),
        ),
      ],
    );
  }
}

class WorkoutDataTile extends StatelessWidget {
  final WorkoutModel workout;
  const WorkoutDataTile({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: OptimizedCacheImage(
            imageUrl: workout.workoutCoverURL!,
            imageBuilder: (context, imageProvider) {
              return Container(
                height: 32.5,
                width: 32.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      workout.workoutCoverURL != defaultWorkoutImage ? 5 : 0),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            errorWidget: (context, url, error) =>
                SvgPicture.asset(gymDIconAsset, fit: BoxFit.cover),
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.workoutName!,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis),
              ),
              FutureBuilder<UserModel?>(
                  future: Database().getUser(workout.ownerId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.data == null) {
                      return Text(
                        '',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            overflow: TextOverflow.ellipsis),
                      );
                    }
                    UserModel user = snapshot.data!;
                    return Text(
                      user.username ?? "",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          overflow: TextOverflow.ellipsis),
                    );
                  }),
              Text(
                  workout.saveCount.toString() +
                      " Save${workout.saveCount == 1 ? '' : 's'}",
                  style: TextStyle(fontSize: 10, color: Colors.grey))
            ],
          ),
        ),
      ],
    );
  }
}
