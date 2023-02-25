import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../context_provider.dart';

class TaskCreated {
  final String text;
  final DateTime? date;

  TaskCreated({required this.text, this.date});
}

Future<TaskCreated?> inpuTextDialog2(
    [String? initialText, DateTime? notificationTime]) async {
  final context = navigatorKey.currentContext!;
  TextEditingController textEditingController = TextEditingController()
    ..text = initialText ?? '';
  DateTime? pickDate = notificationTime;
  return showDialog<TaskCreated>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, snapshot) {
          return AlertDialog(
            content: TextField(
              onEditingComplete: () {
                Navigator.pop(
                    context,
                    TaskCreated(
                        text: textEditingController.text, date: pickDate));
              },
              autofocus: true,
              controller: textEditingController,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () async {
                            DateTime? pickedDateTime;
                            pickedDateTime = await showDatePicker(
                                context: context,
                                initialDate: pickDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate:
                                    DateTime.now().add(Duration(days: 365)));
                            if (pickedDateTime != null) {
                              final pickTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                      hour: DateTime.now().hour,
                                      minute: DateTime.now().minute));
                              if (pickTime != null) {
                                pickDate = DateTime(
                                    pickedDateTime.year,
                                    pickedDateTime.month,
                                    pickedDateTime.day,
                                    pickTime.hour,
                                    pickTime.minute);
                                pickedDateTime.add(Duration(
                                    hours: pickTime.hour,
                                    minutes: pickTime.minute));
                                snapshot(() {});
                              }
                            }
                          },
                          icon: Icon(Icons.schedule)),
                      if (pickDate != null)
                        Text(DateFormat('HH:mm dd MMM yyyy').format(pickDate!))
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(
                                context,
                                TaskCreated(
                                    text: textEditingController.text,
                                    date: pickDate));
                          },
                          child: const Text('OK')),
                    ],
                  ),
                ],
              ),
            ],
          );
        });
      });
}

Future<String?> inpuTextDialog([String? initialText]) async {
  final context = navigatorKey.currentContext!;
  TextEditingController textEditingController = TextEditingController()
    ..text = initialText ?? '';
  return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: TextField(
            onEditingComplete: () {
              Navigator.pop(context, textEditingController.text);
            },
            autofocus: true,
            controller: textEditingController,
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context, textEditingController.text);
                },
                child: const Text('OK')),
          ],
        );
      });
}

void showDeleteTaskDialog(
    {required String title, required VoidCallback onTapOK}) {
  final context = navigatorKey.currentContext!;
  showDialog(
      context: context,
      builder: (ctx) {
        return Focus(
          autofocus: true,
          onKey: (node, event) {
            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              onTapOK();

              Navigator.pop(context);
            }
            return KeyEventResult.ignored;
          },
          child: AlertDialog(
            title: Text(title),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    onTapOK();

                    Navigator.pop(context);
                  },
                  child: const Text('OK')),
            ],
          ),
        );
      });
}

void showAlert({required String title}) {
  final context = navigatorKey.currentContext!;
  showDialog(
      context: context,
      builder: (ctx) {
        return Focus(
          autofocus: true,
          onKey: (node, event) {
            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              Navigator.pop(context);
            }
            return KeyEventResult.ignored;
          },
          child: AlertDialog(
            title: Text(title),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK')),
            ],
          ),
        );
      });
}
