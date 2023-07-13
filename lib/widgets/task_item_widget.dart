import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../model/subtask_model.dart';
import '../model/task_model.dart';
import '../presentation/app_colors.dart';
import '../providers/theme_provider.dart';
import '../tasks_page/tasks_widget_model.dart';
import '../utils/clipboard_utils.dart';
import 'autosize_text_field.dart';
import 'custom_check_box.dart';
import 'dialog/adaptive_dialog.dart';
import 'expandable_section.dart';

class TextItemWidget extends StatefulWidget {
  const TextItemWidget(
      {Key? key,
      required this.model,
      required this.index,
      required this.onChanged,
      required this.onLongPress,
      required this.onTapDelete})
      : super(key: key);

  final int index;
  final TaskModel model;
  final void Function(TaskModel) onChanged;
  final void Function()? onLongPress;
  final VoidCallback onTapDelete;

  @override
  State<TextItemWidget> createState() => _TextItemWidgetState();
}

class _TextItemWidgetState extends State<TextItemWidget> {
  bool isExpand = true;

  late List<FocusNode> focuses;
  //Timer? _debounce;
  @override
  void initState() {
    focuses =
        List.generate(widget.model.subtasks.length, (index) => FocusNode());
    print('### INIT ${focuses.length}');
    //print('### INITSTATE@ ${widget.model.text}');
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TextItemWidget oldWidget) {
    if (oldWidget.model.subtasks.length != widget.model.subtasks.length) {
      focuses =
          List.generate(widget.model.subtasks.length, (index) => FocusNode());
      print('### ONCHGNE ${focuses.length}');
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final _model = context.watch<TasksWidgetModel>();
    final colorTheme = context.read<ModelTheme>().colorTheme;
    final listDone = widget.model.subtasks.map((e) => e.isDone!);

    final bool isGroup = widget.model.subtasks.isNotEmpty;

    return InkWell(
      focusColor: Colors.grey.withOpacity(0.1),
      canRequestFocus: false,
      onLongPress: widget.onLongPress,
      onTap: isDesktop
          ? null
          : () async {
              final newModel = await showGroupEditor(widget.model);
              if (newModel != null) {
                widget.onChanged(newModel);
                /*  if (newModel.notificationDate != null) {
                        NotificationService().scheduleNotification(
                            2, newModel.notificationDate!, newModel.text);
                      } */
              }
            },
      child: Padding(
        padding: EdgeInsets.fromLTRB(isGroup ? 24 : 20, 0, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*         Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ReorderableDragStartListener(
                index: widget.index,
                child: Icon(
                  Icons.drag_handle,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
                  size: 16,
                ),
              ),
            ), */
            if (isGroup)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 4),
                child: InkWell(
                  canRequestFocus: false,
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    isExpand = !isExpand;
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      isExpand && !_model.isEditingMode
                          ? CupertinoIcons.chevron_down
                          : CupertinoIcons.chevron_right,
                      color: const Color(0xFF8D8D95),
                      size: 14,
                    ),
                  ),
                ),
              )
            else
              CheckboxCustom(
                onChanged: !isGroup
                    ? (value) {
                        final newModel = widget.model
                            .copyWith(isDone: value, isVisible: value != null);

                        widget.onChanged(newModel);
                      }
                    : null,
                disabled: widget.model.isVisible == false,
                value: widget.model.isDone!,
              ),
            // const SizedBox(width: 6),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(top: isDesktop ? 8 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: InkWell(
                            canRequestFocus: false,
                            onTap: isGroup && !isDesktop
                                ? () {
                                    isExpand = !isExpand;
                                    setState(() {});
                                  }
                                : null,
                            child: isDesktop
                                ? TextFieldTaskWidget(
                                    onNextFocus: () {},
                                    onPreviousFocus: () {},
                                    focus: FocusNode(),
                                    onDeleteTask: () {},
                                    style: TextStyle(
                                      fontSize: isGroup ? 16 : 14,
                                      fontWeight:
                                          isGroup ? FontWeight.bold : null,
                                      color: widget.model.isDone == true &&
                                              !isGroup
                                          ? Colors.grey
                                          : colorTheme.sidebarIconColor,
                                      decorationColor: colorTheme.primaryColor,
                                    ),
                                    initialText: widget.model.text,
                                    onChangeText: (String text) {
                                      widget.onChanged(
                                          widget.model.copyWith(text: text));
                                    },
                                    onTapCreateNewSubtask: (item) {
                                      final subtasks =
                                          List.of(widget.model.subtasks)
                                            ..insert(0, SubtaskModel.empty());
                                      final task = widget.model
                                          .copyWith(subtasks: subtasks);
                                      widget.onChanged(task);
                                    },
                                  )
                                /*    TextFormField(
                                    style: TextStyle(
                                      fontSize: isGroup ? 16 : 14,
                                      fontWeight:
                                          isGroup ? FontWeight.bold : null,
                                      color: widget.model.isDone == true
                                          ? Colors.grey
                                          : colorTheme.sidebarIconColor,
                                      decorationColor: colorTheme.primaryColor,
                                    ),
                                    initialValue: widget.model.text,
                                    decoration: const InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 4),
                                      isDense: true,
                                      border: InputBorder.none,
                                    ),
                                  ) */
                                : Text(
                                    widget.model.text,
                                    style: TextStyle(
                                      fontSize: isGroup ? 16 : null,
                                      fontWeight:
                                          isGroup ? FontWeight.bold : null,
                                      color: widget.model.isDone == true
                                          ? Colors.grey
                                          : colorTheme.sidebarIconColor,
                                      decorationColor: colorTheme.primaryColor,
                                      /*   decorationThickness: 1,
                                decoration: widget.model.subtasks.isEmpty &&
                                        widget.model.isDone == true
                                    ? TextDecoration.lineThrough
                                    : null, */
                                    ),
                                    /*   Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: widget.model.tasks.isEmpty &&
                                          widget.model.isDone == true
                                      ? const Color(0xFF5F5e63)
                                      : null,
                                  decoration: widget.model.tasks.isEmpty &&
                                          widget.model.isDone == true
                                      ? TextDecoration.lineThrough
                                      : null), */
                                  ),
                          ),
                        ),
                        if (isGroup)
                          Container(
                            margin: const EdgeInsets.only(
                              left: 12,
                              // top: isDesktop ? 6 : 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '${widget.model.subtasks.where((element) => element.isDone!).length}/${widget.model.subtasks.length}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                    if (widget.model.notificationDate != null)
                      Row(
                        children: [
                          const Icon(
                            //CupertinoIcons.calendar,
                            Icons.calendar_month,
                            color: AppColors.gray,
                            size: 12,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            DateFormat('dd MMM hh:mm')
                                .format(widget.model.notificationDate!),
                            style: const TextStyle(
                                color: AppColors.gray, fontSize: 12),
                          ),
                        ],
                      ),
                    if (isGroup)
                      ExpandedSection(
                        expand: isExpand && !_model.isEditingMode,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                          child: Column(
                            children: widget.model.subtasks.map((item) {
                              final i = widget.model.subtasks.indexOf(item);
                              return _SubtaskItemWidget(
                                item,
                                focus: focuses[i],
                                onNextFocus: () {
                                  print('### ${focuses.length - 1}');
                                  print('### ${i + 1}');
                                  if (i + 1 <= focuses.length - 1) {
                                    focuses[i + 1].requestFocus();

                                    print('### next');
                                  } else {
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                                onPreviousFocus: () {
                                  print('### ${i - 1}');
                                  if (i - 1 >= 0) {
                                    focuses[i - 1].requestFocus();

                                    print('### previos');
                                  } else {
                                    print('### eror');
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                                key: ValueKey('${item.text}$i'),
                                onTapCreateNewSubtask: (value) {
                                  // focuses.insert(i + 1, FocusNode());
                                  final tasks = List.of(widget.model.subtasks)
                                    ..[i] = value
                                    ..insert(i + 1, SubtaskModel.empty());
                                  final newModel =
                                      widget.model.copyWith(subtasks: tasks);
                                  widget.onChanged(newModel);

                                  setState(() {});
                                  print('### fdsfdsf');
                                  Future<void>.delayed(
                                          const Duration(milliseconds: 250))
                                      .then((value) {
                                    focuses[i + 1].requestFocus();
                                  });
                                },
                                onChange: (value) {
                                  /*  final newTask = item.copyWith(
                                      isDone: value, isVisible: value != null); */
                                  final tasks = List.of(widget.model.subtasks)
                                    ..[i] = value;
                                  final newModel =
                                      widget.model.copyWith(subtasks: tasks);
                                  widget.onChanged(newModel);
                                  setState(() {});
                                },
                                onTap: () async {
                                  final newModel =
                                      await showGroupEditor(widget.model);
                                  if (newModel != null) {
                                    widget.onChanged(newModel);
                                    /*  if (newModel.notificationDate != null) {
                        NotificationService().scheduleNotification(
                            2, newModel.notificationDate!, newModel.text);
                    } */
                                  }
                                  /*    final text = await inputTextDialog(item.text!);
                  if (text != null) {
                    final newTask = item.copyWith(text: text);
                    final tasks = List.of(widget.model.tasks)..[i] = newTask;
                    final newModel = widget.model.copyWith(tasks: tasks);
                    widget.onChanged(newModel);
                  } */
                                },
                                onDeleteSubtask: () {
                                  final tasks = List.of(widget.model.subtasks)
                                    ..removeAt(i);

                                  final newModel =
                                      widget.model.copyWith(subtasks: tasks);
                                  widget.onChanged(newModel);
                                  setState(() {});

                                  print('### ${i - 1}');
                                  if (i - 1 >= 0) {
                                    focuses[i - 1].requestFocus();

                                    print('### previos');
                                  } else {
                                    print('### eror');
                                    FocusScope.of(context).nextFocus();
                                  }

                                  // deleteTask(item, i);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),

            /*   const SizedBox(
              width: 6,
            ), */
            /*   if (isGroup)
              InkWell(
                  onTap: () async {
                    final text = await inputTextDialog();
                    if (text != null) {
                      final tasks = List.of(widget.model.tasks)
                        ..add(TaskModel(
                            id: widget.model.tasks.length,
                            text: text,
                            isDone: false,
                            createdOn: DateTime.now(),
                            isVisible: true));
                      final newModel =
                          widget.model.copyWith(tasks: tasks);
                      widget.onChanged(newModel);
                    }
                  },
                  child: const Icon(Icons.add, size: 16)), */
          ],
        ),
      ),
    );
  }

  void _deleteTask(SubtaskModel item, int index) {
    if (item.text!.isEmpty) {
      final tasks = List.of(widget.model.subtasks)..removeAt(index);
      final newGroup = widget.model.copyWith(subtasks: tasks);

      widget.onChanged(newGroup);
    } else {
      showDeleteTaskDialog(
          onTapOK: () {
            final tasks = List.of(widget.model.subtasks)..removeAt(index);
            final newGroup = widget.model.copyWith(subtasks: tasks);
            widget.onChanged(newGroup);
          },
          title: 'DELETE?');
    }
  }

  void copyToClipboard() {
    final bool hasData = ClipboardUtils.copyGroupToClipboard(widget.model);
    if (hasData) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Group copied to buffer'),
        duration: Duration(milliseconds: 500),
      ));
    }
  }
}

class _SubtaskItemWidget extends StatelessWidget {
  const _SubtaskItemWidget(
    this.item, {
    Key? key,
    this.onTap,
    required this.onChange,
    required this.focus,
    required this.onDeleteSubtask,
    required this.onTapCreateNewSubtask,
    required this.onNextFocus,
    required this.onPreviousFocus,
  }) : super(key: key);

  final SubtaskModel item;
  final void Function()? onTap;
  final FocusNode focus;
  final VoidCallback onNextFocus;
  final VoidCallback onPreviousFocus;
  final void Function() onDeleteSubtask;
  final void Function(SubtaskModel value) onChange;
  final void Function(SubtaskModel text) onTapCreateNewSubtask;

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.read<ModelTheme>().colorTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxCustom(
          onChanged: (value) {
            onChange(item.copyWith(isDone: value));
          },
          disabled: item.isVisible == false,
          value: item.isDone,
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(top: isDesktop ? 8 : 10),
            child: GestureDetector(
                /*   onLongPressStart: (det) {
                  showContextMenu(
                      globalPosition: det.globalPosition,
                      items: [
                        CustomPopupMenuItem(
                            value: 'Delete',
                            iconColor: Colors.redAccent,
                            textColor: Colors.redAccent),
                      ],
                      onSelected: (value) async {
                        if (value == 'Delete') {
                          onDelete();
                        }
                      });
                },
                onSecondaryTapUp: (tapDetails) {
                  showContextMenu(
                      globalPosition: tapDetails.globalPosition,
                      items: [
                        CustomPopupMenuItem(
                            value: 'Delete',
                            iconColor: Colors.redAccent,
                            textColor: Colors.redAccent),
                      ],
                      onSelected: (value) async {
                        if (value == 'Delete') {
                          onDelete();
                        }
                      });
                }, */
                //onTap: onTap,
                child: isDesktop
                    ? TextFieldTaskWidget(
                        focus: focus,
                        onDeleteTask: onDeleteSubtask,
                        onNextFocus: onNextFocus,
                        onPreviousFocus: onPreviousFocus,
                        onTapCreateNewSubtask: (value) {
                          onTapCreateNewSubtask(item.copyWith(text: value));
                        },
                        onChangeText: (text) {
                          if (text != item.text) {
                            onChange(item.copyWith(text: text));
                          }
                        },
                        style: TextStyle(
                          fontSize: 14,
                          decorationColor: colorTheme.primaryColor,
                        ),
                        initialText: item.text!,
                      )
                    : Text(
                        item.text!,
                        style: TextStyle(
                          color: item.isDone!
                              ? Colors.grey
                              : colorTheme.sidebarIconColor,
                          decorationColor: colorTheme.primaryColor,
                          // decoration: item.isDone! ? TextDecoration.lineThrough : null
                        ),
                      )),
          ),
        )
      ],
    );
  }
}

