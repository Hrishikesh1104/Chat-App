import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/apis.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // bool _showLinearProgressIndicator = false;

  _googleButton() {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: CircularProgressIndicator(
          color: Colors.grey.shade300,
        ),
      ),
    );

    // setState(() {
    //   _showLinearProgressIndicator = true;
    // });
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        // print('\nUser: ${user.user}');
        // print('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        if (await APIs.userExists()) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          await APIs.createUser().then((value) => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen())));
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check your internet connection'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    }
    // finally {
    //   setState(() {
    //     _showLinearProgressIndicator = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'TALKIFY',
      //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      //   ),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade900,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 5,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        // margin: EdgeInsets.only(top: 90),
                        child: Image.asset('images/meetme.png'),
                      ),
                      Text(
                        'Talkify',
                        style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: IntrinsicWidth(
                  child: IntrinsicHeight(
                    // width: double.infinity,
                    // height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      onPressed: () {
                        _googleButton();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 13.0),
                            child: Image.asset(
                              'images/google.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                letterSpacing: 1.5,
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(text: 'Sign in with '),
                                TextSpan(
                                  text: 'Google',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
