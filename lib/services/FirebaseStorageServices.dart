import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

class FirebaseStorageServices {
  /// Uploads the given file (Preferably image/video/audio) to firebase storage and returns a long lived URL, provided path is [folderName]/file${DateTime.now().millisecondsSinceEpoch
  static Future<String> uploadToStorage(
      {required File file,
      bool dataMode = false,
      required String folderName,
      required bool isVideo}) async {
    try {
      //TODO need borjan's help with file extension handling
      final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
            '$folderName/file${DateTime.now().millisecondsSinceEpoch}',
          );
      // if (isVideo) {
      //   file = (await compressVideoFile(file)) ?? file;
      // } else {
      //   file =
      //       (await FirebaseStorageServices().compressImageFile(file)) ?? file;
      // }
      final UploadTask uploadTask = firebaseStorageRef.putFile(file);

      final TaskSnapshot downloadUrl = await uploadTask;

      String url = await downloadUrl.ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      print(e.stackTrace);
      return "";
    }
  }

  static Future<String> uploadToStorageAsData(
      {required Uint8List file,
      required String folderName,
      required bool isVideo}) async {
    try {
      //TODO need borjan's help with file extension handling
      final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
            '$folderName/file${DateTime.now().millisecondsSinceEpoch}',
          );
      // if (isVideo) {
      //   file = (await compressVideoFile(file)) ?? file;
      // } else {
      //   file =
      //       (await FirebaseStorageServices().compressImageFile(file)) ?? file;
      // }
      final UploadTask uploadTask = firebaseStorageRef.putData(file);

      final TaskSnapshot downloadUrl = await uploadTask;

      String url = await downloadUrl.ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      print(e.stackTrace);
      return "";
    }
  }

  static Future<String> uploadToStorageAndGetRef(
      {required File file, required String folderName, bool? isVideo}) async {
    try {
      //TODO need borjan's help with file extension handling
      final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
            '$folderName/file${DateTime.now().millisecondsSinceEpoch}',
          );

      final UploadTask uploadTask = firebaseStorageRef.putFile(file);

      final TaskSnapshot downloadUrl = await uploadTask;

      String url = "gs://" + downloadUrl.ref.fullPath;
      return url;
    } on FirebaseException catch (e) {
      print(e.stackTrace);
      return "";
    }
  }

  Future<File?> compressImageFile(
    File file,
  ) async {
    print(file.absolute.path);
    String targetPath = (await getTemporaryDirectory()).path;
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
      keepExif: false,
    );

    return result;
  }

  static Future<File?> compressVideoFile(File file) async {
    // String path = (await getTemporaryDirectory()).path;
    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      file.path,
      includeAudio: true,

      quality: VideoQuality.MediumQuality,
      deleteOrigin: false, // It's false by default
    );
    if (mediaInfo != null) {
      return mediaInfo.file;
    }
    return null;
  }
}
