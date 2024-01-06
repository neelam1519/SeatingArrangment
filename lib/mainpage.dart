import 'package:find_any_flutter/authpage.dart';
import 'package:find_any_flutter/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';




class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const Homepage();
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
