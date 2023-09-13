import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart' as ip;
import 'package:path_provider/path_provider.dart';
import 'package:sano_gano/services/FirebaseStorageServices.dart';
import 'package:sano_gano/video_editor/video_editor.dart';
import 'package:sano_gano/view/global/custom_icon.dart';
import 'package:sano_gano/view/pages/home/camera_page.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as videoThumbnail;
import 'package:get/get.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import 'package:image_cropper/image_cropper.dart';

import '../controllers/theme_controller.dart';

/// Image Picker service class with static methods to access directly
class ImagePickerServices {
  static final picker = ImagePicker();

  /// captures image and returns a [File]
  static Future<CameraResponse?> openCamera(BuildContext context) async {
    try {
      final AssetEntity? entity = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(),
      );

      if (entity != null) {
        var tData = await entity.thumbnailData;
        return CameraResponse(
          file: await entity.file,
          isVideo: entity.type == AssetType.video,
          thumbnail: tData == null ? null : File.fromRawPath(tData),
        );
      } else {
        print('No image selected.');
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /// captures image and returns a [File]
  static Future<File?> getImageFromCamera(bool squareMode,
      {bool landscape = false}) async {
    print("running camera image....");

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    return pickedFile == null ? null : File(pickedFile.path);

    // if (pickedFile != null) {
    //   print("running crop image....");
    //   var croppedImage = await cropImage(File(pickedFile.path),
    //       squareMode: squareMode, landscape: landscape);
    //   return croppedImage;
    // }
    // else {
    //   print('No image selected.');
    //   return null;
    // }
  }

  static Future<File?> getMediaFromGallery(
      {Function(CameraResponse)? responseCallback,
      Function(VideoEditingResponse)? videoResponseCallback,
      bool imagesOnly = false}) async {
    List<ip.Media>? res = await ip.ImagesPicker.pick(
      count: 1,
      cropOpt: ip.CropOption(
        cropType: ip.CropType.rect,
      ),
      maxTime: 60,
      // quality: 1,
      pickType: imagesOnly ? ip.PickType.image : ip.PickType.all,
      gif: true,
    );
    if (res == null || res.isEmpty) return null;

    if (responseCallback != null) {
      responseCallback(CameraResponse(
        isVideo: res.first.path.isVideo,
      ));
    }
    var pickedFile = File(res.first.path);
    if (res.first.path.isVideo) {
      var response = await Get.to<VideoEditingResponse>(VideoEditor(
        file: pickedFile,
      ));
      if (videoResponseCallback != null && response != null) {
        log("video dimenstions are ${response.videoDimensions}");
        videoResponseCallback(VideoEditingResponse(
            response.videoFile, response.videoDimensions,
            cover: response.cover));
      }
    }

    // File? croppedImage;
    // if (!(res.first.path.isVideo)) {
    //   // croppedImage = await cropImage(File(pickedFile.path),
    //   //     squareMode: true, landscape: true);
    // }

    return File(pickedFile.path);
    // print(res.first.path.isVideoFileName);
    // print(res.first.path.isImageFileName);
    // return File(res.first.path);
  }

  Future<VideoEditingResponse?> editVideo(File file) async {
    try {
      var response = await Get.to<VideoEditingResponse>(VideoEditor(
        file: file,
      ));
      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> getMediaFromCamera({
    Function(CameraResponse)? responseCallback,
  }) async {
    List<ip.Media>? res = await ip.ImagesPicker.openCamera(
      language: ip.Language.English,
      cropOpt: ip.CropOption(
        cropType: ip.CropType.rect,
      ),
      quality: 1,
      pickType: ip.PickType.image,
      maxTime: 15,
    );

    if (res!.isEmpty) return null;
    responseCallback!(CameraResponse(
        isVideo: res.first.path.isVideoFileName,
        file: File(res.first.thumbPath!)));
    var pickedFile = File(res.first.path);
    if (res.first.path.isVideoFileName) {
      pickedFile = await Get.to(VideoEditor(
        file: pickedFile,
      ));
    }

    return File(res.first.path);
// Media
// .path
// .thumbPath (path for video thumb)
// .size (kb)
  }

  /// captures video and returns a [File]
  static Future<File?> getVideoFromCamera() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.camera);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print('No image selected.');
      return null;
    }
  }

  /// get Image from gallery and returns a [File]
  static Future<File?> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print('No image selected.');
      return null;
    }
  }

  /// get Video from gallery and returns a [File]
  static Future<File?> getVideoFromGallery() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print('No image selected.');
      return null;
    }
  }

  /// get multiple images from gallery and returns a [File]
  static Future<List<XFile>?> getMultiImageFromGallery() async {
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 100, //stuff like this
    );

    if (pickedFiles.isNotEmpty) {
      return pickedFiles;
    } else {
      print('No image selected.');
      return null;
    }
  }

  /// get multiple images from gallery and returns a [File]
  static Future<List<File>> getImageAssets(BuildContext context,
      {bool squareMode = false, bool landscape = false}) async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.image,
          textDelegate: EnglishAssetPickerTextDelegate()),
    );
    List<File> listOfFiles = [];

    if (assets != null) {
      for (var element in assets) {
        var file = await element.file;
        File croppedFile =
            (await cropImage(file!, coverPhoto: false, profilePic: false)) ??
                file;

        listOfFiles.add(croppedFile);
      }
    }

    if (listOfFiles.isNotEmpty) {
      return listOfFiles;
    } else {
      print('No image selected.');
      return [];
    }
  }

  static Future<List<File?>> getVideoAssets(BuildContext context) async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          filterOptions: FilterOptionGroup(
              videoOption: FilterOption(
                  durationConstraint: DurationConstraint(
                      // max: Duration(seconds: 15),
                      ))),
          requestType: RequestType.video,
          textDelegate: EnglishAssetPickerTextDelegate()),
    );
    List<File?> listOfFiles = [];
    if (assets != null) {
      for (var element in assets) {
        listOfFiles.add(await element.file);
      }
    }
    await Get.to(VideoEditor(
      file: listOfFiles.first!,
    ));
    if (listOfFiles.isNotEmpty) {
      return listOfFiles;
    } else {
      print('No image selected.');
      return [];
    }
  }

  /// get recent images from gallery and returns a [File]
  Future<Uint8List?> getRecentlySavedImage() async {
    final albums = await PhotoManager.getAssetPathList(type: RequestType.all);
    final recentAlbum = albums.first;
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1, // end at a very big index (to get all the assets)
    );
    print(" got ${recentAssets.length} assets");
    return await recentAssets.first.originBytes;
  }

  static Future<File> getImageThumbnail(String url) async {
    final imgpath = await videoThumbnail.VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: videoThumbnail.ImageFormat.JPEG,
      maxHeight:
          512, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    return File(imgpath!);
  }

  static Future<File?> cropImage(File file,
      {required bool profilePic, required bool coverPhoto}) async {
    // return file;

    var croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        cropStyle: profilePic ? CropStyle.circle : CropStyle.rectangle,
        compressQuality: 100,
        aspectRatio: profilePic
            ? CropAspectRatio(ratioX: 4, ratioY: 4)
            : coverPhoto
                ? CropAspectRatio(ratioX: 16, ratioY: 5)
                : null,
        aspectRatioPresets: profilePic
            ? [CropAspectRatioPreset.ratio4x3]
            : coverPhoto
                ? [CropAspectRatioPreset.ratio16x9]
                : [
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9,
                    CropAspectRatioPreset.square,
                  ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.white,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        ]);
    // return file;
    if (croppedFile == null) {
      return null;
    }
    return File(croppedFile.path);
  }

  static Future<String> pickAndUpload() async {
    var img = await getMediaFromGallery(
      imagesOnly: true,
    );
    var fb = await FirebaseStorageServices.uploadToStorage(
        isVideo: false, file: img!, folderName: "GroupChats");
    return fb;
  }

  static Future<List<File>> getMediaAsset(
      BuildContext context, Function(bool) isVideo) async {
    print("getting media");
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
            maxAssets: 1,
            filterOptions: FilterOptionGroup(
                videoOption: FilterOption(
                    durationConstraint: DurationConstraint(
              max: Duration(seconds: 15),
            ))),
            requestType: RequestType.common,
            themeColor: Color(Get.find<ThemeController>().globalColor),
            textDelegate: EnglishAssetPickerTextDelegate()));
    List<File> listOfFiles = [];
    if (assets != null) {
      for (var element in assets) {
        var file = await element.file;
        listOfFiles.add(file!);
        print(file.path);
        isVideo(element.type == AssetType.video);
      }
    }

    if (listOfFiles.isNotEmpty) {
      return listOfFiles;
    } else {
      print('No image selected.');
      return [];
    }
  }

  static Future<GiphyGif?> getGif() async {
    GiphyGif? gif = await GiphyGet.getGif(
      context: Get.context!, //Required
      apiKey: Platform.isIOS
          ? "RDC1STU4vHsYmJGjsRtlEdxlZWdYOMPl"
          : "T7ssrBOfOqGeio4GInFH4H1lx9HzeAzz", //Required.

      lang: GiphyLanguage.english, //Optional - Language for query.
      randomID: "abcd", // Optional - An ID/proxy for a specific user.
      searchText: "Search GIPHY", //Optional - AppBar search hint text.
      tabColor: Color(Get.find<ThemeController>()
          .globalColor), // Optional- default accent color.
    );
    if (gif != null)
      return gif;
    else
      return null;

    // var result = await ImagePickerServices
    //     .getMediaFromGallery(imagesOnly: true);
  }
}

extension VideoExtensions on String {
  bool get isVideo {
    var list = [
      '.WEBM',
      '.MPG',
      '.MP2',
      '.MPEG',
      '.MPE',
      '.MPV',
      '.OGG',
      '.MP4',
      '.M4P',
      '.M4V',
      '.AVI',
      '.WMV',
      '.MOV',
      '.QT',
      '.FLV',
      '.SWF',
      'AVCHD',
    ];
    for (var element in list) {
      if (this.toLowerCase().endsWith(element.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}
