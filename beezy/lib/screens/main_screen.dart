import 'dart:math';
import 'package:beezy/screens/avatar_screen.dart';
import 'package:beezy/screens/honey_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:beezy/screens/board_screen.dart';
import 'package:beezy/screens/backlog_screen.dart';
import 'package:beezy/models/board.dart';
import 'issues_screen.dart';

class MainScreen extends StatelessWidget {
  final String userUID;
  final String userEmail;
  final String title;

  const MainScreen(
      {Key? key,
      required this.userEmail,
      required this.userUID,
      required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userInfoSnapshot(userUID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error!);
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case ConnectionState.active:
            return _MainScreen(
                userEmail: userEmail,
                userUID: userUID,
                title: title,
                userInfo: snapshot.data!);
          case ConnectionState.none:
            return ErrorWidget("The stream was wrong (connectionState.none)");
          case ConnectionState.done:
            return ErrorWidget("The stream has ended??");
        }
      },
    );
  }
}

class _MainScreen extends StatefulWidget {
  const _MainScreen(
      {required this.title,
      required this.userEmail,
      required this.userUID,
      required this.userInfo});

  final String title;
  final String userEmail;
  final String userUID;
  final UserInfo userInfo;

  @override
  State<_MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> updateDatabasePoints(int newPoints) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.doc('/users/${widget.userUID}');

