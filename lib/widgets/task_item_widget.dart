import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/widgets/context_menu.dart';
import 'package:todo_task/model/group_model.dart';
import 'package:todo_task/services/notification_service.dart';
import 'package:todo_task/utils/clipboard_utils.dart';
import '../providers/theme_provider.dart';
import 'dialog/adaptive_dialog.dart';
import '../model/task_model.dart';
import 'custom_check_box.dart';
import 'expandable_section.dart';

class TextItemWidget extends StatefulWidget {
  const TextItemWidget(
      {Key? key,
      required this.model,
      required this.index,
      required this.onChanged,
      required this.isExpand,
      required this.onLongPress,
      required this.onTapDelete})
      : super(key: key);

  final int index;
  final GroupModel model;
  final void Function(GroupModel) onChanged;
  final void Function()? onLongPress;
  final VoidCallback onTapDelete;
  final bool isExpand;

  @override
  State<TextItemWidget> createState() => _TextItemWidgetState();
}

class _TextItemWidgetState extends State<TextItemWidget> {
  bool isExpand = true;
  //Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.read<ModelTheme>().colorTheme;
    final listDone = widget.model.tasks.map((e) => e.isDone!);

    final bool isGroup = widget.model.tasks.isNotEmpty;

    return InkWell(
      onLongPress: widget.onLongPress,
      /*   onLongPressStart: (det) {
                    showContextMenu(
                        globalPosition: det.globalPosition,
                        items: [
                          if (!isGroup)
                            CustomPopupMenuItem(
                              value: 'Add subtask',
                            ),
                          CustomPopupMenuItem(
                            value: 'Copy',
                          ),
                          CustomPopupMenuItem(
                              value: 'Delete',
                              iconColor: Colors.redAccent,
                              textColor: Colors.redAccent),
                        ],
                        onSelected: (value) async {
                          if (value == 'Copy') {
                            copyToClipboard();
                          } else if (value == 'Delete') {
                            if ((widget.model.text).isEmpty) {
                              widget.onTapDelete();
                            } else {
                              showDeleteTaskDialog(
                                  onTapOK: () {
                                    widget.onTapDelete();
                                  },
                                  title: 'DELETE?');
                            }
                          } else if (value == 'Add subtask') {
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
                          }
                        });
                  },
                  onSecondaryTapUp: (tapDetails) {
                    showContextMenu(
                        globalPosition: tapDetails.globalPosition,
                        items: [
                          if (!isGroup)
                            CustomPopupMenuItem(
                              value: 'Add subtask',
                            ),
                          CustomPopupMenuItem(
                            value: 'Copy',
                          ),
                          CustomPopupMenuItem(
                              value: 'Delete',
                              iconColor: Colors.redAccent,
                              textColor: Colors.redAccent),
                        ],
                        onSelected: (value) async {
                          if (value == 'Copy') {
                            copyToClipboard();
                          } else if (value == 'Delete') {
                            if ((widget.model.text).isEmpty) {
                              widget.onTapDelete();
                            } else {
                              showDeleteTaskDialog(
                                  onTapOK: () {
                                    widget.onTapDelete();
                                  },
                                  title: 'DELETE?');
                            }
                          } else if (value == 'Add subtask') {
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
                          }
                        });
                  }, */
      onTap: () async {
        final newModel = await showGroupEditor(widget.model);
        if (newModel != null) {
          widget.onChanged(newModel);
          /*  if (newModel.notificationDate != null) {
                        NotificationService().scheduleNotification(
                            2, newModel.notificationDate!, newModel.text);
                      } */
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(isGroup ? 20 : 20, 4, 20, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(right: 6),
                //   child: ReorderableDragStartListener(
                //     index: widget.index,
                //     child: Icon(
                //       Icons.drag_handle,
                //       color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
                //       size: 16,
                //     ),
                //   ),
                // ),
                if (isGroup)
                  GestureDetector(
                    onTap: () {
                      isExpand = !isExpand;
                      setState(() {});
                    },
                    child: Icon(
                      isExpand
                          ? Icons.keyboard_arrow_down
                          : Icons.navigate_next_rounded,
                      color: const Color(0xFF8D8D95),
                    ),
                  ),
                if (!isGroup)
                  CheckboxCustom(
                    onChanged: !isGroup
                        ? (value) {
                            final newModel = widget.model.copyWith(
                                isDone: value, isVisible: value != null);

                            widget.onChanged(newModel);
                          }
                        : null,
                    disabled: widget.model.isVisible == false,
                    value: widget.model.isDone!,
                  ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.model.text,
                    style: TextStyle(
                        color: colorTheme.sidebarIconColor,
                        decoration: widget.model.tasks.isEmpty &&
                                widget.model.isDone == true
                            ? TextDecoration.lineThrough
                            : null),
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
                if (widget.model.notificationDate != null)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.schedule,
                      size: 12,
                      color: Colors.orange,
                    ),
                  ),
                if (isGroup)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${widget.model.tasks.where((element) => element.isDone!).length}/${widget.model.tasks.length}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                const SizedBox(
                  width: 6,
                ),
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
            ExpandedSection(
              expand: widget.isExpand ? false : isExpand,
              child: Column(
                children: widget.model.tasks.map((item) {
                  final i = widget.model.tasks.indexOf(item);
                  return _SubtaskItemWidget(
                    item,
                    onChange: (value) {
                      final newTask = item.copyWith(
                          isDone: value, isVisible: value != null);
                      final tasks = List.of(widget.model.tasks)..[i] = newTask;
                      final newModel = widget.model.copyWith(tasks: tasks);
                      widget.onChanged(newModel);
                      setState(() {});
                    },
                    onTap: () async {
                      final newModel = await showGroupEditor(widget.model);
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
                    onDelete: () {
                      deleteTask(item, i);
                    },
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  void deleteTask(TaskModel item, int index) {
    if (item.text!.isEmpty) {
      final tasks = List.of(widget.model.tasks)..removeAt(index);
      final newGroup = widget.model.copyWith(tasks: tasks);

      widget.onChanged(newGroup);
    } else {
      showDeleteTaskDialog(
          onTapOK: () {
            final tasks = List.of(widget.model.tasks)..removeAt(index);
            final newGroup = widget.model.copyWith(tasks: tasks);
            widget.onChanged(newGroup);
          },
          title: 'DELETE?');
    }
  }

  void copyToClipboard() {
    bool hasData = ClipboardUtils.copyGroupToClipboard(widget.model);
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
    this.onChange,
    required this.onDelete,
  }) : super(key: key);

  final TaskModel item;
  final void Function()? onTap;
  final void Function() onDelete;
  final void Function(bool? value)? onChange;

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.read<ModelTheme>().colorTheme;
    return Container(
      padding: const EdgeInsets.only(left: 30, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: CheckboxCustom(
              onChanged: onChange,
              disabled: item.isVisible == false,
              value: item.isDone,
            ),
          ),
          Flexible(
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
                child: Text(
              item.text!,
              style: TextStyle(
                  color: 
                       colorTheme.sidebarIconColor
                      ,
                  decoration: item.isDone! ? TextDecoration.lineThrough : null),
            )),
          )
        ],
      ),
    );
  }
}
