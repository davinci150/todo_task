import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    Key? key,
    required this.onChanged,
    required this.decoration,
    required this.initialValue,
    required this.textColor,
  }) : super(key: key);

  final void Function(String)? onChanged;
  final TextDecoration? decoration;
  final String? initialValue;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        style: TextStyle(
            decorationThickness: 2, decoration: decoration, color: textColor),
        maxLines: null,
        initialValue: initialValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Enter the text',
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          contentPadding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
          isDense: true,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
