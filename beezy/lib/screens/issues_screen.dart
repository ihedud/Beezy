import 'package:flutter/material.dart';
import '../models/board.dart';

const List<String> sprint = <String>['backlog', 'board'];
const List<String> priority = <String>['low', 'medium', 'high'];
const List<String> sprintFilter = <String>['all', 'backlog', 'board'];
const List<String> statusFilter = <String>['all', 'open', 'closed', 'reopened'];
const List<String> priorityFilter = <String>['all', 'low', 'medium', 'high'];

class IssuesScreen extends StatelessWidget {
  final String userUID;

  const IssuesScreen({Key? key, required this.userUID})
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
            return _IssuesScreen(info: snapshot.data!);
          case ConnectionState.none:
            return ErrorWidget("The stream was wrong (connectionState.none)");
          case ConnectionState.done:
            return ErrorWidget("The stream has ended??");
        }
      },
    );
  }
}

class _IssuesScreen extends StatefulWidget {
  const _IssuesScreen({required this.info});

  final PMTinfo info;

  @override
  State<_IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<_IssuesScreen> {
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  String dropdownValueSprint = sprintFilter.first;
  String dropdownValueStatus = statusFilter.first;
  String dropdownValueColumn = 'all';
  String dropdownValuePriority = priorityFilter.first;

  String _dropdownValue(Task task) {
    String dropdownValue = '';
    for (ColumnBZ column in widget.info.columns) {
      if (column.id == task.columnID) {
        dropdownValue = column.columnTitle;
      }
    }
    return dropdownValue;
  }

  List<String> _columnFilter() {
    List<String> status = <String>[];
    status.add('all');
    for (ColumnBZ column in widget.info.columns) {
      status.add(column.columnTitle);
    }
    return status;
  }

  List<Widget> _getTasks(BuildContext context) {
    final List<Widget> taskWidgets = <Widget>[];
    List<Task> filteredTasks;

    if (_searchText.isEmpty) {
      filteredTasks = widget.info.tasks;
    } else {
      filteredTasks = widget.info.tasks
          .where((task) =>
              task.name.toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
    }

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

    late String columnID;
    for (String columnSTR in _columnFilter()) {
      if (dropdownValueColumn == columnSTR && columnSTR != 'all') {
        columnID = widget.info.columns
            .where((column) => column.columnTitle == columnSTR)
            .first
            .id;
        filteredTasks = filteredTasks
            .where((task) => task.columnID.toString() == columnID)
            .toList();
      }
    }

    if (dropdownValuePriority == priorityFilter[1]) {
      filteredTasks =
          filteredTasks.where((task) => task.priority == 0).toList();
    } else if (dropdownValuePriority == priorityFilter[2]) {
      filteredTasks =
          filteredTasks.where((task) => task.priority == 1).toList();
    } else if (dropdownValuePriority == priorityFilter[3]) {
      filteredTasks =
          filteredTasks.where((task) => task.priority == 2).toList();
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
                    color: Color.fromARGB(255, 230, 146, 38),
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
                        Container(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                                width: 80,
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
                                                priority[task.priority])))))),
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
            color: const Color.fromARGB(255, 230, 146, 38),
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
            color: const Color.fromARGB(255, 230, 146, 38),
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
            color: const Color.fromARGB(255, 230, 146, 38),
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
        ),
        const Text('Priority: '),
        DropdownButton<String>(
          value: dropdownValuePriority,
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(color: Colors.black),
          underline: Container(
            height: 2,
            color: const Color.fromARGB(255, 230, 146, 38),
          ),
          onChanged: (String? value) {
            setState(() {
              dropdownValuePriority = value!;
            });
          },
          items: priorityFilter.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        )
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
