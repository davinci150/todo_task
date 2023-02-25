import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:todo_task/dao/tasks_dao.dart';
import 'package:todo_task/dialog/input_text_dialog.dart';
import 'package:todo_task/repository/tasks_repository.dart';

import 'main.dart';
import 'model/folder_model.dart';
import 'model/group_model.dart';
import 'utils/clipboard_utils.dart';

class TasksWidgetModel extends ChangeNotifier {
  TasksWidgetModel() {
    _setup();
  }

  List<GroupModel> groups = [];

  List<FolderModel> list = [];

  String? selectedFolderStr;

  BehaviorSubject<String?> selectedGroupKey = BehaviorSubject.seeded(null);

  void _setup() {
    final selectedGroupIndex = TasksDao.instance.getSelectedGroup();

    list = TasksDao.instance.getFolders();

    if (selectedGroupIndex != null) {
      selectedFolderStr = selectedGroupIndex;
      selectedGroupKey.sink.add(selectedFolderStr);
    }
    selectedGroupKey.stream.listen((key) {
      TasksRepository.instance.groupsStream(key).listen((event) {
        if (event != null) {
          groups = event;
          notifyListeners();
        }
      });
    });
    TasksRepository.instance.foldersStream().listen((event) {
      list = event ?? [];
      notifyListeners();
    });
  }

  void deleteGroup(FolderModel model) {
    TasksRepository.instance.deleteGroup(model);
    selectedFolderStr = null;
    notifyListeners();
  }

  void addTask(TaskCreated task) {
    TasksRepository.instance.createTask(selectedFolderStr!, task);
  }

  void addFolder(String title) {
    final folderModel = FolderModel(title: title);
    TasksRepository.instance.createFolder(folderModel);
    selectFolder(title);
  }

  void selectFolder(String folderKey) {
    selectedFolderStr = folderKey;
    selectedGroupKey.sink.add(selectedFolderStr!);
    notifyListeners();
    TasksDao.instance.setSelectedGroup(selectedFolderStr!);
  }

  Future<void> renameFolder(String title, String folderKey) async {
    await TasksRepository.instance.renameFolder(title, folderKey);
    selectFolder(title);
    notifyListeners();
  }

  void copyToCliboard() {
    bool hasData = ClipboardUtils.copyFolderToCliboard(groups);
    if (hasData) {
      //  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //    content: Text('All tasks copied to buffer'),
      //    duration: Duration(milliseconds: 500),
      //  ));
    }
  }

  void deleteTask(GroupModel model) {
    TasksRepository.instance.deleteTask(model, selectedFolderStr!);
  }

  void onChangeGroupModel(GroupModel newModel, int index) {
    TasksRepository.instance
        .onChangedGroupModel(selectedFolderStr!, newModel, index);
  }

  void onReorder(int oldIndex, int newIndex) {
    TasksRepository.instance.onReorder(selectedFolderStr!, newIndex, oldIndex);
  }
}

class TaskWidgetModelProvider extends InheritedNotifier {
  const TaskWidgetModelProvider(
      {Key? key, required Widget child, required this.model})
      : super(key: key, child: child, notifier: model);

  final TasksWidgetModel model;

  static TaskWidgetModelProvider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TaskWidgetModelProvider>();
  }

  static TaskWidgetModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<TaskWidgetModelProvider>()
        ?.widget;
    return widget is TaskWidgetModelProvider ? widget : null;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<Listenable> oldWidget) {
    return true;
  }
}

class ThemeModelProvider extends InheritedNotifier {
  const ThemeModelProvider(
      {Key? key, required Widget child, required this.model})
      : super(key: key, child: child, notifier: model);

  final ModelTheme model;

  static ThemeModelProvider? watch(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModelProvider>();
  }

  static ThemeModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<ThemeModelProvider>()
        ?.widget;
    return widget is ThemeModelProvider ? widget : null;
  }
}

//class ChangeNotifierProviders<T extends ChangeNotifier>
//    extends InheritedNotifier {
//  const ChangeNotifierProviders(
//      {Key? key, required Widget child, required this.model})
//      : super(key: key, child: child, notifier: model);
//
//  final T model;
//
//  static ChangeNotifierProviders<T>? watch<T>(BuildContext context) {
//    return context
//        .dependOnInheritedWidgetOfExactType<ChangeNotifierProviders<TasksWidgetModel>>();
//  }
//
//  static ChangeNotifierProviders? read(BuildContext context) {
//    final widget = context
//        .getElementForInheritedWidgetOfExactType<
//            ChangeNotifierProviders<TasksWidgetModel>>()
//        ?.widget;
//    return widget is ChangeNotifierProviders<TasksWidgetModel> ? widget : null;
//  }
//}
