import 'package:beezy/screens/avatar_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:beezy/screens/board_screen.dart';
import 'package:beezy/screens/backlog_screen.dart';
import 'package:beezy/models/board.dart';
import 'package:beezy/models/avatar.dart';

import 'issues_screen.dart';

class MyObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Call your method here before the application is closed
      myMethod();
    }
  }

  void myMethod() {
    // Your code logic here
    print('Method called before closing the application');
  }
}

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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Board board = Board();
  Avatar avatar = Avatar();
  int points = 0;
  late TabController _tabController;
  MyObserver myObserver = MyObserver();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    getTasks();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance!.addObserver(myObserver);
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance!.removeObserver(myObserver);
    print('updating...');
    updateTasks();
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused ||
  //       state == AppLifecycleState.inactive ||
  //       state == AppLifecycleState.detached) {
  //     print('updating...');
  //     updateTasks();
  //   }
  // }

  void updatePoints(int newPoints) {
    setState(() {
      points += newPoints;
    });
  }

  void getTasks() async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    CollectionReference tasksCollection =
        usersCollection.doc(widget.userUID).collection('tasks');

    QuerySnapshot querySnapshot = await tasksCollection.get();

    setState(() {
      board.tasks = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = (doc.data() as Map<String, dynamic>);
        return Task(
          id: doc.id,
          columnID: data['columnID'],
          sprintID: data['sprintID'],
          name: data['name'],
          description: data['description'],
          priority: data['priority'],
          points: data['points'],
          status: data['status'],
        );
      }).toList();
    });
  }

  void updateTasks() async {
    print('updating...');
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection("/users");

    CollectionReference tasksCollection =
        usersCollection.doc(widget.userUID).collection('tasks');

    QuerySnapshot querySnapshot = await tasksCollection.get();

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.delete();
    }

    for (Task task in board.tasks) {
      tasksCollection.add({
        'columnID': task.columnID,
        'sprintID': task.sprintID,
        'name': task.name,
        'description': task.description,
        'priority': task.priority,
        'points': task.points,
        'status': task.status
      });
    }
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
