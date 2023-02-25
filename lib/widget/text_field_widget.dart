import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
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
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.initialValue ?? '';
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TextFieldWidget oldWidget) {
    if (controller.text != widget.initialValue) {
      controller.text = widget.initialValue ?? '';
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        style: TextStyle(
            decorationThickness: 2,
            decoration: widget.decoration,
            color: widget.textColor),
        maxLines: null,
        onChanged: widget.onChanged,
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
