import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class AuthGate extends StatelessWidget {
  final Widget app;
  const AuthGate({Key? key, required this.app}) : super(key: key);

  void addUser() {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection("/users");

    final user = FirebaseAuth.instance.currentUser!;

    FirebaseFirestore.instance
        .runTransaction((transaction) async {
          DocumentSnapshot userDocSnapshot =
              await usersCollection.doc(user.uid).get();

          if (!userDocSnapshot.exists) {
            transaction.set(
              usersCollection.doc(user.uid),
              {'email': user.email},
            );
          }
        })
        .then((value) => print('User document created successfully'))
        .catchError((error) => print('Failed to create user document: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: SignInScreen(
              providerConfigs: [
                EmailProviderConfiguration(),
              ],
            ),
          );
        }
        addUser();
        return app;
      },
    );
  }
}
