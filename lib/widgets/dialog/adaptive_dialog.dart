import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../../main.dart';
import '../../model/group_model.dart';

import '../../services/context_provider.dart';
import 'group_editor.dart';
import 'input_text_dialog.dart';

class CreateModel {
  CreateModel({required this.text, this.date});
  final String text;
  final DateTime? date;
}

/* Future<CreateModel?> inputTextDialog2(
    [String? initialText,
    DateTime? notificationTime,
    bool? requiredTimePick]) async {
  final context = navigatorKey.currentContext!;
  TextEditingController textEditingController = TextEditingController()
    ..text = initialText ?? '';
  DateTime? pickDate = notificationTime;
  String errorText = '';
  return showDialog<CreateModel>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, snapshot) {
          return AlertDialog(
            content: TextField(
              decoration: InputDecoration(
                  errorText: errorText.isEmpty ? null : errorText),
              onEditingComplete: () {
                Navigator.pop(
                    context,
                    textEditingController.text.isEmpty
                        ? null
                        : CreateModel(
                            text: textEditingController.text, date: pickDate));
              },
              autofocus: true,
              controller: textEditingController,
            ),
            actions: [
              Column(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)));
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
                                errorText = '';
                                snapshot(() {});
                              }
                            }
                          },
                          icon: const Icon(Icons.schedule)),
                      if (pickDate != null)
                        Text(DateFormat('HH:mm dd MMM yyyy').format(pickDate!))
                    ],
                  ),
                  TextButton(
                      onPressed: () {
                        if (requiredTimePick == true && pickDate == null) {
                          errorText = 'Time is required';
                          snapshot(() {});
                        } else {
                          Navigator.pop(
                              context,
                              textEditingController.text.isEmpty
                                  ? null
                                  : CreateModel(
                                      text: textEditingController.text,
                                      date: pickDate));
                        }
                      },
                      child: const Text('OK')),
                ],
              ),
            ],
          );
        });
      });
} */

Future<GroupModel?> showGroupEditor(GroupModel model) async {
  return showAdaptiveDialog<GroupModel?>(GroupEditorWidget(groupModel: model));
}

Future<T?> showAdaptiveDialog<T>(Widget child) async {
  final context = navigatorKey.currentContext!;
  if (isDesktop) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: child));
        });
  }
  return showModalBottomSheet(
      isScrollControlled: true,
      constraints: const BoxConstraints(),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      context: context,
      builder: (ctx) {
        final safeAreaPadding =
            MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .padding
                .top;

        return Padding(
            padding: EdgeInsets.fromLTRB(12, safeAreaPadding + 12, 12,
                12 + MediaQuery.of(context).viewInsets.bottom),
            child: child);
      });
}

Future<String?> inputTextDialog([String? initialText]) async {
  return showAdaptiveDialog<String?>(InputTextDialog(initialText: initialText));
}

void showDeleteTaskDialog(
    {required String title, required VoidCallback onTapOK}) {
  final context = navigatorKey.currentContext!;
  showDialog<void>(
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

Future<void> showAlert({required String title}) async {
  final context = navigatorKey.currentContext!;
  return showDialog<void>(
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
