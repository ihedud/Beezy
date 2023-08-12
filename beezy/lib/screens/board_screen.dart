import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/task_screen.dart';
import '../models/board.dart';

List<Widget> starIcons = <Widget>[
  const Icon(Icons.star_border),
  const Icon(Icons.star)
];

class BoardScreen extends StatelessWidget {
  final String userEmail;
  final String userUID;
  final Board board;
  final Function(int) updatePoints;

  const BoardScreen(
      {Key? key,
      required this.userEmail,
      required this.userUID,
      required this.board,
      required this.updatePoints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userTaskSnapshots(userUID),
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
            return _BoardScreen(
                userEmail: userEmail,
                userUID: userUID,
                board: board,
                updatePoints: updatePoints,
                tasks: snapshot.data!);
          case ConnectionState.none:
            return ErrorWidget("The stream was wrong (connectionState.none)");
          case ConnectionState.done:
            return ErrorWidget("The stream has ended??");
        }
      },
    );
  }
}

class _BoardScreen extends StatefulWidget {
  const _BoardScreen(
      {super.key,
      required this.userEmail,
      required this.userUID,
      required this.board,
      required this.updatePoints,
      required this.tasks});

  final String userEmail;
  final String userUID;
  final Board board;
  final Function(int) updatePoints;
  final List<Task> tasks;

  @override
  State<_BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<_BoardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> moveTask(String taskID, int newColumnID) async {
    try {
      DocumentReference taskRef = FirebaseFirestore.instance
          .doc('/users/${widget.userUID}/tasks/$taskID');

      await taskRef.update({'columnID': newColumnID});
    } catch (e) {
      print('Error moving task: $e');
    }
  }

  void _addColumn(int id, String columnTitle, bool isEditingText,
      TextEditingController editingController) {
    ColumnBZ column = ColumnBZ();
    column.id = id;
    column.columnTitle = columnTitle + (id + 1).toString();
    column.isEditingText = isEditingText;
    column.editingController = editingController;
    setState(() {
      widget.board.columns.add(column);
    });
  }

  void _addTask(/*int id,*/ String userUID, String name, ColumnBZ column) {
    // Task task = Task(
    //     id: 'task$id',
    //     columnID: column.id,
    //     sprintID: 1,
    //     name: name,
    //     description: '',
    //     priority: 0,
    //     points: 0,
    //     status: 0);
    // setState(() {
    //   widget.board.tasks.add(task);
    // });

    FirebaseFirestore.instance.collection("/users/$userUID/tasks").add({
      'columnID': column.id,
      'sprintID': 1,
      'name': 'New Task',
      'description': '',
      'priority': 0,
      'points': 0,
      'status': 0
    });
    // setState(() {}); // No need to call setState here crec
  }

  void _deleteColumn(ColumnBZ column) {
    setState(() {
      widget.board.columns.removeWhere((item) => item.id == column.id);
    });
  }

  // void _deleteTask(Task task) {
  //   setState(() {
  //     widget.board.tasks.removeWhere((item) => item.id == task.id);
  //   });
  // }

  void _deleteTask(String userUID, String taskID) {
    FirebaseFirestore.instance.doc('/users/$userUID/tasks/$taskID').delete();
  }

  void _editKey(ColumnBZ currentColumn) {
    // if (currentColumn.isKey) {
    //   setState(() {
    //     currentColumn.isKey = false;
    //   });
    //   return;
    // }
    for (ColumnBZ column in widget.board.columns) {
      if (column.isKey) return;
    }
    setState(() {
      currentColumn.isKey = true;
    });
  }

  Widget _getKey(ColumnBZ column) {
    if (column.isKey) {
      return starIcons.last;
    } else {
      return starIcons.first;
    }
  }

  Widget _editColumnTitle(ColumnBZ column, BuildContext context) {
    if (column.isEditingText) {
      return Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100, maxWidth: 260),
        child: TextField(
          onSubmitted: (newValue) {
            setState(() {
              column.columnTitle = newValue;
              column.isEditingText = false;
            });
          },
          autofocus: true,
          controller: column.editingController,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ));
    }
    return InkWell(
      onTap: () {
        setState(() {
          column.isEditingText = true;
        });
      },
      child: Text(
        column.columnTitle,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  Widget _buildColumn(ColumnBZ column) {
    return DragTarget<Task>(
        key: ValueKey(column),
        onAccept: (task) {
          //setState(() {
          moveTask(task.id, column.id);
          if (column.isKey) {
            if (task.status == 0) {
              widget.updatePoints(task.points);
            }
            task.status = 1;
          } else {
            if (task.status == 1) task.status = 2;
          }
          //});
        },
        builder: (context, List<dynamic> accepted, List<dynamic> rejected) {
          return Container(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                  width: 300,
                  child: DecoratedBox(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 255, 223, 142),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Container(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _editColumnTitle(column, context),
                              Expanded(
                                  child: Column(
                                children: [
                                  Expanded(
                                      child: ListView(
                                          scrollDirection: Axis.vertical,
                                          children:
                                              _getTasks(column, context))),
                                  !column.isKey
                                      ? OutlinedButton(
                                          onPressed: () {
                                            _addTask(widget.userUID, 'New Task',
                                                column);
                                            //widget.board.taskID++;
                                          },
                                          child: const Icon(Icons.add))
                                      : Container(),
                                ],
                              )),
                              !column.isKey
                                  ? OutlinedButton(
                                      onPressed: () {
                                        _deleteColumn(column);
                                      },
                                      child: const Tooltip(
                                        message: 'Delete this column',
                                        child: Icon(Icons.remove_circle),
                                      ))
                                  : Container(),
                              OutlinedButton(
                                  onPressed: () {
                                    _editKey(column);
                                  },
                                  child: Tooltip(
                                      message: 'Make this column a Key',
                                      child: _getKey(column)))
                            ],
                          )))));
        });
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
          padding: const EdgeInsets.all(15),
          child: SizedBox(
              width: 250,
              height: 100,
              child: DecoratedBox(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 254, 187, 15),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(task.name),
                      OutlinedButton(
                          onPressed: () {
                            _deleteTask(widget.userUID, task.id);
                          },
                          //tooltip: 'Delete this column',
                          child: const Icon(Icons.remove_circle)),
                      OutlinedButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TaskScreen(
                                    taskID: task.id,
                                    userUID: widget.userUID),
                              ),
                            );
                            //setState(() {});
                          },
                          child: const Icon(Icons.edit)),
                    ],
                  )))),
    );
  }

  List<Widget> _getColumns() {
    final List<Widget> columnWidgets = <Widget>[];
    for (ColumnBZ column in widget.board.columns) {
      columnWidgets.add(_buildColumn(column));
    }
    return columnWidgets;
  }

  List<Widget> _getTasks(ColumnBZ column, BuildContext context) {
    final List<Widget> taskWidgets = <Widget>[];
    for (Task task in widget.tasks) {
      if (column.id == task.columnID) {
        taskWidgets.add(_buildTask(task, context));
      }
    }
    return taskWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: ReorderableListView(
          scrollDirection: Axis.horizontal,
          children: _getColumns(),
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final ColumnBZ column = widget.board.columns.removeAt(oldIndex);
              widget.board.columns.insert(newIndex, column);
            });
          },
        ),
      ),
      FloatingActionButton(
        onPressed: () {
          _addColumn(widget.board.columnID, 'New Column ', false,
              TextEditingController());
          widget.board.columnID++;
        },
        tooltip: 'Create new column',
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
      FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add_a_photo),
      ),
    ]);
  }
}
