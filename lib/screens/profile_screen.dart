import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talkify/modals/chat_user.dart';
import 'package:talkify/screens/auth/login_screen.dart';

import '../api/apis.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade600,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade600,
          elevation: 1,
          centerTitle: true,
          title: Text(
            'Profile Screen',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            onPressed: () async {
              await APIs.updateActiveStatus(false);
              await APIs.auth.signOut();
              await GoogleSignIn().signOut().then((value) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginScreen()));
              });
              APIs.auth = FirebaseAuth.instance;
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: Icon(Icons.logout),
            label: Text(
              'Logout',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: mq.height * 0.04,
                ),
                Stack(
                  children: [
                    _image != null
                        ? Center(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.1),
                              child: Image.file(
                                File(_image!),
                                height: mq.height * 0.2,
                                width: mq.width * 0.4,
                                fit: BoxFit.fill,
                              ),
                            ),
                          )
                        : Center(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.1),
                              child: CachedNetworkImage(
                                height: mq.height * 0.2,
                                width: mq.width * 0.4,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(child: Icon(Icons.person)),
                              ),
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      left: mq.width * 0.55,
                      child: IconButton(
                        onPressed: () {
                          _selectProfilePicFrom();
                        },
                        style: ButtonStyle(
                          shape: MaterialStatePropertyAll(
                            CircleBorder(),
                          ),
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.grey.shade100),
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.grey.shade900),
                        ),
                        icon: Icon(
                          Icons.edit,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: mq.height * 0.03,
                ),
                Text(
                  widget.user.email,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.03,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Name Required',
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      prefixIconColor: Colors.grey.shade900,
                      label: Text(
                        'Name',
                        style: TextStyle(
                          color: Colors.grey.shade100,
                        ),
                      ),
                      hintText: 'eg. Ram Sharma',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.grey.shade100,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.03,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'About Required',
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.info),
                      prefixIconColor: Colors.grey.shade900,
                      label: Text(
                        'About',
                        style: TextStyle(
                          color: Colors.grey.shade100,
                        ),
                      ),
                      hintText: 'eg. Feeling Happy',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.grey.shade100,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.05,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      APIs.updateUserInfo().then(
                        (value) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.thumb_up,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Profile Updated Successfully!',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStatePropertyAll(
                      Size(
                        mq.width * 0.5,
                        mq.height * 0.06,
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.grey.shade800),
                    foregroundColor:
                        MaterialStatePropertyAll(Colors.grey.shade100),
                  ),
                  icon: Icon(
                    Icons.edit,
                  ),
                  label: Text(
                    'Update',
                    style: TextStyle(fontSize: 19),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectProfilePicFrom() {
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
                      padding:
                          EdgeInsets.symmetric(vertical: mq.height * 0.025),
                      child: Text(
                        'Pick Profile Picture',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (image != null) {
                              setState(() {
                                _image = image.path;
                              });
                              APIs.updateProfilePicture(File(_image!));
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
                          child: Image.asset('images/add_image.png'),
                        ),
                        SizedBox(width: mq.width * 0.05),
                        ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera);
                            if (image != null) {
                              setState(() {
                                _image = image.path;
                              });
                              APIs.updateProfilePicture(File(_image!));
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
                    SizedBox(
                      height: mq.height * 0.03,
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
