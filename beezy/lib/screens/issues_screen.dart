import 'package:flutter/material.dart';
import '../models/board.dart';

const List<String> sprint = <String>['backlog', 'board'];
const List<String> sprintFilter = <String>['all', 'backlog', 'board'];
const List<String> statusFilter = <String>['all', 'open', 'closed', 'reopened'];
//const List<Widget> boardTag = <Widget>[Text('board')];

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key, required this.board});

  final Board board;

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  //List<bool> _boardTag = <bool>[false];
  String dropdownValueSprint = sprintFilter.first;
  String dropdownValueStatus = sprintFilter.first;
  String dropdownValueColumn = 'all';

  String _dropdownValue(Task task) {
    String dropdownValue = '';
    for (ColumnBZ column in widget.board.columns) {
      if (column.id == task.columnID) {
        dropdownValue = column.columnTitle;
      }
    }
    return dropdownValue;
  }

  List<String> _columnFilter() {
    List<String> status = <String>[];
    status.add('all');
    for (ColumnBZ column in widget.board.columns) {
      status.add(column.columnTitle);
    }
    return status;
  }

  List<Widget> _getTasks(BuildContext context) {
    final List<Widget> taskWidgets = <Widget>[];
    List<Task> filteredTasks;
    final List<Task> allTasks = widget.board.tasks + widget.board.backlogTasks;

    if (_searchText.isEmpty) {
      filteredTasks = allTasks;
    } else {
      filteredTasks = allTasks
          .where((task) =>
              task.name.toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
    }

    // if (_boardTag[0]) {
    //   filteredTasks =
    //       filteredTasks.where((task) => task.sprintID == 1).toList();
    // }

    if (dropdownValueSprint == sprintFilter[1]) {
      filteredTasks =
          filteredTasks.where((task) => task.sprintID == 0).toList();
    } else if (dropdownValueSprint == sprintFilter[2]) {
      filteredTasks =
          filteredTasks.where((task) => task.sprintID == 1).toList();
    }

    if (dropdownValueStatus == statusFilter[1]) {
      filteredTasks = filteredTasks.where((task) => task.status == 0).toList();
    } else if (dropdownValueStatus == statusFilter[2]) {
      filteredTasks = filteredTasks.where((task) => task.status == 1).toList();
    } else if (dropdownValueStatus == statusFilter[3]) {
      filteredTasks = filteredTasks.where((task) => task.status == 2).toList();
    }

    late int columnID;
    for (String columnSTR in _columnFilter()) {
      if (dropdownValueColumn == columnSTR && columnSTR != 'all') {
        columnID = widget.board.columns
            .where((column) => column.columnTitle == columnSTR)
            .first
            .id;
        filteredTasks =
            filteredTasks.where((task) => task.columnID == columnID).toList();
      }
    }

    for (Task task in filteredTasks) {
      taskWidgets.add(_buildTask(task, context));
    }
    return taskWidgets;
  }

  Widget _buildTask(Task task, BuildContext context) {
    return Container(
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
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                                width: 70,
                                child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 244, 210, 126),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    child: Container(
                                        padding: const EdgeInsets.all(5),
                                        child: Center(
                                            child: Text(
                                                sprint[task.sprintID])))))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                                width: 110,
                                child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 244, 210, 126),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    child: Container(
                                        padding: const EdgeInsets.all(5),
                                        child: Center(
                                            child:
                                                Text(_dropdownValue(task))))))),
                      ],
                    )))));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name...',
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchText = '';
              });
            },
            icon: const Icon(Icons.clear),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
      ),
      Row(children: [
        const Icon(Icons.filter_alt, color: Color.fromARGB(255, 99, 91, 82)),
        const Text('Sprint: '),
        DropdownButton<String>(
          value: dropdownValueSprint,
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(color: Colors.black),
          underline: Container(
            height: 2,
            color: Colors.amber,
          ),
          onChanged: (String? value) {
            setState(() {
              dropdownValueSprint = value!;
            });
          },
          items: sprintFilter.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const Text('Status: '),
        DropdownButton<String>(
          value: dropdownValueStatus,
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(color: Colors.black),
          underline: Container(
            height: 2,
            color: Colors.amber,
          ),
          onChanged: (String? value) {
            setState(() {
              dropdownValueStatus = value!;
            });
          },
          items: statusFilter.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const Text('Column: '),
        DropdownButton<String>(
          value: dropdownValueColumn,
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(color: Colors.black),
          underline: Container(
            height: 2,
            color: Colors.amber,
          ),
          onChanged: (String? value) {
            setState(() {
              dropdownValueColumn = value!;
            });
          },
          items: _columnFilter().map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        )
        // Container(
        //     padding: EdgeInsets.all(5),
        //     child: ToggleButtons(
        //       direction: Axis.horizontal,
        //       onPressed: (int i) {
        //         setState(() {
        //           _boardTag[i] = !_boardTag[i];
        //         });
        //       },
        //       borderRadius: const BorderRadius.all(Radius.circular(8)),
        //       selectedBorderColor: Colors.amber[700],
        //       selectedColor: Colors.white,
        //       fillColor: Colors.amber[200],
        //       color: Colors.amber[400],
        //       constraints: const BoxConstraints(
        //         minHeight: 20.0,
        //         minWidth: 80.0,
        //       ),
        //       isSelected: _boardTag,
        //       children: boardTag,
        //     )),
      ]),
      Expanded(
          child: SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                      child: DecoratedBox(
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 223, 142),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Column(
                              children: _getTasks(context),
                            ),
                          ))))))
    ]);
  }
}