      await userRef.update({'points': widget.userInfo.points + newPoints});
    } catch (e) {
      print('Error updating points: $e');
    }
  }

  bool updatePoints(int newValue) {
    if (newValue >= 0 || widget.userInfo.points >= -newValue) {
      updateDatabasePoints(newValue);
      return true;
    }
    return false;
  }

  Future<void> updateHasWon(bool newValue) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.doc('/users/${widget.userUID}');
      await userRef.update({'hasWon': newValue});
      if (newValue) {
        showWin();
        updateHasWon(false);
      }
    } catch (e) {
      print('Error updating hasWon: $e');
    }
  }

  Future<void> setPoints(int newPoints) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.doc('/users/${widget.userUID}');

      await userRef.update({'points': newPoints});
    } catch (e) {
      print('Error setting points: $e');
    }
  }

  Future<void> setStep(int newStep) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.doc('/users/${widget.userUID}');

      await userRef.update({'step': newStep});
    } catch (e) {
      print('Error setting step: $e');
    }
  }

  Future<void> reset() async {
    final userDoc = FirebaseFirestore.instance.doc("/users/${widget.userUID}");
    QuerySnapshot honeyRushDocs = await FirebaseFirestore.instance
        .collection("/users/${widget.userUID}/honeyRush/honeyRush/profiles")
        .get();
    for (var docSnapshot in honeyRushDocs.docs) {
      await docSnapshot.reference.delete();
    }

    QuerySnapshot foodDocs = await FirebaseFirestore.instance
        .collection("/users/${widget.userUID}/beebo/beebo/foodList")
        .get();
    for (var docSnapshot in foodDocs.docs) {
      await docSnapshot.reference.delete();
    }

    QuerySnapshot hygieneDocs = await FirebaseFirestore.instance
        .collection("/users/${widget.userUID}/beebo/beebo/hygieneList")
        .get();
    for (var docSnapshot in hygieneDocs.docs) {
      await docSnapshot.reference.delete();
    }

    QuerySnapshot toyDocs = await FirebaseFirestore.instance
        .collection("/users/${widget.userUID}/beebo/beebo/toysList")
        .get();
    for (var docSnapshot in toyDocs.docs) {
      await docSnapshot.reference.delete();
    }

    QuerySnapshot sleepDocs = await FirebaseFirestore.instance
        .collection("/users/${widget.userUID}/beebo/beebo/sleepList")
        .get();
    for (var docSnapshot in sleepDocs.docs) {
      await docSnapshot.reference.delete();
    }

    QuerySnapshot columnsDocs = await FirebaseFirestore.instance
        .collection("/users/${widget.userUID}/PMTinfo/PMTinfo/columns")
        .get();
    for (var docSnapshot in columnsDocs.docs) {
      await docSnapshot.reference.delete();
    }

    QuerySnapshot tasksDocs = await FirebaseFirestore.instance
        .collection("/users/${widget.userUID}/PMTinfo/PMTinfo/tasks")
        .get();
    for (var docSnapshot in tasksDocs.docs) {
      await docSnapshot.reference.delete();
    }

    CollectionReference info = userDoc.collection("PMTinfo");
    CollectionReference columns = info.doc(info.id).collection("columns");
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

    CollectionReference honeyRush = userDoc.collection("honeyRush");
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
      'honey': Random().nextInt(21) + 70,
      'diaryText': 'Write your thoughts...',
      'narrativeSpot': Random().nextInt(4),
      'card1': 0,
      'card2': 0,
      'card3': 0,
      'cardSlot1': false,
      'cardSlot2': false,
      'cardSlot3': false,
      'isCarding': false,
      'playedCardsNum': 0
    });
    CollectionReference beebo =
                userDoc.collection("beebo");
                beebo.doc(beebo.id).set({
              'food' : Random().nextDouble(),
              'hygiene' : Random().nextDouble(),
              'toys' : Random().nextDouble(),
              'sleep' : Random().nextDouble(),
              'selectedButtonIndex' : 0
            });
    setPoints(0);
    setStep(0);
  }

  Future<dynamic> showLose() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('You lost!'),
            content: const Text("You didn't fill the honeycomb. What a pity!"),
            actions: [
              TextButton(
                onPressed: () {
                  reset();
                  Navigator.of(context).pop();
                },
                child: const Text("Restart", style: TextStyle(fontSize: 22)),
              )
            ],
          );
        });
  }

  Future<dynamic> showWin() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('You Won!'),
            content: const Text("You filled all the honeycomb. Congratulations!"),
            actions: [
              TextButton(
                onPressed: () {
                  reset();
                  Navigator.of(context).pop();
                },
                child: const Text("Restart", style: TextStyle(fontSize: 22)),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 20, 14, 3),
            background: const Color.fromARGB(255, 255, 245, 202)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 230, 146, 38),
              title: Row(children: [
                Text(widget.title),
                const Spacer(),
                OutlinedButton(
                    onPressed: () {
                      reset();
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    child: const Text("<< Restart",
                        style: TextStyle(color: Colors.black))),
                const SizedBox(width: 10),
                OutlinedButton(
                    onPressed: () {
                      if (widget.userInfo.step < 9) {
                        updateDaytime(widget.userUID);
                        updateHoneyFeverState(widget.userUID);
                        setStep(widget.userInfo.step + 1);
                      } else {
                        showLose();
                      }
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    child: const Text("Forward >>",
                        style: TextStyle(color: Colors.black))),
                const Spacer(),
                Text(widget.userInfo.points.toString()),
                SizedBox(width: 35, child: Image.asset("assets/points.png"))
              ]),
              bottom: TabBar(controller: _tabController, tabs: const [
                Tab(icon: Icon(Icons.table_view)),
                Tab(icon: Icon(Icons.list)),
                Tab(icon: Icon(Icons.list_alt)),
                Tab(icon: Icon(Icons.person)),
                Tab(icon: Icon(Icons.gamepad))
              ]),
            ),
            body: TabBarView(controller: _tabController, children: [
              BoardScreen(
                  userEmail: widget.userEmail,
                  userUID: widget.userUID,
                  updatePoints: updatePoints),
              BacklogScreen(
                  userUID: widget.userUID, updatePoints: updatePoints),
              IssuesScreen(userUID: widget.userUID),
              AvatarScreen(userUID: widget.userUID, updatePoints: updatePoints),
              HoneyScreen(
                  updatePoints: updatePoints,
                  userUID: widget.userUID,
                  updateHasWon: updateHasWon)
            ])),
      ),
    );
  }
}
