import 'package:flutter/material.dart';

class ColumnBZ {
  int id = 0;
  String columnTitle = '';
  bool isEditingText = false;
  TextEditingController editingController = TextEditingController();
  bool isKey = false;
}

class Task {
  int id = 0;
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
}

class Board {
  List<ColumnBZ> columns = <ColumnBZ>[];
  List<Task> tasks = <Task>[];
  List<Task> backlogTasks = <Task>[];
  int columnID = 0;
  int taskID = 0;
}
