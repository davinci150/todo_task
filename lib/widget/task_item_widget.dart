import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:todo_task/model/group_model.dart';
import '../model/task_model.dart';
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
  @override
  Widget build(BuildContext context) {
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
                    color:
                        Theme.of(context).iconTheme.color?.withOpacity(0.3),
                    size: 16,
                  ),
                ),
              ),
              CheckboxCustom(
                onChanged: (value) {
                  final newModel = widget.model
                      .copyWith(isDone: value, isVisible: value != null);

                  widget.onChanged(newModel);
                },
                disabled: widget.model.isVisible == false,
                value: widget.model.isDone,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextFormField(
                  maxLines: null,
                  initialValue: widget.model.text,
                  onChanged: (text) {
                    final newModel = widget.model.copyWith(text: text);
                    widget.onChanged(newModel);
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter the text',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                    contentPadding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
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
                            },
                            disabled: item.isVisible == false,
                            value: item.isDone,
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                      Expanded(
                        child: TextFormField(
                          key: ValueKey(item.id),
                          maxLines: null,
                          initialValue: item.text,
                          onChanged: (text) {
                            final newTask = item.copyWith(text: text);
                            final tasks = List.of(widget.model.tasks!)
                              ..[i] = newTask;
                            final newModel =
                                widget.model.copyWith(tasks: tasks);
                            widget.onChanged(newModel);
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter the text',
                            hintStyle: TextStyle(
                                color: Colors.grey.withOpacity(0.5)),
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 2, 0, 0),
                            isDense: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (item.text!.isEmpty) {
                            final tasks = List.of(widget.model.tasks!)
                              ..removeAt(i);
                            final newGroup =
                                widget.model.copyWith(tasks: tasks);

                            widget.onChanged(newGroup);
                          } else {
                            showDeleteMsgDialog(item, i);
                          }
                        },
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

  void showDeleteMsgDialog(TaskModel model, int index) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('DELETE?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    final tasks = List.of(widget.model.tasks!)..removeAt(index);
                    final newGroup = widget.model.copyWith(tasks: tasks);

                    widget.onChanged(newGroup);

                    Navigator.pop(context);
                  },
                  child: const Text('OK')),
            ],
          );
        });
  }

  void copyToCliboard() {
    String res = '';

    res = res + widget.model.text! + '\n';
    if (widget.model.tasks!.isNotEmpty) {
      final listTasks = widget.model.tasks!
          .where((element) => element.isVisible == true)
          .toList();
      if (listTasks.isNotEmpty) {
        for (var task in listTasks) {
          res = res + (task.isDone! ? '✓ ' : '☐ ') + task.text! + '\n';
        }
      }
    }
    log(res);
    if (res.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: res));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('All tasks copied to buffer'),
        duration: Duration(milliseconds: 500),
      ));
    }
  }
}

//  void onTextChange(VoidCallback function) {
//    _debounce?.cancel();
//    _debounce = Timer(const Duration(milliseconds: 400), () {
//      _bloc.add(AttachmentDialogSearchEvent(text));
//    });
//  }
class CheckboxCustom extends StatefulWidget {
  const CheckboxCustom({
    Key? key,
    required this.value,
    required this.disabled,
    required this.onChanged,
  }) : super(key: key);

  final bool? disabled;
  final bool? value;
  final void Function(bool?) onChanged;

  @override
  State<CheckboxCustom> createState() => _CheckboxCustomState();
}

class _CheckboxCustomState extends State<CheckboxCustom> {
  bool? curValue;
  late IconData icon;

  @override
  void initState() {
    curValue = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disabled == true) {
      icon = Icons.visibility_off;
    } else {
      if (curValue == true) {
        icon = Icons.check_circle;
      } else {
        icon = Icons.radio_button_unchecked_outlined;
      }
    }
    return GestureDetector(
      onLongPress: () {
        widget.onChanged(null);
        setState(() {});
      },
      onTap: () {
        if (widget.disabled == false) {
          curValue = !curValue!;
        }

        widget.onChanged(curValue);
        setState(() {});
      },
      child: Icon(icon,
          size: 16, color: widget.disabled == false ? null : Colors.grey),
    );
  }
}
