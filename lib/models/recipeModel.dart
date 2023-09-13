import 'dart:convert';

import 'package:sano_gano/const/theme.dart';

class RecipeModel {
  String? recipeName;
  int? cookingTimeInMinutes;
  int? servingCount;
  int? saveCount;
  String? description;
  String? ingredients;
  String? instructions;
  String? ownerId;
  String? recipeId;
  DateTime? createdOn;
  String? recipeCoverURL;
  bool? indexedInSearch;
  int? postCount;
  int? likeCount;
  int? reports;
  bool isDeleted = false;
  List<String> savedBy;
  RecipeModel(
      {this.recipeName,
      this.cookingTimeInMinutes,
      this.servingCount,
      this.description,
      this.ingredients,
      this.instructions,
      this.ownerId,
      this.recipeId,
      this.createdOn,
      this.saveCount,
      this.recipeCoverURL,
      this.indexedInSearch,
      this.postCount,
      this.likeCount,
      this.isDeleted = false,
      this.savedBy = const [],
      this.reports});

  Map<String, dynamic> toMap() {
    return {
      'recipeName': recipeName,
      'cookingTimeInMinutes': cookingTimeInMinutes,
      'servingCount': servingCount,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'ownerId': ownerId,
      'recipeId': recipeId,
      'createdOn': createdOn!.millisecondsSinceEpoch,
      'recipeCoverURL': recipeCoverURL,
      'indexedInSearch': indexedInSearch,
      'postCount': postCount,
      'likeCount': likeCount,
      'saveCount': saveCount,
      'isDeleted': isDeleted,
      'savedBy': savedBy,
      'reports': reports
    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
        recipeName: map['recipeName'],
        cookingTimeInMinutes: map['cookingTimeInMinutes'] ?? 0,
        servingCount: map['servingCount'],
        description: map['description'],
        ingredients: map['ingredients'].toString(),
        instructions: map['instructions'].toString(),
        ownerId: map['ownerId'],
        recipeId: map['recipeId'],
        createdOn: DateTime.fromMillisecondsSinceEpoch(
            map['createdOn'] ?? DateTime.now().millisecondsSinceEpoch),
        recipeCoverURL: map['recipeCoverURL'],
        indexedInSearch: map['indexedInSearch'] ?? true,
        postCount: map['postCount'] ?? 0,
        likeCount: map['likeCount'] ?? 0,
        saveCount: map['saveCount'] ?? 0,
        savedBy:
            map['savedBy'] == null ? [] : List<String>.from(map['savedBy']),
        reports: map['reports'] ?? 0);
  }

  String toJson() => json.encode(toMap());

  factory RecipeModel.fromJson(String source) =>
      RecipeModel.fromMap(json.decode(source));

  RecipeModel copyWith(
      {String? recipeName,
      int? cookingTimeInMinutes,
      int? servingCount,
      String? description,
      List<String>? ingredients,
      List<String>? instructions,
      String? ownerId,
      String? recipeId,
      DateTime? createdOn,
      String? recipeCoverURL,
      int? reports}) {
    return RecipeModel(
        recipeName: recipeName ?? this.recipeName,
        cookingTimeInMinutes: cookingTimeInMinutes ?? this.cookingTimeInMinutes,
        servingCount: servingCount ?? this.servingCount,
        description: description ?? this.description,
        ingredients: ingredients![0],
        instructions: instructions![0],
        ownerId: ownerId ?? this.ownerId,
        recipeId: recipeId ?? this.recipeId,
        createdOn: createdOn ?? this.createdOn,
        recipeCoverURL: recipeCoverURL ?? this.recipeCoverURL,
        reports: reports ?? this.reports);
  }

  @override
  String toString() {
    return 'RecipeModel(recipeName: $recipeName, cookingTimeInMinutes: $cookingTimeInMinutes, servingCount: $servingCount, description: $description, ingredients: $ingredients, instructions: $instructions, ownerId: $ownerId, recipeId: $recipeId, createdOn: $createdOn, recipeCoverURL: $recipeCoverURL, indexedInSearch: $indexedInSearch, postCount: $postCount, likeCount: $likeCount)';
  }

  bool get isDefaultImage => this.recipeCoverURL == defaultRecipeImage;
}
