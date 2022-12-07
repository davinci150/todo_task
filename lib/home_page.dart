import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'model/folder_model.dart';
import 'model/group_model.dart';
import 'model/task_model.dart';
import 'widget/task_item_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const taskKey = kDebugMode ? 'testKeyV1' : 'taskKeyV1';

class _MyHomePageState extends State<MyHomePage> {
  List<FolderModel> list = [];
  FolderModel? selectedFolder;
  SharedPreferences? prefs;

  late ScrollController scrollController;
  void deleteAll() {
    prefs!.remove(taskKey);
    list.clear();
    selectedFolder = null;
    setState(() {});
  }

  void _addTask() {
    //final taskModel = TaskModel(
    //    text: '', isDone: false, createdOn: DateTime.now(), isVisible: true);
    final group = GroupModel(
        text: '',
        tasks: [],
        createdOn: DateTime.now(),
        isDone: false,
        isVisible: true);
    selectedFolder!.tasks!.add(group);
    saveTasks();
    setState(() {});
    scrollToBottom(scrollController);
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

    SharedPreferences.getInstance().then((value) {
      prefs = value;
      initTask();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          drawer: Drawer(
              //backgroundColor: const Color(0xFFEFEFEF),
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FlutterLogo(),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'name',
                          //style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'email@test.com',
                          // style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
                Divider(
                  thickness: 2,
                  color: Theme.of(context).primaryColor,
                ),
                Column(children: <Widget>[
                  ...list.map(groupItemWidget).toList(),
                  ...[addNewGroupDrawerButton()]
                ]),
              ],
            ),
          )),
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    themeNotifier.isDark
                        ? themeNotifier.isDark = false
                        : themeNotifier.isDark = true;
                  },
                  icon: Icon(themeNotifier.isDark
                      ? Icons.nightlight_round
                      : Icons.wb_sunny)),
              if (kDebugMode)
                IconButton(onPressed: deleteAll, icon: Icon(Icons.remove))
            ],
            title: Text(selectedFolder?.title ?? 'TODO TASK'),
          ),
          body: selectedFolder == null
              ? const SizedBox()
              : ReorderableListView.builder(
                  scrollController: scrollController,
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 80),
                  itemCount: selectedFolder!
                      .tasks!.length, // selectedGroup!.tasks!.length,
                  itemBuilder: (ctx, index) {
                    final item = selectedFolder!.tasks![index];
                    return TextItemWidget(
                        index: index,
                        key: ValueKey(item),
                        model: item,
                        //onTapEnter: _addTask,
                        onChanged: (newModel) {
                          selectedFolder!.tasks![index].text = newModel.text;
                          selectedFolder!.tasks![index].tasks = newModel.tasks;
                          selectedFolder!.tasks![index].isDone =
                              newModel.isDone;
                          selectedFolder!.tasks![index].isVisible =
                              newModel.isVisible;

                          // item.tasks![i] =
                          //     model.copyWith(
                          //         isDone: value, isVisible: value != null);
                          setState(() {});
                          saveTasks();
                        },
                        //  onTextChange: (text, i) {
                        //    final model = item.tasks![i];
                        //    item.tasks![i] =
                        //        model.copyWith(text: text);
                        //    saveTasks();
                        //  },
                        onTapDelete: () {
                          selectedFolder!.tasks!.remove(item);
                          setState(() {});
                          saveTasks();

                          // if ((item.tasks![i].title ?? '')
                          //     .trim()
                          //     .isEmpty) {
                          //   list.removeAt(index);
                          //   setState(() {});
                          //   saveTasks();
                          // } else {
                          //   showDeleteMsgDialog(index);
                          // }
                        }
                        //),
                        );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = selectedFolder!.tasks![oldIndex];
                      selectedFolder!.tasks!.removeAt(oldIndex);
                      selectedFolder!.tasks!.insert(newIndex, item);
                    });
                    saveTasks();
                  },
                ),
          floatingActionButton: selectedFolder == null
              ? null
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: () => copyToCliboard(),
                      tooltip: 'Copy to clipboard',
                      child: const Icon(Icons.copy_all_outlined),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    FloatingActionButton(
                      onPressed: _addTask,
                      tooltip: 'Add new task',
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  Widget groupItemWidget(FolderModel folderModel) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        selectedFolder = folderModel;
        setState(() {});
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 6),
        decoration: selectedFolder != folderModel
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).primaryColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(folderModel.title!),
            IconButton(
                onPressed: () {
                  showDeleteGroupDialog(folderModel);
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.red.withOpacity(0.6),
                ))
          ],
        ),
      ),
    );
  }

  Widget addNewGroupDrawerButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        showAddGroupDialog();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.fromLTRB(6, 0, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Add new group'),
            Container(
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(6)),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initTask() {
    List<FolderModel> result = [];
    final jsonStr = prefs?.getString(taskKey);
    if ((jsonStr ?? '').isNotEmpty) {
      final map = jsonDecode(jsonStr!) as List<dynamic>;
      for (var value in map) {
        result.add(FolderModel.fromJson(value as Map<String, dynamic>));
      }
    }
    if ((result).isNotEmpty) {
      selectedFolder = result.first;
    }
    list = result;
    setState(() {});
  }

  void saveTasks() {
    final saveJson = list.map((e) => e.toJson()).toList();
    final result = jsonEncode(saveJson);
    log(list.toString());
    prefs?.setString(taskKey, result);
  }

  void copyToCliboard() {
    String res = '';
    selectedFolder!.tasks!
        .where((element) => element.isVisible == true)
        .toList()
        .asMap()
        .forEach((key, value) {
      res = res +
          '${key + 1})' +
          (value.isDone! ? ' ✓ ' : ' ☐ ') +
          value.text! +
          '\n';
      if (value.tasks!.isNotEmpty) {
        final listTasks =
            value.tasks!.where((element) => element.isVisible == true).toList();
        if (listTasks.isNotEmpty) {
          for (var task in listTasks) {
            res = res +
                (task.isDone! ? '     ✓ ' : '     ☐ ') +
                task.text! +
                '\n';
          }
        }
      }
    });
    log(res);
    if (res.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: res));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('All tasks copied to buffer'),
        duration: Duration(milliseconds: 500),
      ));
    }
  }

  void showDeleteMsgDialog(int index) {
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
                    selectedFolder!.tasks!.removeAt(index);
                    setState(() {});
                    saveTasks();

                    Navigator.pop(context);
                  },
                  child: const Text('OK')),
            ],
          );
        });
  }

  void showDeleteGroupDialog(FolderModel model) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('DELETE "${model.title ?? ''}" ?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    list.remove(model);
                    selectedFolder = null;
                    setState(() {});
                    saveTasks();

                    Navigator.pop(context);
                  },
                  child: const Text('OK')),
            ],
          );
        });
  }

  void showAddGroupDialog() {
    String title = '';
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Input title'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onEditingComplete: () => addGroup(title),
                autofocus: true,
                onChanged: (text) {
                  title = text;
                },
                decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red))),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => addGroup(title), child: const Text('OK')),
            ],
          );
        });
  }

  void addGroup(String title) {
    final folderModel = FolderModel(title: title, tasks: []);
    list.add(folderModel);
    selectedFolder = folderModel;
    saveTasks();
    setState(() {});
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
