import 'package:flutter/material.dart';
import '../screens/task_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/board.dart';

List<Widget> starIcons = <Widget>[
  const Icon(Icons.star_border),
  const Icon(Icons.star)
];

class BoardScreen extends StatefulWidget {
  const BoardScreen(
      {super.key, required this.board, required this.updatePoints});

  final Board board;
  final Function(int) updatePoints;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
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

  void _addTask(int id, String name, ColumnBZ column) {
    Task task = Task();
    task.sprintID = 1;
    task.id = id;
    task.columnID = column.id;
    task.name = name;
    setState(() {
      widget.board.tasks.add(task);
    });
  }

  void _deleteColumn(ColumnBZ column) {
    setState(() {
      widget.board.columns.removeWhere((item) => item.id == column.id);
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      widget.board.tasks.removeWhere((item) => item.id == task.id);
    });
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
          setState(() {
            task.columnID = column.id;
            if (column.isKey) {
              if (task.status == 0) {
                widget.updatePoints(task.points);
              }
              task.status = 1;
            } else {
              if (task.status == 1) task.status = 2;
            }
          });
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
                                            _addTask(widget.board.taskID,
                                                'New Task', column);
                                            widget.board.taskID++;
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
    for (Task task in widget.board.tasks) {
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
        onPressed: () {
          FirebaseFirestore.instance
              .collection("/tasks")
              .add({'name': "new task 1"});
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add_a_photo),
      ),
    ]);
  }
}
