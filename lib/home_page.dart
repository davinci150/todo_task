import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/group_model.dart';
import 'model/task_model.dart';
import 'widget/task_item_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const taskKey = 'taskKeyV1';

class _MyHomePageState extends State<MyHomePage> {
  List<GroupModel> list = [];
  GroupModel? selectedGroup;
  SharedPreferences? prefs;

  late ScrollController scrollController;

  void _addTask() {
    final model = TaskModel(
        text: '', isDone: false, createdOn: DateTime.now(), isVisible: true);
    selectedGroup!.tasks!.add(model);
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFEFEFEF),
        drawer: Drawer(
            backgroundColor: const Color(0xFFEFEFEF),
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
                      const Icon(
                        Icons.account_circle_outlined,
                        size: 50,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'name',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'email@test.com',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    ],
                  ),
                  Divider(
                    thickness: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                  Column(
                    children: list.map((e) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              selectedGroup = e;
                              setState(() {});
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.only(left: 6),
                              decoration: selectedGroup != e
                                  ? null
                                  : BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    e.text!,
                                    style: TextStyle(
                                        color: selectedGroup == e
                                            ? Colors.blueGrey
                                            : Colors.grey),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        showDeleteGroupDialog(e);
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red.withOpacity(0.6),
                                      ))
                                ],
                              ),
                            ),
                          );
                        }).toList() +
                        [
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              showAddGroupDialog();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 6, bottom: 6),
                              padding: const EdgeInsets.fromLTRB(6, 0, 8, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Add new group'),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(6)),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                  ),
                ],
              ),
            )),
        appBar: AppBar(
          title: Text(selectedGroup?.text ?? 'TODO TASK'),
        ),
        body: selectedGroup == null
            ? const SizedBox()
            : ReorderableListView.builder(
                scrollController: scrollController,
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
                itemCount: selectedGroup!.tasks!.length,
                itemBuilder: (ctx, index) {
                  return TextItemWidget(
                      index: index,
                      key: ValueKey(selectedGroup!.tasks![index]),
                      model: selectedGroup!.tasks![index],
                      onTapEnter: _addTask,
                      onChanged: (value) {
                        final model = selectedGroup!.tasks![index];
                        selectedGroup!.tasks![index] = model.copyWith(
                            isDone: value, isVisible: value != null);
                        setState(() {});
                        saveTasks();
                      },
                      onTextChange: (text) {
                        final model = selectedGroup!.tasks![index];
                        selectedGroup!.tasks![index] =
                            model.copyWith(text: text);
                        saveTasks();
                      },
                      onTapDelete: () {
                        if ((selectedGroup!.tasks![index].text ?? '')
                            .trim()
                            .isEmpty) {
                          selectedGroup!.tasks!.removeAt(index);
                          setState(() {});
                          saveTasks();
                        } else {
                          showDeleteMsgDialog(index);
                        }
                      }
                      //),
                      );
                },
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = selectedGroup!.tasks!.removeAt(oldIndex);
                    selectedGroup!.tasks!.insert(newIndex, item);
                  });
                  saveTasks();
                },
              ),
        floatingActionButton: selectedGroup == null
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
  }

  void initTask() {
    List<GroupModel> result = [];
    final jsonStr = prefs?.getString(taskKey);
    if ((jsonStr ?? '').isNotEmpty) {
      final map = jsonDecode(jsonStr!) as List<dynamic>;
      for (var value in map) {
        result.add(GroupModel.fromJson(value as Map<String, dynamic>));
      }
    }
    if ((result).isNotEmpty) {
      selectedGroup = result.first;
    }
    list = result;
    setState(() {});
  }

  void saveTasks() {
    final saveJson = list.map((e) => e.toJson()).toList();
    final result = jsonEncode(saveJson);
    prefs?.setString(taskKey, result);
  }

  void copyToCliboard() {
    String res = '';
    selectedGroup!.tasks!
        .where((element) => element.isVisible == true)
        .toList()
        .asMap()
        .forEach((key, value) {
      res = res +
          '${key + 1})' +
          (value.isDone! ? ' ✓ ' : ' ☐ ') +
          value.text! +
          '\n';
    });

    Clipboard.setData(ClipboardData(text: res));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('All tasks copied to buffer'),
      duration: Duration(milliseconds: 500),
    ));
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
                    selectedGroup!.tasks!.removeAt(index);
                    setState(() {});
                    saveTasks();

                    Navigator.pop(context);
                  },
                  child: const Text('OK')),
            ],
          );
        });
  }

  void showDeleteGroupDialog(GroupModel model) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('DELETE "${model.text ?? ''}" ?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    list.remove(model);
                    selectedGroup = null;
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
                  onPressed: () {
                    final groupModel = GroupModel(text: title, tasks: []);
                    list.add(groupModel);
                    selectedGroup = groupModel;
                    setState(() {});
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK')),
            ],
          );
        });
  }
}
