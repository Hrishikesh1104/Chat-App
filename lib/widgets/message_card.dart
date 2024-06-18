import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:talkify/api/apis.dart';

import '../main.dart';
import '../modals/messages.dart';

class MessageCard extends StatefulWidget {
  final MessageClass message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _ourMessage() : _senderMessage(),
    );
  }

  Widget _senderMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: mq.width * 0.75),
          child: Container(
            padding: EdgeInsets.all(mq.width * 0.03),
            margin: EdgeInsets.symmetric(
                vertical: mq.height * 0.01, horizontal: mq.width * .04),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(15),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade300),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
        Text(
          TimeOfDay.fromDateTime(DateTime.fromMicrosecondsSinceEpoch(
                  int.parse(widget.message.sent)))
              .format(context),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade900),
        ),
      ],
    );
  }

  Widget _ourMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          TimeOfDay.fromDateTime(DateTime.fromMicrosecondsSinceEpoch(
                  int.parse(widget.message.sent)))
              .format(context),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade900),
        ),
        if (widget.message.read.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Icon(
              Icons.done_all,
              size: 20,
              color: Colors.blue,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Icon(
              Icons.done_all,
              size: 20,
              color: Colors.black54,
            ),
          ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: mq.width * 0.75),
          child: Container(
            padding: EdgeInsets.all(mq.width * 0.03),
            margin: EdgeInsets.symmetric(
                vertical: mq.height * 0.01, horizontal: mq.width * .04),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(15),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade900),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            width: mq.width,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(mq.height * 0.05),
                topRight: Radius.circular(mq.height * 0.05),
              ),
            ),
            child: Wrap(
              children: [
                Column(
                  children: [
                    Container(
                      height: 4,
                      margin: EdgeInsets.symmetric(
                          vertical: mq.height * .015,
                          horizontal: mq.width * .4),
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    widget.message.type == Type.text
                        ? _OptionItem(
                            icon: const Icon(Icons.copy,
                                color: Color(0xFF212121), size: 26),
                            name: 'Copy Text',
                            onTap: () async {
                              await Clipboard.setData(
                                      ClipboardData(text: widget.message.msg))
                                  .then((value) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Message copied!'),
                                  ),
                                );
                              });
                            },
                          )
                        : _OptionItem(
                            icon: const Icon(Icons.download,
                                color: Color(0xFF212121), size: 26),
                            name: 'Save Image',
                            onTap: () async {
                              try {
                                await GallerySaver.saveImage(widget.message.msg,
                                        albumName: 'Talkify')
                                    .then((success) {
                                  Navigator.pop(context);
                                  if (success != null && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Image Successfully Saved!'),
                                      ),
                                    );
                                  }
                                });
                              } catch (e) {
                                log('ERROR: $e');
                              }
                            },
                          ),
                    if (isMe)
                      Divider(
                        color: Colors.black54,
                        endIndent: mq.width * .04,
                        indent: mq.width * .04,
                      ),
                    if (widget.message.type == Type.text && isMe)
                      _OptionItem(
                        icon: const Icon(Icons.edit,
                            color: Color(0xFF212121), size: 26),
                        name: 'Edit Message',
                        onTap: () {
                          Navigator.pop(context);
                          _showMessageUpdateDialog();
                        },
                      ),
                    if (isMe)
                      _OptionItem(
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.red, size: 26),
                        name: 'Delete Message',
                        onTap: () async {
                          await APIs.deleteMessage(widget.message).then(
                            (value) {
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    Divider(
                      color: Colors.black54,
                      endIndent: mq.width * .04,
                      indent: mq.width * .04,
                    ),
                    _OptionItem(
                        icon: const Icon(Icons.remove_red_eye,
                            color: Color(0xFF212121)),
                        name:
                            'Sent At: ${_getMessageTime(context: context, time: widget.message.sent)}',
                        onTap: () {}),
                    _OptionItem(
                        icon: const Icon(Icons.remove_red_eye,
                            color: Colors.blue),
                        name: widget.message.read.isEmpty
                            ? 'Read At: Not seen yet'
                            : 'Read At: ${_getMessageTime(context: context, time: widget.message.read)}',
                        onTap: () {}),
                  ],
                ),
              ],
            ),
          );
        });
  }

  static String _getMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return formattedTime;
    }

    return now.year == sent.year
        ? '$formattedTime - ${sent.day} ${_getMonth(sent)}'
        : '$formattedTime - ${sent.day} ${_getMonth(sent)} ${sent.year}';
  }

  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sept';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade300,
        contentPadding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.message,
              color: Color(0xFF212121),
              size: 28,
            ),
            Text(
              '  Update Message',
              style: TextStyle(
                letterSpacing: 0,
                color: Color(0xFF212121),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value) => updatedMsg = value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              APIs.updateMessage(widget.message, updatedMsg);
            },
            child: const Text(
              'Update',
              style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
