import 'package:fridge_it/ui/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fridge_it/ui/home/main_home.dart';
import 'package:flutter/material.dart';

class CheckUserState extends StatefulWidget {
  const CheckUserState({super.key});

  @override
  State<CheckUserState> createState() => _CheckUserStateState();
}

class _CheckUserStateState extends State<CheckUserState> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MainHome();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
