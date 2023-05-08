import '../screens/task_screen.dart';
import 'package:flutter/material.dart';
import '../models/board.dart';

class BacklogScreen extends StatefulWidget {
  const BacklogScreen(
      {super.key, required this.board, required this.updatePoints});

  final Board board;
  final Function(int) updatePoints;

  @override
  State<BacklogScreen> createState() => _BacklogScreenState();
}

class _BacklogScreenState extends State<BacklogScreen> {
  String _dropdownValue(Task task) {
    String dropdownValue = '';
    for (ColumnBZ column in widget.board.columns) {
      if (column.id == task.columnID) {
        dropdownValue = column.columnTitle;
      }
    }
    return dropdownValue;
  }

  List<String> _status() {
    List<String> status = <String>[];
    for (ColumnBZ column in widget.board.columns) {
      status.add(column.columnTitle);
    }
    return status;
  }

  void _setStatus(String value, Task task) {
    for (ColumnBZ column in widget.board.columns) {
      if (column.columnTitle == value) {
        task.columnID = column.id;
        if (column.isKey && widget.board.tasks.contains(task)) {
          task.status = 1;
          widget.updatePoints(task.points);
        } else {
          if (task.status != 0) {
            task.status = 2;
          }
        }
      }
    }
  }

  void _addBacklogTask(int id, String name) {
    Task task = Task();
    task.sprintID = 0;
    task.id = id;
    task.columnID = widget.board.columns.first.id;
    task.name = name;
    setState(() {
      widget.board.backlogTasks.add(task);
    });
  }

  void _addBoardTask(int id, String name) {
    Task task = Task();
    task.sprintID = 1;
    task.id = id;
    task.columnID = widget.board.columns.first.id;
    task.name = name;
    setState(() {
      widget.board.tasks.add(task);
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      if (widget.board.tasks.contains(task)) {
        widget.board.tasks.removeWhere((item) => item.id == task.id);
      } else if (widget.board.backlogTasks.contains(task)) {
        widget.board.backlogTasks.removeWhere((item) => item.id == task.id);
      }
    });
  }

  List<Widget> _getSprintTasks(BuildContext context) {
    final List<Widget> taskWidgets = <Widget>[];
    for (Task task in widget.board.tasks) {
      taskWidgets.add(_buildTask(task, context));
    }
    return taskWidgets;
  }

  List<Widget> _getBacklogTasks(BuildContext context) {
    final List<Widget> taskWidgets = <Widget>[];
    for (Task task in widget.board.backlogTasks) {
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
                      color: Color.fromARGB(143, 205, 150, 10),
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
                      color: Color.fromARGB(255, 254, 187, 15),
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
                            //elevation: 16,
                            style: const TextStyle(color: Colors.black),
                            underline: Container(
                              height: 2,
                              color: Colors.amber,
                            ),
                            onChanged: (String? value) {
                              setState(() {
                                _setStatus(value!, task);
                              });
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
                                _deleteTask(task);
                              },
                              //tooltip: 'Delete this column',
                              child: const Icon(Icons.remove_circle)),
                          OutlinedButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TaskScreen(selectedTask: task),
                                  ),
                                );
                                setState(() {});
                              },
                              child: const Icon(Icons.edit)),
                        ],
                      ))))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      DragTarget<Task>(onAccept: (task) {
        setState(() {
          widget.board.backlogTasks.remove(task);
          widget.board.tasks.add(task);
          task.sprintID = 1;
          for (ColumnBZ column in widget.board.columns) {
            if (task.columnID == column.id && column.isKey) {
              if (task.status == 0) {
                widget.updatePoints(task.points);
              }
              task.status = 1;
            }
          }
        });
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
                                    _addBoardTask(
                                        widget.board.taskID, 'New Task');
                                    widget.board.taskID++;
                                  },
                                  child: const Icon(Icons.add)),
                            ])))));
      }),
      DragTarget<Task>(onAccept: (task) {
        setState(() {
          if (task.status != 1) {
            widget.board.tasks.remove(task);
            widget.board.backlogTasks.add(task);
            task.sprintID = 0;
          }
        });
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
                                    _addBacklogTask(
                                        widget.board.taskID, 'New Task');
                                    widget.board.taskID++;
                                  },
                                  child: const Icon(Icons.add)),
                            ])))));
      })
    ]);
  }
}
