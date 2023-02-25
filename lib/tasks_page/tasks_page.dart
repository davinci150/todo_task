import 'package:flutter/material.dart';

import '../main.dart';
import '../model/group_model.dart';
import '../tasks_widget_model.dart';
import '../widget/task_item_widget.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late TasksWidgetModel _model;

  @override
  void initState() {
    _model = TasksWidgetModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TaskWidgetModelProvider(
      model: _model,
      child: const _TasksPageWidgetBody(),
    );
  }
}

class _TasksPageWidgetBody extends StatelessWidget {
  const _TasksPageWidgetBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _model = TaskWidgetModelProvider.watch(context)?.model;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).drawerTheme.backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
              child: Text(
                _model?.selectedFolderStr ?? 'TODO TASK',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          if (_model?.selectedFolderStr != null)
            Expanded(
              child: ReorderableListView.builder(
                // scrollController: scrollController,
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 80),
                itemCount: _model?.groups.length ?? 0,
                itemBuilder: (ctx, index) {
                  final GroupModel item = _model!.groups[index];
                  return TextItemWidget(
                      index: index,
                      key: ValueKey(item.createdOn),
                      model: item,
                      onChanged: (newModel) {
                        _model.onChangeGroupModel(newModel, index);
                      },
                      onTapDelete: () {
                        _model.deleteTask(item);
                      });
                },
                onReorder: (int oldIndex, int newIndex) {
                  _model!.onReorder(oldIndex, newIndex);
                },
              ),
            ),
        ],
      ),
    );
  }
}