class TextFieldTaskWidget extends StatefulWidget {
  const TextFieldTaskWidget({
    Key? key,
    required this.initialText,
    required this.onChangeText,
    required this.onTapCreateNewSubtask,
    required this.style,
    required this.onDeleteTask,
    required this.focus,
    required this.onNextFocus,
    required this.onPreviousFocus,
  }) : super(key: key);

  final String initialText;
  final VoidCallback onDeleteTask;
  final VoidCallback onNextFocus;
  final VoidCallback onPreviousFocus;
  final void Function(String text) onChangeText;
  final void Function(String text) onTapCreateNewSubtask;
  final TextStyle style;
  final FocusNode focus;

  @override
  State<TextFieldTaskWidget> createState() => _TextFieldTaskWidgetState();
}

class _TextFieldTaskWidgetState extends State<TextFieldTaskWidget> {
  final TextEditingController controller = TextEditingController();

  bool hasChanges = false;

  @override
  void dispose() {
    controller.dispose();
    widget.focus.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (!widget.focus.hasFocus) {
      if (hasChanges) {
        print('### exti with changes');
        widget.onChangeText(controller.text);
      }
    }
  }

  @override
  void initState() {
    controller.text = widget.initialText;

    widget.focus.addListener(_onFocusChange);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.read<ModelTheme>().colorTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RawKeyboardListener(
          focusNode: FocusNode(canRequestFocus: false),
          onKey: (RawKeyEvent event) {
            if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
              widget.focus.unfocus();
              widget.onNextFocus();
            } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
              widget.focus.unfocus();
              widget.onPreviousFocus();
            } else if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
              if (controller.text.isEmpty) {
                hasChanges = false;

                widget.focus.unfocus();
                widget.onDeleteTask();
              }
            } else if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
              reset();
            } else if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
                event.isShiftPressed) {
              print('Shift + Enter is pressed');
              hasChanges = false;
              widget.onTapCreateNewSubtask(controller.text);
            } else if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              print('Enter is pressed');
              hasChanges = false;
              widget.onChangeText(controller.text);
            }
          },
          child: AutoSizeTextField(
            focusNode: widget.focus,
            minWidth: controller.text.isEmpty ? 100 : null,
            fullwidth: false,
            onChanged: (value) {
              hasChanges = value != widget.initialText;
              setState(() {});
            },
            controller: controller,
            style: widget.style,
            decoration: const InputDecoration(
              hintText: 'Enter text',
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ),
        if (hasChanges)
          InkWell(
            onTap: reset,
            child: const Icon(
              Icons.close,
              color: Colors.red,
              size: 17,
            ),
          )
      ],
    );
  }

  void reset() {
    controller.text = widget.initialText;
    setState(() {
      hasChanges = false;
    });

    widget.focus.unfocus();
  }
}
