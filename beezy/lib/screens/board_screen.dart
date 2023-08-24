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
  //final PMTinfo info;
  final Function(int) updatePoints;

  const BoardScreen(
      {Key? key,
      required this.userEmail,
      required this.userUID,
      //required this.info,
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
            return _BoardScreen(
              userEmail: userEmail,
              userUID: userUID,
              info: snapshot.data!,
              updatePoints: updatePoints,
              /*tasks: snapshot.data!.tasks
                    .where((task) => task.sprintID == 1)
                    .toList()*/
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

class _BoardScreen extends StatefulWidget {
  const _BoardScreen({
    required this.userEmail,
    required this.userUID,
    required this.info,
    required this.updatePoints,
    /*required this.tasks*/
  });

  final String userEmail;
  final String userUID;
  final PMTinfo info;
  final Function(int) updatePoints;
  //final List<Task> tasks;

  @override
  State<_BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<_BoardScreen> {
  late String tasksPath;
  late String columnsPath;

  @override
  void initState() {
    super.initState();
    tasksPath = "/users/${widget.userUID}/PMTinfo/PMTinfo/tasks";
    columnsPath = "/users/${widget.userUID}/PMTinfo/PMTinfo/columns";
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> moveTask(String taskID, String newColumnID) async {
    try {
      DocumentReference taskRef =
          FirebaseFirestore.instance.doc('$tasksPath/$taskID');

      await taskRef.update({'columnID': newColumnID});
    } catch (e) {
      print('Error moving task: $e');
    }
  }

  Future<void> updateStatus(int newValue, String taskID) async {
    try {
      DocumentReference taskRef =
          FirebaseFirestore.instance.doc('$tasksPath/$taskID');

      await taskRef.update({'status': newValue});
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  // void _addColumn(String id, String columnTitle, bool isEditingText,
  //     TextEditingController editingController) {
  //   ColumnBZ column = ColumnBZ();
  //   column.id = id;
  //   column.columnTitle = columnTitle + (int.parse(id) + 1).toString();
  //   column.isEditingText = isEditingText;
  //   column.editingController = editingController;
  //   setState(() {
  //     widget.board.columns.add(column);
  //   });
  // }

  Future<void> updateName(String newName, String columnID) async {
    try {
      DocumentReference columnRef =
          FirebaseFirestore.instance.doc('$columnsPath/$columnID');

      await columnRef.update({'columnTitle': newName});
    } catch (e) {
      print('Error updating title: $e');
    }
  }

  Future<int> updateColumnNum() async {
    try {
      DocumentReference infoRef = FirebaseFirestore.instance
          .doc('/users/${widget.userUID}/PMTinfo/PMTinfo');

      final infoSnapshot = await infoRef.get();
      if (infoSnapshot.exists) {
        int currentColumnID =
            (infoSnapshot.data() as Map<String, dynamic>)['columnID'];
        int newColumnID = currentColumnID + 1;
        await infoRef.update({'columnID': newColumnID});
        return newColumnID;
      }
    } catch (e) {
      print('Error updating columnID: $e');
    }
    return 0;
  }

  Future<void> updateColumnOrder(String columnID, int newValue) async {
    try {
      DocumentReference columnRef = FirebaseFirestore.instance
          .doc('/users/${widget.userUID}/PMTinfo/PMTinfo/columns/$columnID');

      await columnRef.update({'displayOrder': newValue});
    } catch (e) {
      print('Error updating displayOrder: $e');
    }
  }

  void columnReorder(int deletedDisplayOrder) async {
    final columnRef =
        await FirebaseFirestore.instance.collection(columnsPath).get();
    for (int i = deletedDisplayOrder; i <= widget.info.columns.length; i++) {
      for (final doc in columnRef.docs) {
        if (doc.get('displayOrder') == (i + 1)) {
          updateColumnOrder(doc.id, i);
        }
      }
    }
  }

  void moveColumn() async {
    final columnRef =
        await FirebaseFirestore.instance.collection(columnsPath).get();
    for (int i = 0; i < widget.info.columns.length; i++) {
      for (final doc in columnRef.docs) {
        if (doc.id == widget.info.columns[i].id) {
          updateColumnOrder(doc.id, i);
          break;
        }
      }
    }
  }

  Future<void> _addColumn(String name) async {
    int newColumnID = await updateColumnNum();

    FirebaseFirestore.instance.collection(columnsPath).add({
      'columnTitle': name + newColumnID.toString(),
      'displayOrder': widget.info.columns.length,
      'isKey': false,
      'isEditingText': false
    });
  }

  void _addTask(String name, ColumnBZ column) {
    FirebaseFirestore.instance.collection(tasksPath).add({
      'columnID': column.id,
      'sprintID': 1,
      'name': 'New Task',
      'description': '',
      'priority': 0,
      'points': 0,
      'status': 0
    });
  }

  void _deleteColumn(String columnID, int displayOrder) {
    FirebaseFirestore.instance.doc('$columnsPath/$columnID').delete();
    columnReorder(displayOrder);
  }

  void _deleteTask(String taskID) {
    FirebaseFirestore.instance.doc('$tasksPath/$taskID').delete();
  }

  // void _editKey(ColumnBZ currentColumn) {
  //   for (ColumnBZ column in widget.board.columns) {
  //     if (column.isKey) return;
  //   }
  //   setState(() {
  //     currentColumn.isKey = true;
  //   });
  // }

  Widget _getKey(ColumnBZ column) {
    if (column.isKey && !column.isEditingText) {
      return starIcons.first;
    } else {
      //return starIcons.last;
      return Container();
    }
  }

  Widget _editColumnTitle(ColumnBZ column, BuildContext context) {
    if (column.isEditingText) {
      return Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100, maxWidth: 260),
        child: TextField(
          onSubmitted: (newValue) {
            updateName(newValue, column.id);
            setState(() {
              //column.columnTitle = newValue;
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
          moveTask(task.id, column.id);
          if (column.isKey) {
            if (task.status == 0) {
              widget.updatePoints(task.points);
            }
            updateStatus(1, task.id);
          } else {
            if (task.status == 1) updateStatus(2, task.id);
          }
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
                              //Expanded(
                              //child:
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _getKey(column),
                                  _editColumnTitle(column, context),
                                  _getKey(column)
                                ],
                              ),
                              //),
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
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                width: 1.0,
                                                color: Color.fromARGB(
                                                    143, 20, 14, 5)),
                                          ),
                                          onPressed: () {
                                            _addTask('New Task', column);
                                          },
                                          child: const Icon(Icons.add,
                                              color: Color.fromARGB(
                                                  143, 20, 14, 5)))
                                      : Container(),
                                ],
                              )),
                              !column.isKey
                                  ? OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            width: 1.0,
                                            color:
                                                Color.fromARGB(143, 20, 14, 5)),
                                      ),
                                      onPressed: () {
                                        _deleteColumn(
                                            column.id, column.displayOrder);
                                      },
                                      child: const Tooltip(
                                        message: 'Delete this column',
                                        child: Icon(Icons.remove_circle,
                                            color:
                                                Color.fromARGB(143, 20, 14, 5)),
                                      ))
                                  : Container(),

                              // OutlinedButton(
                              //     onPressed: () {
                              //       _editKey(column);
                              //     },
                              //     child: Tooltip(
                              //         message: 'Make this column a Key',
                              //         child: _getKey(column)))
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
                      color: Color.fromARGB(143, 46, 35, 6),
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
                      color: Color.fromARGB(255, 230, 146, 38),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(task.name),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                width: 1.0,
                                color: Color.fromARGB(143, 20, 14, 5)),
                          ),
                          onPressed: () {
                            _deleteTask(task.id);
                          },
                          //tooltip: 'Delete this column',
                          child: const Icon(Icons.remove_circle,
                              color: Color.fromARGB(143, 20, 14, 5))),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                width: 1.0,
                                color: Color.fromARGB(143, 20, 14, 5)),
                          ),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TaskScreen(
                                    taskID: task.id, userUID: widget.userUID),
                              ),
                            );
                          },
                          child: const Icon(Icons.edit,
                              color: Color.fromARGB(143, 20, 14, 5))),
                    ],
                  )))),
    );
  }

  List<Widget> _getColumns() {
    final List<Widget> columnWidgets = <Widget>[];
    for (ColumnBZ column in widget.info.columns) {
      columnWidgets.add(_buildColumn(column));
    }
    return columnWidgets;
  }

  List<Widget> _getTasks(ColumnBZ column, BuildContext context) {
    final List<Widget> taskWidgets = <Widget>[];
    for (Task task
        in widget.info.tasks.where((task) => task.sprintID == 1).toList()) {
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
            //setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final ColumnBZ column = widget.info.columns.removeAt(oldIndex);
            widget.info.columns.insert(newIndex, column);
            moveColumn();
            //});
          },
        ),
      ),
      FloatingActionButton(
        onPressed: () {
          _addColumn('New Column ');
          // _addColumn(widget.board.columnID.toString(), 'New Column ', false,
          //     TextEditingController());
          // widget.board.columnID++;
        },
        tooltip: 'Create new column',
        backgroundColor: Color.fromARGB(255, 230, 146, 38),
        child: const Icon(Icons.add),
      ),
    ]);
  }
}
