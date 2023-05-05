import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

class InputTextDialog extends StatefulWidget {
  const InputTextDialog({Key? key, this.initialText}) : super(key: key);
  final String? initialText;
  @override
  State<InputTextDialog> createState() => _InputTextDialogState();
}

class _InputTextDialogState extends State<InputTextDialog> {
  late TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController()
      ..text = widget.initialText ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.read<ModelTheme>().colorTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorTheme.mobileScaffoldColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 16,
            ),
            Text(
              'Input text',
              style: TextStyle(color: colorTheme.sidebarIconColor),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: colorTheme.sidebarIconColor))),
              style: TextStyle(color: colorTheme.sidebarIconColor),
              onEditingComplete: () {
                Navigator.pop(context, textEditingController.text);
              },
              autofocus: true,
              controller: textEditingController,
            ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {
                    Navigator.pop(context, textEditingController.text);
                  },
                  child: const Text('OK')),
            ),
          ],
        ),
      ),
    );
  }
}
