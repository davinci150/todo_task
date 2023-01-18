import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/dao/tasks_dao.dart';
import 'package:todo_task/model/user_model.dart';
import 'package:todo_task/test_msg.dart';
import 'package:todo_task/utils/clipboard_utils.dart';
import 'api/auth_api.dart';
import 'dao/auth_dao.dart';
import 'firestore_repository.dart';
import 'main.dart';
import 'model/folder_model.dart';
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
  List<FolderModel> list = [];
  FolderModel? selectedFolder;
  late TasksDao tasksDao;
  late AuthDao authDao;
  UserModel? userModel;
  late ScrollController scrollController;
  String? selectedFolderStr;

  void deleteAll() {
    authDao.deleteUser();
    userModel = null;
    tasksDao.removeAll();
    list.clear();
    selectedFolder = null;
    setState(() {});
  }

  void _addTask() {
    final group = GroupModel.empty();
    selectedFolder!.tasks!.add(group);
    saveTasks();
    setState(() {});
    scrollToBottom(scrollController);
    //--------------------------------------------
    collection?.update(
        {group.createdOn!.millisecondsSinceEpoch.toString(): group.toJson()});
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
    tasksDao = TasksDao.instance;
    authDao = AuthDao();

    initTask();
    initUser();
    super.initState();
  }

  Future<void> initUser() async {
    final user = await authDao.getLoggedUser();
    if (user != null) {
      userModel = user;
      setState(() {});
    }
  }

  Future<void> signUp() async {
    final user = await AuthApi().signUp();
    if (user != null) {
      userModel = user;
      setState(() {});
    }
  }

  DocumentReference<Map<String, dynamic>>? collection;
  @override
  Widget build(BuildContext context) {
    collection = selectedFolderStr == null
        ? null
        : FireStoreRepository.instance.getCollection(selectedFolderStr!);
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          drawer: Drawer(
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 40,
                        width: 40,
                        color: Colors.grey,
                        child: userModel == null
                            ? InkWell(onTap: signUp, child: const FlutterLogo())
                            : Image.network(userModel!.imageUrl),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userModel == null
                              ? 'name'
                              : userModel!.name.isEmpty
                                  ? 'NONE'
                                  : userModel!.name,
                          //style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          userModel == null
                              ? 'email@test.com'
                              : userModel!.email,

                          // style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
                if (userModel != null)
                  Text(
                    'UID: ${userModel!.uid}',
                    //style: TextStyle(color: Colors.grey),
                  ),
                Divider(
                  thickness: 2,
                  color: Theme.of(context).primaryColor,
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('tasks')
                        .doc(uid)
                        .collection('folders')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) return const Offstage();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: snapshot.data!.docs
                            .map((e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(e.id),
                                ))
                            .toList(),
                      );
                    }),
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
                IconButton(onPressed: deleteAll, icon: const Icon(Icons.remove))
            ],
            title: Text(selectedFolder?.title ?? 'TODO TASK'),
          ),
          body: Column(
            children: [
              if (selectedFolderStr != null)
                MyWidget(
                  folderName: selectedFolderStr!,
                  key: ValueKey(selectedFolderStr),
                ),
              if (selectedFolder != null)
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: collection?.snapshots(),
                    builder: (context, snapshot) {
                      return Expanded(
                        child: ReorderableListView.builder(
                          scrollController: scrollController,
                          buildDefaultDragHandles: false,
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 80),
                          itemCount: selectedFolder!.tasks!.length,
                          itemBuilder: (ctx, index) {
                            final item = selectedFolder!.tasks![index];
                            return TextItemWidget(
                                index: index,
                                key: ValueKey(item),
                                model: item,
                                onChanged: (newModel) {
                                  selectedFolder!.tasks![index].text =
                                      newModel.text;
                                  selectedFolder!.tasks![index].tasks =
                                      newModel.tasks;
                                  selectedFolder!.tasks![index].isDone =
                                      newModel.isDone;
                                  selectedFolder!.tasks![index].isVisible =
                                      newModel.isVisible;

                                  setState(() {});
                                  saveTasks();

                                  //----------------
                                  collection?.update({
                                    item.createdOn!.millisecondsSinceEpoch
                                        .toString(): newModel.toJson()
                                  });
                                },
                                onTapDelete: () {
                                  if ((item.text ?? '').isEmpty &&
                                      item.tasks!.isEmpty) {
                                    deleteTask(item);
                                  } else {
                                    showDeleteTaskDialog(item);
                                  }
                                });
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

                            final map = <String, dynamic>{};
                            for (final element in selectedFolder!.tasks!) {
                              map[element.createdOn!.millisecondsSinceEpoch
                                  .toString()] = element.toJson();
                            }

                            //     collection?.set({});
                            collection?.set(Map.of(map));
                          },
                        ),
                      );
                    }),
            ],
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
        selectedFolderStr = folderModel.title;
        final i = list.indexOf(selectedFolder!);
        tasksDao.setSelectedGroup(i);
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
    final selectedGroupIndex = tasksDao.getSelectedGroup();

    List<FolderModel> result = tasksDao.getFolders();

    if ((result).isNotEmpty && selectedGroupIndex != -1) {
      selectedFolder = result[selectedGroupIndex];
      selectedFolderStr = selectedFolder?.title;
    }
    list = result;
    setState(() {});
  }

  void saveTasks() {
    tasksDao.saveTasks(list);
  }

  void copyToCliboard() {
    bool hasData = ClipboardUtils.copyFolderToCliboard(selectedFolder!);
    if (hasData) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('All tasks copied to buffer'),
        duration: Duration(milliseconds: 500),
      ));
    }
  }

  void deleteTask(GroupModel model) {
    selectedFolder!.tasks!.remove(model);
    setState(() {});
    saveTasks();

    //----------------
    collection?.update({
      model.createdOn!.millisecondsSinceEpoch.toString(): FieldValue.delete()
    });
  }

  void showDeleteTaskDialog(GroupModel model) {
    showDialog(
        context: context,
        builder: (ctx) {
          return Focus(
            autofocus: true,
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                selectedFolder!.tasks!.remove(model);
                setState(() {});
                saveTasks();

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
                      deleteTask(model);
                      Navigator.pop(context);
                    },
                    child: const Text('OK')),
              ],
            ),
          );
        });
  }

  void deleteGroup(FolderModel model) {
    list.remove(model);
    selectedFolder = null;
    selectedFolderStr = null;
    tasksDao.setSelectedGroup(-1);
    setState(() {});
    saveTasks();

    collection?.delete();
    Navigator.pop(context);
  }

  void showDeleteGroupDialog(FolderModel model) {
    showDialog(
        context: context,
        builder: (ctx) {
          return Focus(
            autofocus: true,
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                deleteGroup(model);
              }
              return KeyEventResult.ignored;
            },
            child: AlertDialog(
              title: Text('DELETE "${model.title ?? ''}" ?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => deleteGroup(model),
                    child: const Text('OK')),
              ],
            ),
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
    selectedFolderStr = folderModel.title;
    final i = list.indexOf(selectedFolder!);
    tasksDao.setSelectedGroup(i);
    saveTasks();
    setState(() {});
    Navigator.pop(context);
    Navigator.pop(context);
    //--------------------------------------------
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(title)
        .set({});
  }
}
