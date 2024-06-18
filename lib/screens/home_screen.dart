import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talkify/screens/profile_screen.dart';
import 'package:talkify/widgets/chat_card.dart';

import '../api/apis.dart';
import '../modals/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.updateActiveStatus(true);
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('pause'))
          APIs.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: !_isSearching,
        onPopInvoked: (_) {
          if (_isSearching) {
            setState(() => _isSearching = !_isSearching);
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey.shade600,
          appBar: AppBar(
            backgroundColor: Colors.grey.shade600,
            centerTitle: true,
            title: !_isSearching
                ? Text(
                    'Talkify',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  )
                : TextField(
                    autofocus: true,
                    style: TextStyle(fontSize: 18),
                    onChanged: (val) {
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search name or email',
                      hintStyle: TextStyle(
                          color: Colors.grey[400], letterSpacing: 0.5),
                    ),
                  ),
            actions: [
              IconButton(
                onPressed: () {
                  _searchList.clear();
                  setState(() {
                    _isSearching = !_isSearching;
                    _searchList;
                  });
                },
                icon: Icon(
                  !_isSearching ? Icons.search : Icons.clear,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        user: APIs.me,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              elevation: 10,
              backgroundColor: Colors.grey.shade800,
              onPressed: () {
                _addChatUserDialog();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Icon(
                Icons.add,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {
                      var _connectionState = snapshot.connectionState;
                      if (_connectionState == ConnectionState.waiting ||
                          _connectionState == ConnectionState.none) {
                        // Center(child: CircularProgressIndicator());
                      } else if (_connectionState == ConnectionState.active ||
                          _connectionState == ConnectionState.done) {
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => ChatUser.fromJson(e.data()))
                                .toList() ??
                            [];
                      }
                      if (_list.isNotEmpty) {
                        return ListView.builder(
                          itemCount:
                              _isSearching ? _searchList.length : _list.length,
                          padding: EdgeInsets.only(top: 10),
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ChatCard(
                              user: _isSearching
                                  ? _searchList[index]
                                  : _list[index],
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
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade300,
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        //title
        title: const Row(
          children: [
            Icon(
              Icons.person_add,
              color: Color(0xFF212121),
              size: 28,
            ),
            Text(
              '  Add User',
              style: TextStyle(
                color: Color(0xFF212121),
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),

        //content
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            hintText: 'Email Id',
            prefixIcon: const Icon(
              Icons.email,
              color: Color(0xFF212121),
            ),
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
            onPressed: () async {
              Navigator.pop(context);
              if (email.isNotEmpty) {
                await APIs.addChatUser(email).then(
                  (value) {
                    if (!value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'User does not Exists!',
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
