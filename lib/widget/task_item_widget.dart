import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_task/model/group_model.dart';
import 'package:todo_task/utils/clipboard_utils.dart';
import 'package:todo_task/widget/text_field_widget.dart';
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
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final listDone = widget.model.tasks!.map((e) => e.isDone!);
    bool isDoneGroup =
        listDone.isEmpty ? widget.model.isDone! : !listDone.contains(false);

    return Container(
      padding: widget.model.tasks!.isEmpty ? null : const EdgeInsets.all(8),
      margin: widget.model.tasks!.isEmpty
          ? const EdgeInsets.fromLTRB(20, 4, 20, 4)
          : const EdgeInsets.fromLTRB(12, 4, 12, 4),
      decoration: widget.model.tasks!.isNotEmpty
          ? BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ReorderableDragStartListener(
                  index: widget.index,
                  child: Icon(
                    Icons.drag_handle,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
                    size: 16,
                  ),
                ),
              ),
              CheckboxCustom(
                onChanged: widget.model.tasks!.isEmpty
                    ? (value) {
                        final newModel = widget.model
                            .copyWith(isDone: value, isVisible: value != null);

                        widget.onChanged(newModel);
                      }
                    : null,
                disabled: widget.model.isVisible == false,
                value: isDoneGroup,
              ),
              const SizedBox(width: 6),
              TextFieldWidget(
               // key: ValueKey(widget.model.text),
                initialValue: widget.model.text,
                decoration: isDoneGroup ? TextDecoration.lineThrough : null,
                onChanged: (text) {
                  onTextChange(() {
                    final newModel = widget.model.copyWith(text: text);
                    widget.onChanged(newModel);
                  });
                },
                textColor: widget.model.isDone! ||
                        isDoneGroup ||
                        widget.model.isVisible == false
                    ? const Color(0xFF5F5e63)
                    : null,
              ),
              if (widget.model.tasks!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InkWell(
                    onTap: copyToCliboard,
                    child: const Icon(
                      Icons.copy,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
              if (widget.model.tasks!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InkWell(
                    onTap: () {
                      isExpand = !isExpand;
                      setState(() {});
                    },
                    child: Icon(
                      isExpand
                          ? Icons.expand_less_outlined
                          : Icons.keyboard_arrow_down_outlined,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              InkWell(
                  onTap: () {
                    if (widget.model.tasks!.isEmpty) {
                      final tasks = List.of(widget.model.tasks!)
                        ..add(TaskModel(
                            id: 0,
                            text: widget.model.text,
                            isDone: widget.model.isDone,
                            createdOn: widget.model.createdOn,
                            isVisible: widget.model.isVisible));

                      final newModel = widget.model
                          .copyWith(tasks: tasks, text: '', isDone: false);
                      widget.onChanged(newModel);
                    }
                    //
                    else {
                      final tasks = List.of(widget.model.tasks!)
                        ..add(TaskModel(
                            id: widget.model.tasks!.length,
                            text: '',
                            isDone: false,
                            createdOn: DateTime.now(),
                            isVisible: true));
                      final newModel = widget.model.copyWith(tasks: tasks);
                      widget.onChanged(newModel);
                    }
                  },
                  child: Icon(
                    widget.model.tasks!.isEmpty ? Icons.copy_all : Icons.add,
                    size: 16,
                  )),
              const SizedBox(width: 6),
              InkWell(
                onTap: widget.onTapDelete,
                child: Icon(
                  Icons.close,
                  color: Colors.red.withOpacity(0.4),
                  size: 12,
                ),
              ),
            ],
          ),
          ExpandedSection(
            expand: isExpand,
            child: Column(
              children: widget.model.tasks!.map((item) {
                final i = widget.model.tasks!.indexOf(item);
                return Container(
                  padding: const EdgeInsets.only(left: 42, top: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CheckboxCustom(
                            onChanged: (value) {
                              final newTask = item.copyWith(
                                  isDone: value, isVisible: value != null);
                              final tasks = List.of(widget.model.tasks!)
                                ..[i] = newTask;
                              final newModel =
                                  widget.model.copyWith(tasks: tasks);
                              widget.onChanged(newModel);
                              setState(() {});
                            },
                            disabled: item.isVisible == false,
                            value: item.isDone,
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                      TextFieldWidget(
                          key: ValueKey(item.id),
                          onChanged: (text) {
                            onTextChange(() {
                              final newTask = item.copyWith(text: text);
                              final tasks = List.of(widget.model.tasks!)
                                ..[i] = newTask;
                              final newModel =
                                  widget.model.copyWith(tasks: tasks);
                              widget.onChanged(newModel);
                            });
                          },
                          decoration:
                              item.isDone! ? TextDecoration.lineThrough : null,
                          initialValue: item.text,
                          textColor: item.isDone! || item.isVisible == false
                              ? const Color(0xFF5F5e63)
                              : null),
                      InkWell(
                        onTap: () => deleteTask(item, i),
                        child: Icon(
                          Icons.close,
                          color: Colors.red.withOpacity(0.4),
                          size: 12,
                        ),
                      ),
                    ],
                  ),
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
      showDeleteMsgDialog(item, index);
    }
  }

  void showDeleteMsgDialog(TaskModel model, int index) {
    showDialog(
        context: context,
        builder: (ctx) {
          return Focus(
            autofocus: true,
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                final tasks = List.of(widget.model.tasks!)..removeAt(index);
                final newGroup = widget.model.copyWith(tasks: tasks);

                widget.onChanged(newGroup);

                Navigator.pop(context);
              }
              return KeyEventResult.ignored;
            },
            child: AlertDialog(
              title: const Text('DELETE?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      final tasks = List.of(widget.model.tasks!)
                        ..removeAt(index);
                      final newGroup = widget.model.copyWith(tasks: tasks);

                      widget.onChanged(newGroup);

                      Navigator.pop(context);
                    },
                    child: const Text('OK')),
              ],
            ),
          );
        });
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

  void onTextChange(VoidCallback function) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      function();
    });
  }
}
