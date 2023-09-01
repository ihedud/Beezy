import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ColumnBZ {
  String id = '';
  String columnTitle = '';
  int displayOrder = 0;
  bool isKey = false;
  bool isEditingText = false;
  TextEditingController editingController = TextEditingController();

  ColumnBZ.fromFirestore(this.id, Map<String, dynamic> json)
      : columnTitle = json['columnTitle'],
        displayOrder = json['displayOrder'],
        isKey = json['isKey'],
        isEditingText = json['isEditingText'] {
    editingController.text = columnTitle;
  }
}

class Task {
  String id = '';
  String columnID = '';
  int sprintID = 0;
  String name = '';
  String description = '';
  int priority = 0;
  int points = 0;
  int status = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController pointsController = TextEditingController();

  Task.fromFirestore(this.id, Map<String, dynamic> json)
      : columnID = json['columnID'],
        sprintID = json['sprintID'],
        name = json['name'],
        description = json['description'],
        priority = json['priority'],
        points = json['points'],
        status = json['status'] {
    nameController.text = name;
    descriptionController.text = description;
    pointsController.text = points.toString();
  }
}

class PMTinfo {
  List<ColumnBZ> columns = <ColumnBZ>[];
  List<Task> tasks = <Task>[];
  int columnID = 0;

  // PMTinfo({List<ColumnBZ>? columns, List<Task>? tasks, int? columnID}) {
  //   if (columns != null) {
  //     this.columns = columns;
  //   }
  //   if (tasks != null) {
  //     this.tasks = tasks;
  //   }
  //   if (columnID != null) {
  //     this.columnID = columnID;
  //   }
  // }

  PMTinfo.fromFirestore(Map<String, dynamic> json, List<ColumnBZ> columnsData,
      List<Task> tasksData)
      : columnID = json['columnID'] {
    columns = columnsData;
    tasks = tasksData;
  }
}

// Stream<PMTinfo> userTaskSnapshots(String userUID) {
//   final db = FirebaseFirestore.instance;
//   final stream = db.collection("/users/$userUID/PMTinfo").snapshots();
//   final streamColumns =
//       db.collection("/users/$userUID/PMTinfo/PMTinfo/columns").snapshots();
//   final streamTasks =
//       db.collection("/users/$userUID/PMTinfo/PMTinfo/tasks").snapshots();

//   final controller = StreamController<PMTinfo>();

//   stream.listen((query) {
//     final columns = <ColumnBZ>[];
//     final tasks = <Task>[];

//     streamColumns.listen((queryColumns) {
//       print("here");
//       columns.clear();
//       for (int i = 0; i < queryColumns.docs.length; i++) {
//         for (final doc in queryColumns.docs) {
//           if (doc.get('displayOrder') == i) {
//             columns.add(ColumnBZ.fromFirestore(doc.id, doc.data()));
//           }
//         }
//       }

//       streamTasks.listen((queryTasks) {
//         tasks.clear();
//         for (final taskDoc in queryTasks.docs) {
//           tasks.add(Task.fromFirestore(taskDoc.id, taskDoc.data()));
//         }

//         late PMTinfo info;
//         for (final doc in query.docs) {
//           info = PMTinfo.fromFirestore(doc.data(), columns, tasks);
//         }

//         controller.add(info);
//       });
//     });
//   });

//   return controller.stream;
// }

// Stream<PMTinfo> userTaskSnapshots(String userUID) {
//   final db = FirebaseFirestore.instance;
//   final stream = db.collection("/users/$userUID/PMTinfo").snapshots();
//   final controller = StreamController<PMTinfo>();

//   stream.listen((query) async {
//     final columnsSnapshot =
//         await db.collection("/users/$userUID/PMTinfo/PMTinfo/columns").get();

//     final tasksSnapshot =
//         await db.collection("/users/$userUID/PMTinfo/PMTinfo/tasks").get();

//     final columns = columnsSnapshot.docs.map(
//         (doc) => ColumnBZ.fromFirestore(doc.id, doc.data())).toList();

//     final tasks = tasksSnapshot.docs.map(
//         (doc) => Task.fromFirestore(doc.id, doc.data())).toList();

//     final info = PMTinfo.fromFirestore(query.docs.first.data(), columns, tasks);

//     controller.add(info);
//   });

//   return controller.stream;
// }

Stream<PMTinfo> userPMTinfoSnapshots(String userUID) {
  final db = FirebaseFirestore.instance;

  final columnsStream = db
      .collection("/users/$userUID/PMTinfo/PMTinfo/columns")
      .orderBy('displayOrder')
      .snapshots();

  final tasksStream =
      db.collection("/users/$userUID/PMTinfo/PMTinfo/tasks").snapshots();

  final controller = StreamController<PMTinfo>();

  final List<ColumnBZ> columns = [];
  final List<Task> tasks = [];

  columnsStream.listen((queryColumns) {
    columns.clear();
    // for (final doc in queryColumns.docs) {
    //   columns.add(ColumnBZ.fromFirestore(doc.id, doc.data()));
    // }

    for (int i = 0; i < queryColumns.docs.length; i++) {
      for (final doc in queryColumns.docs) {
        if (doc.get('displayOrder') == i) {
          columns.add(ColumnBZ.fromFirestore(doc.id, doc.data()));
        }
      }
    }

    updateController(controller, columns, tasks, userUID);
  });

  tasksStream.listen((queryTasks) {
    tasks.clear();
    for (final taskDoc in queryTasks.docs) {
      tasks.add(Task.fromFirestore(taskDoc.id, taskDoc.data()));
    }
    updateController(controller, columns, tasks, userUID);
  });

  return controller.stream;
}

void updateController(StreamController<PMTinfo> controller,
    List<ColumnBZ> columns, List<Task> tasks, String userUID) {
  final db = FirebaseFirestore.instance;

  db.collection("/users/$userUID/PMTinfo").get().then((query) {
    late PMTinfo info;
    for (final doc in query.docs) {
      info = PMTinfo.fromFirestore(doc.data(), columns, tasks);
    }
    controller.add(info);
  }).catchError((error) {
    print(error);
  });
}

Stream<Task?> userTaskSnapshot(String userUID, String taskID) {
  final db = FirebaseFirestore.instance;
  final stream =
      db.doc("/users/$userUID/PMTinfo/PMTinfo/tasks/$taskID").snapshots();
  return stream.map((doc) {
    if (doc.exists) {
      Map<String, dynamic>? data = doc.data();
      if (data != null) {
        return Task.fromFirestore(doc.id, data);
      }
    }
    return null;
  });
}

class UserInfo {
  String userEmail = '';
  int points = 0;
  int step = 0;

  UserInfo.fromFirestore(Map<String, dynamic> json)
      : userEmail = json['email'],
      points = json['points'],
      step = json['step'];
}

Stream<UserInfo?> userInfoSnapshot(String userUID) {
  final db = FirebaseFirestore.instance;
  final stream =
      db.doc("/users/$userUID").snapshots();
  return stream.map((doc) {
    if (doc.exists) {
      Map<String, dynamic>? data = doc.data();
      if (data != null) {
        return UserInfo.fromFirestore(data);
      }
    }
    return null;
  });
}
