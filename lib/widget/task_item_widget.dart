import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_task/model/group_model.dart';
import '../model/task_model.dart';

class TextItemWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: model.tasks!.isEmpty ? null : const EdgeInsets.all(8),
      margin: model.tasks!.isEmpty
          ? const EdgeInsets.fromLTRB(20, 4, 20, 4)
          : const EdgeInsets.fromLTRB(12, 4, 12, 4),
      decoration: model.tasks!.isNotEmpty
          ? BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10))
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
                    size: 16,
                  ),
                ),
              ),
              CheckboxCustom(
                onChanged: (value) {
                  final newModel =
                      model.copyWith(isDone: value, isVisible: value != null);

                  onChanged(newModel);
                },
                disabled: model.isVisible == false,
                value: model.isDone,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextFormField(
                  maxLines: null,
                  initialValue: model.text,
                  onChanged: (text) {
                    final newModel = model.copyWith(text: text);
                    onChanged(newModel);
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
              InkWell(
                  onTap: () {
                    if (model.tasks!.isEmpty) {
                      final tasks = List.of(model.tasks!)
                        ..add(TaskModel(
                            id: 0,
                            text: model.text,
                            isDone: model.isDone,
                            createdOn: model.createdOn,
                            isVisible: model.isVisible));

                      final newModel =
                          model.copyWith(tasks: tasks, text: '', isDone: false);
                      onChanged(newModel);
                    }
                    //
                    else {
                      final tasks = List.of(model.tasks!)
                        ..add(TaskModel(
                            id: model.tasks!.length,
                            text: '',
                            isDone: false,
                            createdOn: DateTime.now(),
                            isVisible: true));
                      final newModel = model.copyWith(tasks: tasks);
                      onChanged(newModel);
                    }
                  },
                  child: Icon(
                    model.tasks!.isEmpty ? Icons.copy_all : Icons.add,
                    size: 16,
                  )),
              InkWell(
                onTap: onTapDelete,
                child: Icon(
                  Icons.close,
                  color: Colors.red.withOpacity(0.4),
                  size: 12,
                ),
              ),
            ],
          ),
          Column(
            children: model.tasks!.map((item) {
              final i = model.tasks!.indexOf(item);
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
                            final tasks = List.of(model.tasks!)..[i] = newTask;
                            final newModel = model.copyWith(tasks: tasks);
                            onChanged(newModel);
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
                          final tasks = List.of(model.tasks!)..[i] = newTask;
                          final newModel = model.copyWith(tasks: tasks);
                          onChanged(newModel);
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter the text',
                          hintStyle:
                              TextStyle(color: Colors.grey.withOpacity(0.5)),
                          contentPadding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        final tasks = List.of(model.tasks!)..removeAt(i);
                        final newGroup = model.copyWith(tasks: tasks);

                        onChanged(newGroup);
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
          )
        ],
      ),
    );
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
