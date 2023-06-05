import 'package:flutter/material.dart';
import '../models/board.dart';
import 'package:flutter/services.dart';

const List<String> priority = <String>['low', 'medium', 'high'];
const List<String> status = <String>['open', 'closed', 'reopened'];

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key, required this.selectedTask});

  final Task selectedTask;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
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

  String _getDropdownValue() {
    return priority[widget.selectedTask.priority];
  }

  Widget _editTaskName(BuildContext context) {
    if (isEditingName) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 50, maxWidth: 260),
        child: TextField(
          onSubmitted: (newValue) {
            setState(() {
              widget.selectedTask.name = newValue;
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
        child: Text(widget.selectedTask.name));
  }

  Widget _editTaskDescription(BuildContext context) {
    if (isEditingDescription) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
        child: TextField(
          focusNode: FocusNode(onKey: (node, event) {
            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              setState(() {
                widget.selectedTask.description =
                    widget.selectedTask.descriptionController.text;
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
        height: 200, width: 300, child: Text(widget.selectedTask.description));
  }

  Widget _editTaskPoints(BuildContext context) {
    if (isEditingPoints && widget.selectedTask.status == 0) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100, maxWidth: 260),
        child: TextField(
          onSubmitted: (newValue) {
            setState(() {
              widget.selectedTask.points = int.parse(newValue);
              isEditingPoints = false;
            });
          },
          autofocus: true,
          controller: widget.selectedTask.pointsController,
          //style: Theme.of(context).textTheme.headlineMedium,
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
        widget.selectedTask.points.toString(),
        //style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            //elevation: 16,
            style: const TextStyle(color: Colors.black),
            underline: Container(
              height: 2,
              color: Colors.amber,
            ),
            onChanged: (String? value) {
              setState(() {
                if (value == priority[0]) {
                  widget.selectedTask.priority = 0;
                } else if (value == priority[1]) {
                  widget.selectedTask.priority = 1;
                } else if (value == priority[2]) {
                  widget.selectedTask.priority = 2;
                }
              });
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
