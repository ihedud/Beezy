import 'package:beezy/screens/avatar_screen.dart';
import 'package:flutter/material.dart';
import 'package:beezy/screens/board_screen.dart';
import 'package:beezy/screens/backlog_screen.dart';
import 'package:beezy/models/board.dart';
import 'package:beezy/models/avatar.dart';

import 'issues_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Board board = Board();
  Avatar avatar = Avatar();
  int points = 0;

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
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.table_view)),
                Tab(icon: Icon(Icons.list)),
                Tab(icon: Icon(Icons.list_alt)),
                Tab(icon: Icon(Icons.person))
              ]),
            ),
            body: TabBarView(children: [
              BoardScreen(board: board, updatePoints: updatePoints),
              BacklogScreen(board: board, updatePoints: updatePoints),
              IssuesScreen(board: board),
              AvatarScreen(avatar: avatar, updatePoints: updatePoints)
            ])),
      ),
    );
  }
}
