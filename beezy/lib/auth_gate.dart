import 'dart:math';

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
              {'email': user.email, 'points': 0, 'step': 0, 'hasWon' : false},
            );
            CollectionReference info =
                usersCollection.doc(user.uid).collection("PMTinfo");
            CollectionReference columns =
                info.doc(info.id).collection("columns");
            columns.add({
              'columnTitle': 'To Do',
              'displayOrder': 0,
              'isKey': false,
              'isEditingText': false
            });
            columns.add({
              'columnTitle': 'In Progress',
              'displayOrder': 1,
              'isKey': false,
              'isEditingText': false
            });
            columns.add({
              'columnTitle': 'Done',
              'displayOrder': 2,
              'isKey': true,
              'isEditingText': false
            });
            info.doc(info.id).set({'columnID': 0});

            CollectionReference honeyRush =
                usersCollection.doc(user.uid).collection("honeyRush");
            CollectionReference profiles =
                honeyRush.doc(honeyRush.id).collection("profiles");
            profiles.add({
              'name': 'Laura',
              'avatarTypePath': 'assets/bee_avatar_2.png',
              'lifes': Random().nextInt(3) + 1,
              'playedCards': Random().nextInt(4),
              'hasHoneyFever': false,
              'daysPassed': 0
            });
            profiles.add({
              'name': 'Pol',
              'avatarTypePath': 'assets/bee_avatar_3.png',
              'lifes': Random().nextInt(3) + 1,
              'playedCards': Random().nextInt(4),
              'hasHoneyFever': false,
              'daysPassed': 0
            });
            profiles.add({
              'name': 'Laia',
              'avatarTypePath': 'assets/bee_avatar_4.png',
              'lifes': Random().nextInt(3) + 1,
              'playedCards': Random().nextInt(4),
              'hasHoneyFever': false,
              'daysPassed': 0
            });
            profiles.add({
              'name': 'Júlia',
              'avatarTypePath': 'assets/bee_avatar_5.png',
              'lifes': Random().nextInt(3) + 1,
              'playedCards': Random().nextInt(4),
              'hasHoneyFever': false,
              'daysPassed': 0
            });
            profiles.add({
              'name': 'Biel',
              'avatarTypePath': 'assets/bee_avatar_6.png',
              'lifes': Random().nextInt(3) + 1,
              'playedCards': Random().nextInt(4),
              'hasHoneyFever': false,
              'daysPassed': 0
            });
            profiles.add({
              'name': 'Nora',
              'avatarTypePath': 'assets/bee_avatar_7.png',
              'lifes': Random().nextInt(3) + 1,
              'playedCards': Random().nextInt(4),
              'hasHoneyFever': false,
              'daysPassed': 0
            });
            honeyRush.doc(honeyRush.id).set({
              'daytime': true,
              'hasRolled': false,
              'isRolling': false,
              'temporaryNectar': 0,
              'nectar': 0,
              'honey' : Random().nextInt(21) + 65,
              'diaryText' : 'Write your thoughts...',
              'narrativeSpot' : Random().nextInt(4),
              'card1' : 0,
              'card2' : 0,
              'card3' : 0,
              'cardSlot1' : false,
              'cardSlot2' : false,
              'cardSlot3' : false,
              'isCarding' : false,
              'playedCardsNum' : 0
            });
            CollectionReference beebo =
                usersCollection.doc(user.uid).collection("beebo");
                beebo.doc(beebo.id).set({
              'food' : Random().nextDouble(),
              'hygiene' : Random().nextDouble(),
              'toys' : Random().nextDouble(),
              'sleep' : Random().nextDouble(),
              'selectedButtonIndex' : 0
            });
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
