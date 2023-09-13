import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/stream_feed_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/view/widgets/post_widget.dart';
import 'package:stream_feed/stream_feed.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({
    required this.currentUser,
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  final StreamUser currentUser;
  final ScrollController scrollController;

  @override
  _TimelineScreenState createState() => _TimelineScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<StreamUser>('currentUser', currentUser));
  }
}

class _TimelineScreenState extends State<TimelineScreen> {
  var sfc = Get.find<StreamFeedController>();
  var uc = Get.find<UserController>();
  late StreamFeedClient _client;
  bool _isLoading = true;
  List<GenericEnrichedActivity> activities = <GenericEnrichedActivity>[];

  late final Subscription _feedSubscription;

  Future<void> _listenToFeed() async {
    _feedSubscription = await sfc.timelineFeed!
        // ignore: avoid_print
        .subscribe(print);
  }

  Future<void> _loadActivities({bool pullToRefresh = false}) async {
    if (!pullToRefresh) setState(() => _isLoading = true);
    final userFeed = sfc.timelineFeed!;
    final data = await userFeed.getEnrichedActivities();
    if (!pullToRefresh) _isLoading = false;
    setState(() => activities = data);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _client = sfc.feedClient;
    _listenToFeed();
    _loadActivities();
  }

  @override
  void dispose() {
    super.dispose();
    _feedSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadActivities(pullToRefresh: true),
        child: _isLoading
            ? Center(child: Container())
            : activities.isEmpty
                ? Container()
                : ListView.builder(
                    // controller: widget.scrollController,
                    physics: BouncingScrollPhysics(),
                    addAutomaticKeepAlives: true,

                    itemCount: activities.length,
                    // padding: const EdgeInsets.symmetric(vertical: 16),
                    // separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, index) {
                      final activity = activities[index];
                      var post =
                          PostModel.fromActivity(activityEnriched: activity);
                      return PostWidget(
                        postModel: post,
                        postId: post.postId,
                      );
                    },
                  ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        IterableProperty<GenericEnrichedActivity>('activities', activities));
  }
}
