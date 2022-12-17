import 'dart:convert';
import 'dart:developer';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_task/dao/tasks_dao.dart';
import 'package:todo_task/utils/clipboard_utils.dart';
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

const taskKey = kDebugMode ? 'testKeyV1' : 'taskKeyV2';
const selectedGroupKey = kDebugMode ? 'selectedGroupV1' : 'selectedGroupV1';

class _MyHomePageState extends State<MyHomePage> {
  List<FolderModel> list = [];
  FolderModel? selectedFolder;
  late TasksDao tasksDao;
  User? user;
  late ScrollController scrollController;
  void deleteAll() {
    tasksDao.removeAll();
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

  final googleSignInArgs = GoogleSignInArgs(
      clientId:
          '668468006082-h76emhnpea6kq2lmv043ptlq7298qdq9.apps.googleusercontent.com',
      redirectUri: //'https://localhost:59892/',
          //'https://todo-dcf3a.firebaseapp.com/__/auth/action?mode=action&oobCode=code'
          'https://todo-dcf3a.firebaseapp.com/__/auth/handler',
      // 'https://react-native-firebase-testing.firebaseapp.com/__/auth/handler',
      //  scope: 'email',ws://127.0.0.1:56710/7f4HmGG5B0I=/ws
      scope: 'email');

  Future<void> test() async {
    try {
      final result = await DesktopWebviewAuth.signIn(googleSignInArgs)
          .onError((error, stackTrace) {
        log(error.toString());
      });

      // print(result?.accessToken);
      // print(result?.tokenSecret);
      final credential =
          GoogleAuthProvider.credential(accessToken: result?.accessToken);
      final credinal =
          await FirebaseAuth.instance.signInWithCredential(credential);
      user = credinal.user;
      setState(() {});
      print(user?.uid);
    } catch (err) {
      // something went wrong
    }
  }

  @override
  void initState() {
    scrollController = ScrollController();
    tasksDao = TasksDao.instance;

    initTask();

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 40,
                        width: 40,
                        color: Colors.grey,
                        child: user == null
                            ? InkWell(onTap: test, child: const FlutterLogo())
                            : Image.network(user!.photoURL ?? ''),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user == null ? 'name' : user!.displayName ?? 'none',
                          //style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          user == null
                              ? 'email@test.com'
                              : user!.email ?? 'none',

                          // style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
                if (user != null)
                  Text(
                    'UID: ${user!.uid}',
                    //style: TextStyle(color: Colors.grey),
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
                          if ((item.text ?? '').isEmpty &&
                              item.tasks!.isEmpty) {
                            selectedFolder!.tasks!.remove(item);
                            setState(() {});
                            saveTasks();
                          } else {
                            showDeleteMsgDialog(item);
                          }

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

  void showDeleteMsgDialog(GroupModel model) {
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      selectedFolder!.tasks!.remove(model);
                      setState(() {});
                      saveTasks();

                      Navigator.pop(context);
                    },
                    child: const Text('OK')),
              ],
            ),
          );
        });
  }

  void showDeleteGroupDialog(FolderModel model) {
    showDialog(
        context: context,
        builder: (ctx) {
          return Focus(
            autofocus: true,
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                list.remove(model);
                selectedFolder = null;
                tasksDao.setSelectedGroup(-1);
                setState(() {});
                saveTasks();

                Navigator.pop(context);
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
                    onPressed: () {
                      list.remove(model);
                      selectedFolder = null;
                      tasksDao.setSelectedGroup(-1);
                      setState(() {});
                      saveTasks();

                      Navigator.pop(context);
                    },
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
    final i = list.indexOf(selectedFolder!);
    tasksDao.setSelectedGroup(i);
    saveTasks();
    setState(() {});
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
