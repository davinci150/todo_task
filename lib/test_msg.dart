import 'package:flutter/material.dart';
import 'package:todo_task/model/group_model.dart';
import 'package:todo_task/tasks_repository.dart';

import 'widget/task_item_widget.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key, required this.folderName}) : super(key: key);

  final String folderName;

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.folderName.isEmpty) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<List<GroupModel>?>(
      stream: TasksRepository.instance.groupsStream(widget.folderName),
      builder: (context, snapshot) {
        if (snapshot.data == null) return const SizedBox();

        return Column(children: [
          ...snapshot.data!.map((e) {
            final index = snapshot.data!.indexOf(e);

            return TextItemWidget(
                model: e, index: index, onChanged: (gr) {}, onTapDelete: () {});
          }).toList(),
        ]);
      },
    );
  }
}
