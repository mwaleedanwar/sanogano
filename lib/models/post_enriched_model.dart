import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/models/user.dart';

class EnrichedPostModel {
  late PostModel post;
  late UserModel owner;
  late bool isLiked;
  late bool isSaved;

  EnrichedPostModel(
      {required this.post,
      required this.owner,
      required this.isLiked,
      required this.isSaved});
}
