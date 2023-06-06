import 'package:beezy/screens/avatar_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:beezy/screens/board_screen.dart';
import 'package:beezy/screens/backlog_screen.dart';
import 'package:beezy/models/board.dart';
import 'package:beezy/models/avatar.dart';

import 'issues_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen(
      {super.key,
      required this.title,
      required this.userEmail,
      required this.userUID});

  final String title;
  final String userEmail;
  final String userUID;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  Board board = Board();
  Avatar avatar = Avatar();
  int points = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void updatePoints(int newPoints) {
    setState(() {
      points += newPoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Row(children: [
                Text(widget.title),
                const Spacer(),
                Text(points.toString())
              ]),
              bottom: TabBar(controller: _tabController, tabs: const [
                Tab(icon: Icon(Icons.table_view)),
                Tab(icon: Icon(Icons.list)),
                Tab(icon: Icon(Icons.list_alt)),
                Tab(icon: Icon(Icons.person))
              ]),
            ),
            body: TabBarView(controller: _tabController, children: [
              BoardScreen(
                  userEmail: widget.userEmail,
                  userUID: widget.userUID,
                  board: board,
                  updatePoints: updatePoints),
              BacklogScreen(board: board, updatePoints: updatePoints),
              IssuesScreen(board: board),
              AvatarScreen(avatar: avatar, updatePoints: updatePoints)
            ])),
      ),
    );
  }
}
