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
      required this.status});
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
