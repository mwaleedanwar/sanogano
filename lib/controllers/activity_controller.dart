import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/notificationModel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/utils/database.dart';

import 'auth_controller.dart';

class ActivityController extends GetxController {
  Rx<List<NotificationModel>?> _activityList = Rx<List<NotificationModel>?>([]);
  List<NotificationModel>? get activityList => _activityList.value;
  set activityListSetter(List<NotificationModel>? value) =>
      _activityList.value = value;
  Rx<List<DetailedNotificationModel>?> _detailedActivityList =
      Rx<List<DetailedNotificationModel>?>([]);
  List<DetailedNotificationModel>? get detailedActivityList =>
      _detailedActivityList.value;
  set detailedActivityListSetter(List<DetailedNotificationModel>? value) =>
      _detailedActivityList.value = value;
  RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  RxInt _totalActivitiesLoaded = 0.obs;
  int get totalActivitiesLoaded => _totalActivitiesLoaded.value;
  RxInt _totalActivitiesInDb = 0.obs;
  int get totalActivitiesInDb => _totalActivitiesInDb.value;
  Database db = Database();
  String uid = Get.find<AuthController>().user!.uid;

  bool get hasMore => totalActivitiesLoaded < totalActivitiesInDb;
  RxBool _isActivityLoading = false.obs;
  bool get isActivityLoading => _isActivityLoading.value;

  DocumentSnapshot? lastDoc;
  Future<void> fetchActivities({bool isRefresh = false}) async {
    _isActivityLoading.value = true;
    if (isRefresh) {
      _isLoading.value = true;
    }
    List<NotificationModel>? activities = [];
    log("fetching activities on initial level");
    log(uid);
    var query =
        db.appActivityHistoryQuery(uid).orderBy('timestamp', descending: true);

    if (lastDoc != null && !isRefresh) {
      query = query.startAfterDocument(lastDoc!);
    }

    var docs =
        await query.limit(isRefresh ? totalActivitiesLoaded + 15 : 15).get();
    if (docs.docs.isEmpty) {
      _isActivityLoading.value = false;
      _isLoading.value = false;
      return;
    }
    lastDoc = docs.docs.last;
    _totalActivitiesLoaded.value = isRefresh
        ? docs.docs.length
        : _totalActivitiesLoaded.value + docs.docs.length;
    if (docs.docs.isNotEmpty) {
      for (var activity in docs.docs) {
        activities.add(
            NotificationModel.fromMap(activity.data() as Map<String, dynamic>));
      }
    }
    if (activities.isNotEmpty) {
      _activityList.value = [...activityList!, ...activities];

      log(activities.length.toString());
      await getActivityDetails(notificationList: activities);
    }
    _isActivityLoading.value = false;
    _isLoading.value = false;
  }

  Future<void> refreshActivity() async {
    detailedActivityListSetter = [];
    activityListSetter = [];
    await fetchActivities(isRefresh: true);
  }

  Stream<int> checkIfHasMoreActivity() {
    return db
        .appActivityHistoryQuery(uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((event) {
      return event.docs.length;
    });
  }

  @override
  void onInit() {
    _totalActivitiesInDb.bindStream(checkIfHasMoreActivity());
    // _activityList.bindStream(getActivities);
    // ever<List<NotificationModel>?>(_activityList, (val) async {
    //   if (val == [] || val!.isEmpty) {
    //     _detailedActivityList.value = [];
    //   } else {
    //     await getActivityList();
    //   }
    // });
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    await fetchActivities();

    super.onReady();
  }

  Future<void> getActivityDetails(
      {required List<NotificationModel> notificationList}) async {
    // _detailedActivityList.value = [];

    for (var notification in notificationList) {
      UserModel? sender = await db.getUser(notification.senderUid!);
      DetailedNotificationModel detailedNotificationModel =
          DetailedNotificationModel(
        notificationModel: notification,
        sender: sender!,
      );
      _detailedActivityList.value!.add(detailedNotificationModel);
    }
  }
}
