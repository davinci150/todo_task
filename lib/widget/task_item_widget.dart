import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/task_model.dart';

class TextItemWidget extends StatelessWidget {
  const TextItemWidget(
      {Key? key,
      required this.model,
      required this.index,
      required this.onChanged,
      required this.onTapEnter,
      required this.onTextChange,
      required this.onTapDelete})
      : super(key: key);

  final int index;
  final TaskModel model;
  final void Function(bool?) onChanged;
  final void Function(String)? onTextChange;
  final VoidCallback onTapDelete;
  final VoidCallback onTapEnter;

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //     border:
      //         Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5)))),
      margin: EdgeInsets.only(bottom: 10),
      //padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_handle,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
                  size: 16,
                ),
              ),
              const SizedBox(width: 6),
              CheckboxCustom(
                onChanged: onChanged,
                disabled: model.isVisible == false,
                value: model.isDone,
              ),
              const SizedBox(width: 6),
            ],
          ),
          Expanded(
            child: TextFormField(
              maxLines: null,
              initialValue: model.text,
              onChanged: onTextChange,
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
            onTap: onTapDelete,
            child: Icon(
              Icons.close,
              color: Colors.red.withOpacity(0.4),
              size: 12,
            ),
          ),
        ],
      ),
    );
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 6),
          // padding: const EdgeInsets.symmetric(horizontal: 8),
          // decoration: BoxDecoration(
          //     color: Color(0xFF282b38), borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(
                    Icons.drag_handle,
                    color: Colors.black38,
                  ),
                ),
                Expanded(
                    child: TextFormField(
                  keyboardType: TextInputType.text,
                  //autofocus: true,
                  onEditingComplete: onTapEnter,
                  onChanged: onTextChange,
                  maxLines: null,
                  initialValue: model.text,

                  style: TextStyle(
                      color: model.isVisible == true ? null : Colors.grey,
                      fontSize: 14),
                  decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: CheckboxCustom(
                          onChanged: onChanged,
                          disabled: model.isVisible == false,
                          value: model.isDone,
                        ),
                      ),
                      //isDense: false,
                      //contentPadding: EdgeInsets.zero,
                      suffixIcon: InkWell(
                        onTap: onTapDelete,
                        child: Icon(
                          Icons.close,
                          color: Colors.red[300],
                        ),
                      ),
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      hintText: 'Enter text',
                      border: InputBorder.none),
                )),
                //Text(model.text),
              ],
            ),
          ),
        ),
        if (model.createdOn != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 20),
            child: Text(
              DateFormat('dd MMM, hh:mm').format(model.createdOn!),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}

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
