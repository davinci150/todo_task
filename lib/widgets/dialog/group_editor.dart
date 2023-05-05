import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/model/task_model.dart';

import '../../model/group_model.dart';
import '../../presentation/my_flutter_app_icons.dart';
import '../../providers/theme_provider.dart';
import '../custom_check_box.dart';

class GroupEditorWidget extends StatefulWidget {
  const GroupEditorWidget({Key? key, required this.groupModel})
      : super(key: key);

  final GroupModel groupModel;

  @override
  State<GroupEditorWidget> createState() => _GroupEditorWidgetState();
}

class _GroupEditorWidgetState extends State<GroupEditorWidget> {
  late GroupModel groupModel;

  ScrollController scrollController = ScrollController();
  List<FocusNode> focuses = [];
  @override
  void initState() {
    focuses.addAll(widget.groupModel.tasks.map((e) => FocusNode()));
    groupModel = widget.groupModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(focuses.length);
    final colorTheme = context.read<ModelTheme>().colorTheme;
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorTheme.mobileScaffoldColor,
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (groupModel.tasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: CheckboxCustom(
                            onChanged: null,
                            disabled: groupModel.isVisible == false,
                            value: groupModel.isDone,
                          ),
                        ),
                      Expanded(
                        child: TextFormField(
                          onEditingComplete: () {
                            focuses.insert(0, FocusNode());
                            final tasks = List.of(groupModel.tasks)
                              ..insert(
                                  0,
                                  TaskModel(
                                      text: '',
                                      isDone: false,
                                      createdOn: DateTime.now(),
                                      isVisible: true,
                                      id: 3));

                            groupModel = groupModel.copyWith(tasks: tasks);
                            setState(() {});

                            Future<void>.delayed(Duration(milliseconds: 200))
                                .then((value) {
                              focuses[0].requestFocus();
                              // FocusScope.of(context).nextFocus();
                            });
                          },
                          style: TextStyle(color: colorTheme.sidebarIconColor),
                          textInputAction: TextInputAction.next,
                          autofocus: groupModel.tasks.isEmpty,
                          initialValue: groupModel.text,
                          onChanged: (value) {
                            groupModel = groupModel.copyWith(text: value);
                          },
                          decoration: const InputDecoration(
                              isDense: true, border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: groupModel.tasks.map((e) {
                      final index = groupModel.tasks.indexOf(e);
                      return Row(
                        children: [
                          CheckboxCustom(
                            onChanged: null,
                            disabled: e.isVisible == false,
                            value: e.isDone,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: RawKeyboardListener(
                              // autofocus: index == groupModel.tasks.length - 1,
                              focusNode: FocusNode(),
                              onKey: (event) {
                                if (event.isKeyPressed(
                                    LogicalKeyboardKey.backspace)) {
                                  print('### eventl');

                                  final tasks = List.of(groupModel.tasks)
                                    ..removeAt(index);

                                  groupModel =
                                      groupModel.copyWith(tasks: tasks);

                                  if (index != 0) {
                                    focuses[index - 1].requestFocus();
                                  } else if (focuses.length > 1) {
                                    focuses[index].requestFocus();
                                  }
                                  focuses.removeAt(index);

                                  setState(() {});
                                }
                                print('### eventl 1 ${event}');
                              },
                              child: TextFormField(
                                key: ValueKey(focuses[index]),
                                focusNode: focuses[index],
                                /*    onSaved: (value) {
                                  print('### ${value}');
                                }, */
                                onEditingComplete: () {
                                  print('### ds');
                                  focuses.insert(index + 1, FocusNode());

                                  final tasks = List.of(groupModel.tasks)
                                    ..insert(
                                        index + 1,
                                        TaskModel(
                                            text: '',
                                            isDone: false,
                                            createdOn: DateTime.now(),
                                            isVisible: true,
                                            id: 3));

                                  groupModel =
                                      groupModel.copyWith(tasks: tasks);
                                  setState(() {});

                                  Future<void>.delayed(
                                          Duration(milliseconds: 200))
                                      .then((value) {
                                    focuses[index + 1].requestFocus();
                                  });
                                },
                                onFieldSubmitted: (value) {
                                  print('### ${value}');
                                },
                                autofocus: index == groupModel.tasks.length - 1,
                                onChanged: (value) {
                                  final tasks = List.of(groupModel.tasks);
                                  final task =
                                      tasks[index].copyWith(text: value);
                                  tasks[index] = task;

                                  groupModel =
                                      groupModel.copyWith(tasks: tasks);
                                },
                                initialValue: e.text,
                                style: TextStyle(
                                    color: colorTheme.sidebarIconColor),
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                    isDense: true, border: InputBorder.none),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              NeumorphicButton(
                onPressed: () async {
                  DateTime initialDate = DateTime.now();
                  if (groupModel.notificationDate != null) {
                    if (groupModel.notificationDate!.isAfter(DateTime.now())) {
                      initialDate = groupModel.notificationDate!;
                    }
                  }
                  DateTime? pickedDateTime;
                  pickedDateTime = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (pickedDateTime != null) {
                    final pickTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: DateTime.now().hour,
                            minute: DateTime.now().minute));
                    if (pickTime != null) {
                      final date = DateTime(
                          pickedDateTime.year,
                          pickedDateTime.month,
                          pickedDateTime.day,
                          pickTime.hour,
                          pickTime.minute);
                      date.add(Duration(
                          hours: pickTime.hour, minutes: pickTime.minute));

                      groupModel =
                          groupModel.copyWith(notificationDate: () => date);

                      setState(() {});
                    }
                  }
                },
                style: NeumorphicStyle(
                  intensity: 3,
                  depth: -1.5,
                  color: colorTheme.mobileScaffoldColor,
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(MyFlutterApp.schedule,
                        size: 16, color: colorTheme.sidebarIconColor),
                    const SizedBox(width: 6),
                    Text(
                      groupModel.notificationDate == null
                          ? 'Notification'
                          : DateFormat('HH:mm dd MMM yyyy')
                              .format(groupModel.notificationDate!),
                      style: TextStyle(
                          fontSize: 14, color: colorTheme.sidebarIconColor),
                    ),
                    if (groupModel.notificationDate != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: InkWell(
                          onTap: () {
                            groupModel = groupModel.copyWith(
                                notificationDate: () => null);
                            setState(() {});
                          },
                          child: const Icon(Icons.close, size: 16),
                        ),
                      )
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, groupModel);
                  },
                  child: const Text('Done')),
            ],
          ),
        ],
      ),
    );
  }
}
