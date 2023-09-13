import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A widget that displays the subtitle for [StreamChannelListTile].
class CustomChannelListTileSubtitle extends StatelessWidget {
  /// Creates a new instance of [StreamChannelListTileSubtitle] widget.
  CustomChannelListTileSubtitle({
    super.key,
    required this.channel,
    this.textStyle,
  }) : assert(
          channel.state != null,
          'Channel ${channel.id} is not initialized',
        );

  /// The channel to create the subtitle from.
  final Channel channel;

  /// The style of the text displayed
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (channel.isMuted) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          StreamSvgIcon.mute(size: 16),
          Text(
            '  ${context.translations.channelIsMutedText}',
            style: textStyle,
          ),
        ],
      );
    }
    return StreamTypingIndicator(
      channel: channel,
      style: textStyle,
      alternativeWidget: CustomChannelLastMessageText(
        channel: channel,
        textStyle: textStyle,
      ),
    );
  }
}

/// A widget that displays the last message of a channel.
class CustomChannelLastMessageText extends StatefulWidget {
  /// Creates a new instance of [CustomChannelLastMessageText] widget.
  CustomChannelLastMessageText({
    super.key,
    required this.channel,
    this.textStyle,
  }) : assert(
          channel.state != null,
          'Channel ${channel.id} is not initialized',
        );

  /// The channel to display the last message of.
  final Channel channel;

  /// The style of the text displayed
  final TextStyle? textStyle;

  @override
  State<CustomChannelLastMessageText> createState() =>
      _CustomChannelLastMessageTextState();
}

class _CustomChannelLastMessageTextState
    extends State<CustomChannelLastMessageText> {
  Message? _lastMessage;

  @override
  Widget build(BuildContext context) => BetterStreamBuilder<List<Message>>(
        stream: widget.channel.state!.messagesStream,
        initialData: widget.channel.state!.messages,
        builder: (context, messages) {
          final lastMessage = messages.lastWhereOrNull(
            (m) => !m.shadowed && !m.isDeleted,
          );

          if (widget.channel.state?.isUpToDate == true) {
            _lastMessage = lastMessage;
          }

          if (_lastMessage == null) return const Offstage();

          return CustomStreamMessagePreviewText(
            message: _lastMessage!,
            textStyle: widget.textStyle,
            language: widget.channel.client.state.currentUser?.language,
          );
        },
      );
}

/// A widget that renders a preview of the message text.
class CustomStreamMessagePreviewText extends StatelessWidget {
  /// Creates a new instance of [CustomStreamMessagePreviewText].
  const CustomStreamMessagePreviewText({
    super.key,
    required this.message,
    this.language,
    this.textStyle,
  });

  /// The message to display.
  final Message message;

  /// The language to use for translations.
  final String? language;

  /// The style to use for the text.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final messageText = message
        .translate(language ?? 'en')
        .replaceMentions(linkify: false)
        .text;
    final messageAttachments = message.attachments;
    final messageMentionedUsers = message.mentionedUsers;

    final mentionedUsersRegex = RegExp(
      messageMentionedUsers.map((it) => '@${it.name}').join('|'),
      caseSensitive: false,
    );

    final messageTextParts = [
      ...messageAttachments.map((it) {
        if (it.type == 'image') {
          return '';
        } else if (it.type == 'video') {
          return '';
        } else if (it.type == 'giphy') {
          return '';
        }
        // return it == message.attachments.last
        //     ? (it.title ?? '')
        //     : '${it.title ?? ''} , ';
      }),
      if (messageText != null)
        if (messageMentionedUsers.isNotEmpty)
          ...mentionedUsersRegex.allMatchesWithSep(messageText)
        else
          messageText,
    ];

    final fontStyle = (message.isSystem || message.isDeleted)
        ? FontStyle.italic
        : FontStyle.normal;

    final regularTextStyle = textStyle?.copyWith(fontStyle: fontStyle);

    final mentionsTextStyle = textStyle?.copyWith(
      fontStyle: fontStyle,
      fontWeight: FontWeight.bold,
    );

    final spans = [
      for (final part in messageTextParts)
        if (messageMentionedUsers.isNotEmpty &&
            messageMentionedUsers.any((it) => '@${it.name}' == part))
          TextSpan(
            text: part,
            style: mentionsTextStyle,
          )
        else if (messageAttachments.isNotEmpty &&
            messageAttachments
                .where((it) => it.title != null)
                .any((it) => it.title == part))
          TextSpan(
            text: part,
            style: regularTextStyle?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          )
        else
          TextSpan(
            text: part,
            style: regularTextStyle,
          ),
    ];

    return Text.rich(
      TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
    );
  }
}

extension _RegExpX on RegExp {
  List<String> allMatchesWithSep(String input, [int start = 0]) {
    final result = <String>[];
    for (final match in allMatches(input, start)) {
      result.add(input.substring(start, match.start));
      // ignore: cascade_invocations
      result.add(match[0]!);
      // ignore: parameter_assignments
      start = match.end;
    }
    result.add(input.substring(start));
    return result;
  }
}
