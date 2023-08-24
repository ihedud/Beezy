import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/board.dart';

class BacklogScreen extends StatelessWidget {
  final String userUID;
  final Function(int) updatePoints;

  const BacklogScreen(
      {Key? key,
      required this.userUID,
      required this.updatePoints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userPMTinfoSnapshots(userUID),
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
            return _BacklogScreen(
              info: snapshot.data!,
              userUID: userUID,
              updatePoints: updatePoints,
            );
          case ConnectionState.none:
            return ErrorWidget("The stream was wrong (connectionState.none)");
          case ConnectionState.done:
            return ErrorWidget("The stream has ended??");
        }
      },
    );
  }
}

class _BacklogScreen extends StatefulWidget {
  const _BacklogScreen({
    required this.info,
    required this.userUID,
    required this.updatePoints,
  });

  final PMTinfo info;
  final String userUID;
  final Function(int) updatePoints;

  @override
  State<_BacklogScreen> createState() => _BacklogScreenState();
}

class _BacklogScreenState extends State<_BacklogScreen> {
  String _dropdownValue(Task task) {
    String dropdownValue = '';
    for (ColumnBZ column in widget.info.columns) {
      if (column.id == task.columnID) {
        dropdownValue = column.columnTitle;
      }
    }
    return dropdownValue;
  }

  Future<void> moveTask(String taskID, int newSprintID) async {
    try {
      DocumentReference taskRef = FirebaseFirestore.instance
          .doc('/users/${widget.userUID}/PMTinfo/PMTinfo/tasks/$taskID');

      await taskRef.update({'sprintID': newSprintID});
    } catch (e) {
      print('Error moving task: $e');
    }
  }

  Future<void> updateStatus(int newValue, String taskID) async {
    try {
      DocumentReference taskRef = FirebaseFirestore.instance
          .doc('/users/${widget.userUID}/PMTinfo/PMTinfo/tasks/$taskID');

      await taskRef.update({'status': newValue});
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  List<String> _status() {
    List<String> status = <String>[];
    for (ColumnBZ column in widget.info.columns) {
      status.add(column.columnTitle);
    }
    return status;
  }

  Future<void> updateColumn(String value, Task task) async {
    try {
      DocumentReference taskRef = FirebaseFirestore.instance
          .doc('/users/${widget.userUID}/PMTinfo/PMTinfo/tasks/${task.id}');

      await taskRef.update({'columnID': value});
    } catch (e) {
      print('Error setting status: $e');
    }
  }

  void _addBacklogTask(String userUID, String name) {
    FirebaseFirestore.instance.collection("/users/$userUID/PMTinfo/PMTinfo/tasks").add({
      'columnID': widget.info.columns.first.id,
      'sprintID': 0,
      'name': name,
      'description': '',
      'priority': 0,
      'points': 0,
      'status': 0
    });
  }

  void _addBoardTask(String userUID, String name) {
    FirebaseFirestore.instance.collection("/users/$userUID/PMTinfo/PMTinfo/tasks").add({
      'columnID': widget.info.columns.first.id,
      'sprintID': 1,
      'name': name,
      'description': '',
      'priority': 0,
      'points': 0,
      'status': 0
    });
  }

  void _deleteTask(String userUID, String taskID) {
    FirebaseFirestore.instance.doc('/users/$userUID/PMTinfo/PMTinfo/tasks/$taskID').delete();
  }

  List<Widget> _getSprintTasks(BuildContext context) {
    final List<Widget> taskWidgets = <Widget>[];
    for (Task task in widget.info.tasks) {
      if (task.sprintID != 0) {
        taskWidgets.add(_buildTask(task, context));
      }
    }
    return taskWidgets;
  }

  List<Widget> _getBacklogTasks(BuildContext context) {
    final List<Widget> taskWidgets = <Widget>[];
    for (Task task
        in widget.info.tasks.where((task) => task.sprintID == 0).toList()) {
      taskWidgets.add(_buildTask(task, context));
    }
    return taskWidgets;
  }

  Widget _buildTask(Task task, BuildContext context) {
    return LongPressDraggable(
      data: task,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Container(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
              width: 250,
              height: 100,
              child: DecoratedBox(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 175, 117, 41),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      task.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )))),
      child: Container(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: SizedBox(
              height: 50,
              child: DecoratedBox(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 230, 146, 38),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        children: <Widget>[
                          Text(task.name),
                          const Spacer(),
                          DropdownButton<String>(
                            value: _dropdownValue(task),
                            icon: const Icon(Icons.arrow_drop_down),
                            style: const TextStyle(color: Colors.black),
                            underline: Container(
                              height: 2,
                              color: Color.fromARGB(255, 230, 146, 38),
                            ),
                            onChanged: (String? value) {
                              for (ColumnBZ column in widget.info.columns) {
                                if (column.columnTitle == value) {
                                  updateColumn(column.id, task);
                                  if (column.isKey &&
                                      widget.info.tasks.contains(task)) {
                                    if (task.status == 0) {
                                      widget.updatePoints(task.points);
                                    }
                                    updateStatus(1, task.id);
                                  } else {
                                    if (task.status != 0) {
                                      updateStatus(2, task.id);
                                    }
                                  }
                                }
                              }
                            },
                            items: _status()
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          OutlinedButton(
                              onPressed: () {
                                _deleteTask(widget.userUID, task.id);
                              },
                              //tooltip: 'Delete this column',
                              child: const Icon(Icons.remove_circle)),
                          // OutlinedButton(
                          //     onPressed: () async {
                          //       await Navigator.of(context).push(
                          //         MaterialPageRoute(
                          //           builder: (context) =>
                          //               TaskScreen(selectedTask: task, userUID: widget.u,),
                          //         ),
                          //       );
                          //       setState(() {});
                          //     },
                          //     child: const Icon(Icons.edit)),
                        ],
                      ))))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      DragTarget<Task>(onAccept: (task) {
        moveTask(task.id, 1);
        for (ColumnBZ column in widget.info.columns) {
          if (task.columnID == column.id && column.isKey) {
            if (task.status == 0) {
              widget.updatePoints(task.points);
            }
            updateStatus(1, task.id);
          }
        }
      }, builder: (context, List<dynamic> accepted, List<dynamic> rejected) {
        return Container(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
                child: DecoratedBox(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 223, 142),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Board',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              Column(
                                children: _getSprintTasks(context),
                              ),
                              OutlinedButton(
                                  onPressed: () {
                                    _addBoardTask(widget.userUID, 'New Task');
                                  },
                                  child: const Icon(Icons.add)),
                            ])))));
      }),
      DragTarget<Task>(onAccept: (task) {
        if (task.status != 1) {
          moveTask(task.id, 0);
        }
      }, builder: (context, List<dynamic> accepted, List<dynamic> rejected) {
        return Container(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
                child: DecoratedBox(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 223, 142),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Backlog',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              Column(
                                children: _getBacklogTasks(context),
                              ),
                              OutlinedButton(
                                  onPressed: () {
                                    _addBacklogTask(widget.userUID, 'New Task');
                                  },
                                  child: const Icon(Icons.add)),
                            ])))));
      })
    ]);
  }
}
