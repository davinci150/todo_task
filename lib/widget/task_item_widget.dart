import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_task/context_menu.dart';
import 'package:todo_task/model/group_model.dart';
import 'package:todo_task/notification_service.dart';
import 'package:todo_task/utils/clipboard_utils.dart';
import '../dialog/input_text_dialog.dart';
import '../model/task_model.dart';
import 'custom_check_box.dart';
import 'expandable_section.dart';

class TextItemWidget extends StatefulWidget {
  const TextItemWidget(
      {Key? key,
      required this.model,
      required this.index,
      required this.onChanged,
      required this.onTapDelete})
      : super(key: key);

  final int index;
  final GroupModel model;
  final void Function(GroupModel) onChanged;
  final VoidCallback onTapDelete;

  @override
  State<TextItemWidget> createState() => _TextItemWidgetState();
}

class _TextItemWidgetState extends State<TextItemWidget> {
  bool isExpand = true;
  //Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final listDone = widget.model.tasks!.map((e) => e.isDone!);

    bool isDoneGroup =
        listDone.isEmpty ? widget.model.isDone! : !listDone.contains(false);

    final bool isGroup = widget.model.tasks!.isNotEmpty;

    return Container(
      margin: EdgeInsets.fromLTRB(isGroup ? 16 : 20, 4, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
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
              GestureDetector(
                onSecondaryTapUp: (tapDetails) {
                  showContextMenu(
                      tapDetails: tapDetails,
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
                          copyToCliboard();
                        } else if (value == 'Delete') {
                          if ((widget.model.text ?? '').isEmpty) {
                            widget.onTapDelete();
                          } else {
                            showDeleteTaskDialog(
                                onTapOK: () {
                                  widget.onTapDelete();
                                },
                                title: 'DELETE?');
                          }
                        } else if (value == 'Add subtask') {
                          final text = await inpuTextDialog();
                          if (text != null) {
                            final tasks = List.of(widget.model.tasks!)
                              ..add(TaskModel(
                                  id: widget.model.tasks!.length,
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
                onTap: () async {
                  final text = await inpuTextDialog2(
                      widget.model.text!, widget.model.notificationDate);
                  if (text?.text != null) {
                    final newModel = widget.model.copyWith(
                        text: text!.text, notificationDate: text.date);
                    widget.onChanged(newModel);
                    if (text.date != null) {
                      NotificationService()
                          .scheduleNotification(2, text.date!, text.text);
                    }
                  }
                },
                child: Text(
                  widget.model.text!,
                  style: Theme.of(context).textTheme.bodyMedium,
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
                    '${widget.model.tasks!.where((element) => element.isDone!).length}/${widget.model.tasks!.length}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              const SizedBox(
                width: 6,
              ),
              if (isGroup)
                InkWell(
                    onTap: () async {
                      final text = await inpuTextDialog();
                      if (text != null) {
                        final tasks = List.of(widget.model.tasks!)
                          ..add(TaskModel(
                              id: widget.model.tasks!.length,
                              text: text,
                              isDone: false,
                              createdOn: DateTime.now(),
                              isVisible: true));
                        final newModel = widget.model.copyWith(tasks: tasks);
                        widget.onChanged(newModel);
                      }
                    },
                    child: const Icon(Icons.add, size: 16)),
            ],
          ),
          ExpandedSection(
            expand: isExpand,
            child: Column(
              children: widget.model.tasks!.map((item) {
                final i = widget.model.tasks!.indexOf(item);
                return _SubtasItemWidget(
                  item,
                  onChange: (value) {
                    final newTask =
                        item.copyWith(isDone: value, isVisible: value != null);
                    final tasks = List.of(widget.model.tasks!)..[i] = newTask;
                    final newModel = widget.model.copyWith(tasks: tasks);
                    widget.onChanged(newModel);
                    setState(() {});
                  },
                  onTap: () async {
                    final text = await inpuTextDialog(item.text!);
                    if (text != null) {
                      final newTask = item.copyWith(text: text);
                      final tasks = List.of(widget.model.tasks!)..[i] = newTask;
                      final newModel = widget.model.copyWith(tasks: tasks);
                      widget.onChanged(newModel);
                    }
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
    );
  }

  void deleteTask(TaskModel item, int index) {
    if (item.text!.isEmpty) {
      final tasks = List.of(widget.model.tasks!)..removeAt(index);
      final newGroup = widget.model.copyWith(tasks: tasks);

      widget.onChanged(newGroup);
    } else {
      showDeleteTaskDialog(
          onTapOK: () {
            final tasks = List.of(widget.model.tasks!)..removeAt(index);
            final newGroup = widget.model.copyWith(tasks: tasks);
            widget.onChanged(newGroup);
          },
          title: 'DELETE?');
    }
  }

  void copyToCliboard() {
    bool hasData = ClipboardUtils.copyGroupToClipboard(widget.model);
    if (hasData) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Group copied to buffer'),
        duration: Duration(milliseconds: 500),
      ));
    }
  }
}

class _SubtasItemWidget extends StatelessWidget {
  const _SubtasItemWidget(
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
    return Container(
      padding: const EdgeInsets.only(left: 30, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CheckboxCustom(
                onChanged: onChange,
                disabled: item.isVisible == false,
                value: item.isDone,
              ),
              const SizedBox(width: 6),
            ],
          ),
          GestureDetector(
            onSecondaryTapUp: (tapDetails) {
              showContextMenu(
                  tapDetails: tapDetails,
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
            onTap: onTap,
            child: Text(
              item.text!,
              style: TextStyle(
                  color: item.isDone! || item.isVisible == false
                      ? const Color(0xFF5F5e63)
                      : null,
                  decoration: item.isDone! ? TextDecoration.lineThrough : null),
            ),
          )
          //   TextFieldWidget(
          //       key: ValueKey(item.id),
          //       onChanged: (text) {
          //         onTextChange(() {
          //           final newTask = item.copyWith(text: text);
          //           final tasks = List.of(widget.model.tasks!)
          //             ..[i] = newTask;
          //           final newModel =
          //               widget.model.copyWith(tasks: tasks);
          //           widget.onChanged(newModel);
          //         });
          //       },
          //       decoration:
          //           item.isDone! ? TextDecoration.lineThrough : null,
          //       initialValue: item.text,
          //       textColor: item.isDone! || item.isVisible == false
          //           ? const Color(0xFF5F5e63)
          //           : null),
          //   InkWell(
          //     onTap: () => deleteTask(item, i),
          //     child: Icon(
          //       Icons.close,
          //       color: Colors.red.withOpacity(0.4),
          //       size: 12,
          //     ),
          //   ),
        ],
      ),
    );
  }
}
