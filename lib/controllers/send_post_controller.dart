import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class SendPostController extends GetxController {
  final BuildContext context;
  SendPostController(this.context);

  Rx<TextEditingController> _fieldController =
      Rx<TextEditingController>(TextEditingController());

  TextEditingController get fieldController => _fieldController.value;

  RxBool _isSearchActive = false.obs;
  bool get isSearchActive => _isSearchActive.value;
  Rx<StreamMessageSearchListController?> _messageSearchListController =
      Rx<StreamMessageSearchListController?>(null);
  StreamMessageSearchListController? get messageSearchListController =>
      _messageSearchListController.value;
  Rx<StreamChannelListController?> _channelListController =
      Rx<StreamChannelListController?>(null);
  StreamChannelListController? get channelListController =>
      _channelListController.value;

  Rx<Set<Channel>> _selectedChannels = Rx<Set<Channel>>({});
  Set<Channel> get selectedChannels => _selectedChannels.value;
  RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  @override
  void onInit() {
    _messageSearchListController.value = StreamMessageSearchListController(
      client: StreamChat.of(context).client,
      filter: Filter.in_('members', [StreamChat.of(context).currentUser!.id]),
      limit: 5,
      searchQuery: '',
      sort: [
        SortOption(
          'created_at',
          direction: SortOption.ASC,
        ),
      ],
    );
    _channelListController.value = StreamChannelListController(
      client: StreamChat.of(context).client,
      filter: Filter.and([
        Filter.in_(
          'members',
          [StreamChat.of(context).currentUser!.id],
        ),
      ]),
      channelStateSort: const [SortOption('last_message_at')],
      // sort: const [SortOption('last_message_at')],
      presence: true,
      limit: 30,
    );
    fieldController.addListener(_handleChannelQuery);
    _isLoading.value = false;
    super.onInit();
  }

  void _handleChannelQuery() {
    EasyDebounce.debounce('send-post-debouncer', 350.milliseconds, () {
      messageSearchListController!.searchQuery = fieldController.text;
      _isSearchActive.value = fieldController.text.isNotEmpty;
      if (isSearchActive) {
        messageSearchListController!.doInitialLoad();
      }
    });
  }

  void addChannelToSelectedChannels(Channel channel) {
    print('addChannelToSelectedChannels');
    _selectedChannels.value.add(channel);
  }

  void removeChannelFromSelectedChannels(Channel channel) {
    print('removeChannelFromSelectedChannels');
    _selectedChannels.value.remove(channel);
  }

  @override
  void onClose() {
    fieldController.removeListener(_handleChannelQuery);
    fieldController.dispose();
    messageSearchListController?.dispose();
    channelListController?.dispose();
    super.onClose();
  }
}
