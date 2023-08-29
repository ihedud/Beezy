import 'package:beezy/screens/avatar_screen.dart';
import 'package:beezy/screens/honey_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:beezy/screens/board_screen.dart';
import 'package:beezy/screens/backlog_screen.dart';
import 'package:beezy/models/avatar.dart';
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
      stream: userPointsSnapshot(userUID),
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
                points: snapshot.data!);
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
      {super.key,
      required this.title,
      required this.userEmail,
      required this.userUID,
      required this.points});

  final String title;
  final String userEmail;
  final String userUID;
  final int points;

  @override
  State<_MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Avatar avatar = Avatar();
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

  Future<void> updatePoints(int newPoints) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.doc('/users/${widget.userUID}');

      await userRef.update({'points': widget.points + newPoints});
    } catch (e) {
      print('Error updating title: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromARGB(255, 20, 14, 3),
            background: Color.fromARGB(255, 255, 245, 202)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 230, 146, 38),
              title: Row(children: [
                Text(widget.title),
                const Spacer(),
                Text(widget.points.toString()),
                SizedBox(width: 35, child: Image.asset("points.png"))
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
              AvatarScreen(avatar: avatar, updatePoints: updatePoints),
              HoneyScreen(updatePoints: updatePoints, userUID: widget.userUID)
            ])),
      ),
    );
  }
}
