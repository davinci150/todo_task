import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:todo_task/model/user_model.dart';
import 'package:todo_task/sidebar.dart';
import 'package:todo_task/tasks_widget_model.dart';
import 'model/group_model.dart';
import 'widget/task_item_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const taskKey = kDebugMode ? 'testKeyV1' : 'taskKeyV2';
const selectedGroupKey = kDebugMode ? 'selectedGroupV1' : 'selectedGroupV1';

const String uid = 'mKSkbFBTiteCnZQjVi2QzaZFF0e2';

class _MyHomePageState extends State<MyHomePage> {
  UserModel? userModel;
  late ScrollController scrollController;

  void deleteAll() {
    //authDao.deleteUser();
    //userModel = null;
    //tasksDao.removeAll();
    // list.clear();
    // selectedFolder = null;
    setState(() {});
  }

  Future scrollToBottom(ScrollController scrollController) async {
    await scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.easeInOut);

    while (scrollController.position.pixels !=
        scrollController.position.maxScrollExtent) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      await SchedulerBinding.instance.endOfFrame;
    }
  }

  @override
  void initState() {
    scrollController = ScrollController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _model = TaskWidgetModelProvider.watch(context)?.model;

    // return Consumer<ModelTheme>(
    //     builder: (context, ModelTheme themeNotifier, child) {
    log('BUIDL');
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  const SideBar(),
                  //   if (_model?.selectedFolder != null)
                  StreamBuilder<List<GroupModel>?>(
                      stream: _model?.groupsStream(_model.selectedFolderStr),
                      builder: (context, snapshot) {
                        if (snapshot.data == null) return const Text('not');
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 10, 10),
                                child: Text(
                                  _model!.selectedFolder?.title ?? 'TODO TASK',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              if (_model.selectedFolderStr != null)
                                //  MyWidget(
                                //    folderName: _model.selectedFolderStr!,
                                //    key: ValueKey(_model.selectedFolderStr!),
                                //  ),
                                //Divider(),
                                Expanded(
                                  child: ReorderableListView.builder(
                                    scrollController: scrollController,
                                    buildDefaultDragHandles: false,
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 80),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (ctx, index) {
                                      final GroupModel item =
                                          snapshot.data![index];
                                      return TextItemWidget(
                                          index: index,
                                          key: ValueKey(item.createdOn),
                                          model: item,
                                          onChanged: (newModel) {
                                            _model.onChangeGroupModel(
                                                newModel, index);
                                          },
                                          onTapDelete: () {
                                            if ((item.text ?? '').isEmpty) {
                                              _model.deleteTask(item);
                                            } else {
                                              showDeleteTaskDialog(item);
                                            }
                                          });
                                    },
                                    onReorder: (int oldIndex, int newIndex) {
                                      _model.onReorder(oldIndex, newIndex);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            )
          ],
        ),
        floatingActionButton: _model?.selectedFolder == null
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: () => _model?.copyToCliboard(),
                    tooltip: 'Copy to clipboard',
                    child: const Icon(Icons.copy_all_outlined),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  FloatingActionButton(
                    onPressed: () => _model?.addTask(),
                    tooltip: 'Add new task',
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
      ),
    );
    //  });
  }

  void showDeleteTaskDialog(GroupModel model) {
    showDialog(
        context: context,
        builder: (ctx) {
          final _model = TaskWidgetModelProvider.read(context)?.model;
          return Focus(
            autofocus: true,
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                _model?.deleteTask(model);

                Navigator.pop(context);
              }
              return KeyEventResult.ignored;
            },
            child: AlertDialog(
              title: const Text('DELETE?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      _model?.deleteTask(model);
                      Navigator.pop(context);
                    },
                    child: const Text('OK')),
              ],
            ),
          );
        });
  }
}
