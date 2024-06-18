import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talkify/modals/chat_user.dart';
import 'package:talkify/screens/others_profile_screen.dart';
import 'package:talkify/widgets/message_card.dart';

import '../api/apis.dart';
import '../main.dart';
import '../modals/messages.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _showEmoji = false;
  bool _imageIsUploading = false;
  List<MessageClass> _list = [];
  final _textController = TextEditingController();
  SmartReplySuggestionResult? _suggestions;
  final SmartReply _smartReply = SmartReply();

  @override
  void dispose() {
    _smartReply.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: PopScope(
            canPop: !_showEmoji,
            onPopInvoked: (_) async {
              if (_showEmoji) {
                setState(() => _showEmoji = !_showEmoji);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              backgroundColor: Colors.grey.shade600,
              appBar: AppBar(
                backgroundColor: Colors.grey.shade300,
                automaticallyImplyLeading: false,
                flexibleSpace: _AppBar(),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        // getSuggestions(APIs.getAllMessages(widget.user));
                        // debugPrint('PRINT ZALA: ${suggestions}');
                        var _connectionState = snapshot.connectionState;
                        if (_connectionState == ConnectionState.waiting ||
                            _connectionState == ConnectionState.none) {
                          return SizedBox();
                        } else if (_connectionState == ConnectionState.active ||
                            _connectionState == ConnectionState.done) {
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => MessageClass.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: 10),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: Text(
                                'No connections found!',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                            );
                          }
                        }
                        return Center(
                          child: Text(
                            'Something went wrong!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  //   child: (suggestions.isNotEmpty)
                  //       ? Row(children: [
                  //           chip(suggestions[0]),
                  //           const SizedBox(width: 5),
                  //           chip(suggestions[1]),
                  //           const SizedBox(width: 5),
                  //           chip(suggestions[2]),
                  //         ])
                  //       : Container(),
                  // ),
                  if (_suggestions != null)
                    Text('Status: ${_suggestions!.status.name}'),
                  if (_suggestions != null &&
                      _suggestions!.suggestions.isNotEmpty)
                    for (final suggestion in _suggestions!.suggestions)
                      Text('\t $suggestion'),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (_smartReply.conversation.isNotEmpty)
                          ElevatedButton(
                              onPressed: () {
                                _smartReply.clearConversation();
                                setState(() {
                                  _suggestions = null;
                                });
                              },
                              child: Text('Clear conversation')),
                        ElevatedButton(
                            onPressed: _suggestReplies,
                            child: Text('Get Suggest Replies')),
                      ]),
                  if (_imageIsUploading) CircularProgressIndicator(),
                  _chatInput(),
                  if (_showEmoji)
                    SizedBox(
                      height: mq.height * 0.35,
                      child: EmojiPicker(
                        textEditingController: _textController,
                        config: Config(
                          height: 256,
                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(
                            emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _AppBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OthersProfileScreen(
                      user: widget.user,
                    )));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
          return Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey.shade900,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.04),
                  child: CachedNetworkImage(
                    width: mq.width * 0.11,
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(
                        Icons.person,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: mq.width * 0.03),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive)
                        : getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive),
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chatInput() {
    return Row(
      children: [
        Container(
          child: IconButton(
            onPressed: () {
              _selectImageFrom();
            },
            icon: Icon(
              Icons.add,
              color: Colors.grey.shade900,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: TextField(
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onTap: () {
                if (_showEmoji)
                  setState(() {
                    _showEmoji = !_showEmoji;
                  });
              },
              decoration: InputDecoration(
                fillColor: Colors.grey.shade300,
                hintText: 'Type a message',
                hintStyle: TextStyle(
                  color: Colors.grey.shade600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _showEmoji = !_showEmoji;
                    });
                  },
                  icon: Icon(
                    Icons.emoji_emotions,
                    color: Colors.grey.shade900,
                  ),
                ),
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              ),
            ),
          ),
        ),
        IconButton(
          color: Colors.green,
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              if (_list.isEmpty) {
                APIs.sendFirstMessage(
                    widget.user, _textController.text, Type.text);
              } else {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
              }
              // print('${_list[0].msg}');
              if (widget.user.id == _list[0].fromId)
                _addMessage(_textController, false);
              else
                _addMessage(_textController, true);
              _textController.clear();
            }
          },
          icon: Icon(Icons.send),
        ),
      ],
    );
  }

  void _selectImageFrom() {
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: mq.height * 0.025),
                    child: Text(
                      'Select Image ',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final List<XFile> images =
                                await picker.pickMultiImage();
                            for (var selectedImage in images) {
                              setState(() {
                                _imageIsUploading = true;
                              });
                              await APIs.sendChatImage(
                                  widget.user, File(selectedImage.path));
                            }
                            setState(() {
                              _imageIsUploading = false;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(mq.width * 0.1),
                            ),
                            fixedSize: Size(mq.width * 0.4, mq.height * 0.2),
                          ),
                          child: Image.asset('images/add_image.png'),
                        ),
                        SizedBox(height: mq.width * 0.05),
                        ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (image != null) {
                              setState(() {
                                _imageIsUploading = true;
                              });
                              await APIs.sendChatImage(
                                  widget.user, File(image.path));
                              setState(() {
                                _imageIsUploading = false;
                              });
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(mq.width * 0.1),
                            ),
                            fixedSize: Size(mq.width * 0.4, mq.height * 0.2),
                          ),
                          child: Image.asset('images/camera.png'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String getLastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;

    //if time is not available then return below statement
    if (i == -1) return 'Last seen not available';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == time.year) {
      return 'Last seen today at $formattedTime';
    }

    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'Last seen yesterday at $formattedTime';
    }

    String month = _getMonth(time);

    return 'Last seen on ${time.day} $month at $formattedTime';
  }

  // get month name from month no. or index
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

  Widget chip(String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          APIs.sendMessage(widget.user, label, Type.text);
        },
        child: Chip(
          label: Center(
            child: Text(label),
          ),
        ),
      ),
    );
  }

  void _addMessage(TextEditingController controller, bool localUser) {
    FocusScope.of(context).unfocus();
    if (controller.text.isNotEmpty) {
      if (localUser) {
        _smartReply.addMessageToConversationFromLocalUser(
            controller.text, DateTime.now().millisecondsSinceEpoch);
      } else {
        _smartReply.addMessageToConversationFromRemoteUser(controller.text,
            DateTime.now().millisecondsSinceEpoch, widget.user.id);
      }
      controller.text = '';
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message added to the conversation')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Message can\'t be empty')));
    }
  }

  Future<void> _suggestReplies() async {
    FocusScope.of(context).unfocus();
    final result = await _smartReply.suggestReplies();
    setState(() {
      _suggestions = result;
    });
    for (final suggestion in result.suggestions) {
      print('SUGGESTION: $suggestion');
    }
  }
}
