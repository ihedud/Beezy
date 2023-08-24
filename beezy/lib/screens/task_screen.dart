import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/board.dart';
import 'package:flutter/services.dart';

const List<String> priority = <String>['low', 'medium', 'high'];
const List<String> status = <String>['open', 'closed', 'reopened'];

class TaskScreen extends StatelessWidget {
  final String taskID;
  final String userUID;

  const TaskScreen({Key? key, required this.taskID, required this.userUID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userTaskSnapshot(userUID, taskID),
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
            return _TaskScreen(userUID: userUID, selectedTask: snapshot.data!);
          case ConnectionState.none:
            return ErrorWidget("The stream was wrong (connectionState.none)");
          case ConnectionState.done:
            return ErrorWidget("The stream has ended??");
        }
      },
    );
  }
}

class _TaskScreen extends StatefulWidget {
  const _TaskScreen({required this.selectedTask, required this.userUID});

  final Task selectedTask;
  final String userUID;

  @override
  State<_TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<_TaskScreen> {
  bool isEditingName = false;
  bool isEditingDescription = false;
  bool isEditingPoints = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> updateName(String newName) async {
    try {
      DocumentReference taskRef = FirebaseFirestore.instance
          .doc('/users/${widget.userUID}/PMTinfo/PMTinfo/tasks/${widget.selectedTask.id}');

      await taskRef.update({'name': newName});
    } catch (e) {
      print('Error updating name: $e');
    }
  }

  Future<void> updateDescription(String newText) async {
    try {
      DocumentReference taskRef = FirebaseFirestore.instance
          .doc('/users/${widget.userUID}/PMTinfo/PMTinfo/tasks/${widget.selectedTask.id}');

      await taskRef.update({'description': newText});
    } catch (e) {
      print('Error updating description: $e');
    }
  }

  Future<void> updatePoints(int newValue) async {
    try {
      DocumentReference taskRef = FirebaseFirestore.instance
          .doc('/users/${widget.userUID}/PMTinfo/PMTinfo/tasks/${widget.selectedTask.id}');

      await taskRef.update({'points': newValue});
    } catch (e) {
      print('Error updating points: $e');
    }
  }

  Future<void> updatePriority(String value) async {
    try {
      DocumentReference taskRef = FirebaseFirestore.instance
          .doc('/users/${widget.userUID}/PMTinfo/PMTinfo/tasks/${widget.selectedTask.id}');
      late int newValue;
      if (value == priority[0]) {
        newValue = 0;
      } else if (value == priority[1]) {
        newValue = 1;
      } else if (value == priority[2]) {
        newValue = 2;
      }
      await taskRef.update({'priority': newValue});
    } catch (e) {
      print('Error updating priority: $e');
    }
  }

  String _getDropdownValue() {
    return priority[widget.selectedTask.priority];
  }

  Widget _editTaskName(BuildContext context) {
    if (isEditingName) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 50, maxWidth: 260),
        child: TextField(
          onSubmitted: (newValue) {
            updateName(newValue);
            setState(() {
              isEditingName = false;
            });
          },
          autofocus: true,
          controller: widget.selectedTask.nameController,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );
    }
    return InkWell(
        onTap: () {
          setState(() {
            isEditingName = true;
          });
        },
        child: Text(isEditingName
            ? widget.selectedTask.nameController.text
            : widget.selectedTask.name));
  }

  Widget _editTaskDescription(BuildContext context) {
    if (isEditingDescription) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
        child: TextField(
          focusNode: FocusNode(onKey: (node, event) {
            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              updateDescription(widget.selectedTask.descriptionController.text);
              setState(() {
                isEditingDescription = false;
                node.unfocus();
              });
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          }),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          autofocus: true,
          controller: widget.selectedTask.descriptionController,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return SizedBox(
        height: 200,
        width: 300,
        child: Text(isEditingDescription
            ? widget.selectedTask.descriptionController.text
            : widget.selectedTask.description));
  }

  Widget _editTaskPoints(BuildContext context) {
    if (isEditingPoints && widget.selectedTask.status == 0) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100, maxWidth: 260),
        child: TextField(
          onSubmitted: (newValue) {
            updatePoints(int.parse(newValue));
            setState(() {
              isEditingPoints = false;
            });
          },
          autofocus: true,
          controller: widget.selectedTask.pointsController,
        ),
      );
    } else if (widget.selectedTask.status != 0) {
      return Text(widget.selectedTask.points.toString());
    }
    return InkWell(
      onTap: () {
        setState(() {
          isEditingPoints = true;
        });
      },
      child: Text(
        isEditingPoints
            ? widget.selectedTask.pointsController.text
            : widget.selectedTask.points.toString(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 230, 146, 38),
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: _editTaskName(context),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 100, children: [
          const Text('Description:'),
          _editTaskDescription(context),
          OutlinedButton(
              onPressed: () {
                setState(() {
                  isEditingDescription = true;
                });
              },
              child: const Icon(Icons.edit)),
        ]),
        Wrap(spacing: 100, children: [
          const Text('Priority:'),
          DropdownButton<String>(
            value: _getDropdownValue(),
            icon: const Icon(Icons.arrow_drop_down),
            style: const TextStyle(color: Colors.black),
            underline: Container(
              height: 2,
              color: Color.fromARGB(255, 230, 146, 38),
            ),
            onChanged: (String? value) {
              updatePriority(value!);
            },
            items: priority.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )
        ]),
        Wrap(
          spacing: 100,
          children: [const Text('Points:'), _editTaskPoints(context)],
        ),
        Wrap(
          spacing: 100,
          children: [
            const Text('Status:'),
            Text(status[widget.selectedTask.status])
          ],
        )
      ]),
    );
  }
}
