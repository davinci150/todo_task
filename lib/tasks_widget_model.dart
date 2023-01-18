import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:todo_task/dao/tasks_dao.dart';
import 'package:todo_task/tasks_repository.dart';

import 'model/folder_model.dart';
import 'model/group_model.dart';
import 'utils/clipboard_utils.dart';

class TasksWidgetModel extends ChangeNotifier {
  TasksWidgetModel() {
    _setup();
  }

  List<GroupModel> groups = [];

  List<FolderModel> list = [];

  FolderModel? selectedFolder;

  String? selectedFolderStr;

  void _setup() {
    final selectedGroupIndex = TasksDao.instance.getSelectedGroup();

    list = TasksDao.instance.getFolders();

    if ((list).isNotEmpty && selectedGroupIndex != -1) {
      selectedFolder = list[selectedGroupIndex];
      selectedFolderStr = selectedFolder?.title;
      //collection =
      //    FireStoreRepository.instance.getCollection(selectedFolderStr!);
    }
    log('setup $selectedFolderStr');
    TasksRepository.instance.groupsStream(selectedFolderStr).listen((event) {
      if (event != null) {
        log(event.length.toString());
        groups = event;
      }
    });
    notifyListeners();
  }

  Stream<List<GroupModel>?> groupsStream(String? folderKey) {
    return TasksRepository.instance.groupsStream(selectedFolderStr);
  }

  void deleteGroup(FolderModel model) {
    TasksRepository.instance.deleteGroup(model);

    selectedFolder = null;
    selectedFolderStr = null;

    notifyListeners();
  }

  void addTask() {
    TasksRepository.instance.createTask(selectedFolderStr!);
  }

  void addFolder(String title) {
    TasksRepository.instance.createFolder(title);
  }

  void selectGroup(FolderModel folderModel) {
    selectedFolder = folderModel;
    selectedFolderStr = folderModel.title;

    notifyListeners();
    final i = list.indexOf(selectedFolder!);
    TasksDao.instance.setSelectedGroup(i);
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
    /*if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = selectedFolder!.tasks![oldIndex];
    selectedFolder!.tasks!.removeAt(oldIndex);
    selectedFolder!.tasks!.insert(newIndex, item);
    notifyListeners();
    saveTasks();

    final map = <String, dynamic>{};
    for (final element in selectedFolder!.tasks!) {
      map[element.createdOn!.millisecondsSinceEpoch.toString()] =
          element.toJson();
    }

    //    collection?.set({});
    collection?.set(Map.of(map));*/
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
}
