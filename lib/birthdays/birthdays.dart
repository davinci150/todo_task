import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_task/birthdays_widget_model.dart';
import 'package:todo_task/dialog/input_text_dialog.dart';

import '../model/birthday_model.dart';

class BirthdaysPage extends StatefulWidget {
  const BirthdaysPage({Key? key}) : super(key: key);

  @override
  State<BirthdaysPage> createState() => _BirthdaysPageState();
}

class _BirthdaysPageState extends State<BirthdaysPage> {
  @override
  Widget build(BuildContext context) {
    final _model = BirthdaysWidgetModel();
    return BirthdaysModelProvider(
      model: _model,
      child: const BdPage(),
    );
  }
}

class BdPage extends StatefulWidget {
  const BdPage({Key? key}) : super(key: key);

  @override
  State<BdPage> createState() => _BdPageState();
}

class _BdPageState extends State<BdPage> {
  @override
  Widget build(BuildContext context) {
    final _model = BirthdaysModelProvider.watch(context)?.model;
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).drawerTheme.backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
              onPressed: () async {
                final createModel = await inpuTextDialog2();
                if (createModel != null) {
                  _model?.addBirthday(createModel);
                }
              },
              child: Text('Add birthday')),
          ..._model!.birthdays
              .map((BirthdayModel e) => Row(
                    children: [
                      Text(e.name),
                      SizedBox(
                        width: 12,
                      ),
                      Text(DateFormat('dd MMM yyyy').format(e.birthday)),
                    ],
                  ))
              .toList(),
        ],
      ),
    );
  }
}
