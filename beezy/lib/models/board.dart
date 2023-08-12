import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ColumnBZ {
  int id = 0;
  String columnTitle = '';
  bool isEditingText = false;
  TextEditingController editingController = TextEditingController();
  bool isKey = false;
}

// class Task {
//   int id = 0;
//   int columnID = 0;
//   int sprintID = 0;
//   String name = '';
//   String description = '';
//   int priority = 0;
//   int points = 0;
//   int status = 0;
//   TextEditingController nameController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   TextEditingController pointsController = TextEditingController();
// }

class Task {
  String id = '';
  int columnID = 0;
  int sprintID = 0;
  String name = '';
  String description = '';
  int priority = 0;
  int points = 0;
  int status = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController pointsController = TextEditingController();

  Task(
      {required this.id,
      required this.columnID,
      required this.sprintID,
      required this.name,
      required this.description,
      required this.priority,
      required this.points,
      required this.status}) {
    nameController.text = name;
    descriptionController.text = description;
    pointsController.text = points.toString();
  }

  Task.fromFirestore(this.id, Map<String, dynamic> json)
      : columnID = json['columnID'],
        sprintID = json['sprintID'],
        name = json['name'],
        description = json['description'],
        priority = json['priority'],
        points = json['points'],
        status = json['status']{
    nameController.text = name;
    descriptionController.text = description;
    pointsController.text = points.toString();
  }

}

Stream<List<Task>> userTaskSnapshots(String userUID) {
  final db = FirebaseFirestore.instance;
  final stream = db.collection("/users/$userUID/tasks").snapshots();
  return stream.map((query) {
    List<Task> tasks = [];
    for (final doc in query.docs) {
      tasks.add(Task.fromFirestore(doc.id, doc.data()));
    }
    return tasks;
  });
}

Stream<Task?> userTaskSnapshot(String userUID, String taskID) {
  final db = FirebaseFirestore.instance;
  final stream = db.doc("/users/$userUID/tasks/$taskID").snapshots();
  return stream.map((doc) {
    if (doc.exists) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        return Task.fromFirestore(doc.id, data);
      }
    }
    return null;
  });
}

class Board {
  List<ColumnBZ> columns = <ColumnBZ>[
    ColumnBZ()
      ..id = 0
      ..columnTitle = 'To Do',
    ColumnBZ()
      ..id = 1
      ..columnTitle = 'In Progress',
    ColumnBZ()
      ..id = 2
      ..columnTitle = 'Done',
  ];
  List<Task> tasks = <Task>[];
  List<Task> backlogTasks = <Task>[];
  int columnID = 3;
  int taskID = 0;
}
