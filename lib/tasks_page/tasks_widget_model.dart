import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_task/widgets/dialog/adaptive_dialog.dart';
import 'package:todo_task/repository/tasks_repository.dart';

import '../main.dart';
import '../model/folder_model.dart';
import '../model/group_model.dart';
import '../utils/clipboard_utils.dart';

class TasksWidgetModel extends ChangeNotifier {
  TasksWidgetModel();

  GroupWrapper? group;

  FolderModel? selectedFolderStr;

  bool isEditingMode = false;
  List<GroupModel> selectedTasks = [];

  void selectTask(GroupModel model) {
    if (selectedTasks.contains(model)) {
      selectedTasks.remove(model);
    } else {
      isEditingMode = true;
      selectedTasks.add(model);
    }

    notifyListeners();
  }

  void setEditingMode(bool isEditMode) {
    isEditingMode = isEditMode;
    if (isEditingMode == false) {
      selectedTasks.clear();
    }
    notifyListeners();
  }

  void selectAllTasks() {
    if (selectedTasks.length == group!.groups.length) {
      selectedTasks.clear();
    } else {
      selectedTasks = List.of(group!.groups);
    }

    notifyListeners();
  }

  void setup(FolderModel folder) {
    if (folder.title == selectedFolderStr?.title) return;
    print('### SETUP ${folder.title}');
    selectedFolderStr = folder;
    GetIt.I<TasksRepository>().groupsStream(folder).listen((event) {
      if (event != null) {
        group = event;
        notifyListeners();
      }
    });
  }

  void close() {
    group = null;
    selectedFolderStr = null;
    isEditingMode = false;
    selectedTasks.clear();
    notifyListeners();
  }

  void addTask(GroupModel task) {
    GetIt.I<TasksRepository>().createTask(selectedFolderStr!, task);
  }

  void copyToClipboard(BuildContext context, List<GroupModel> tasks) {
    final bool hasData = ClipboardUtils.copyFolderToClipboard(tasks);
    if (hasData) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('All tasks copied to buffer'),
        duration: Duration(milliseconds: 500),
      ));
    }
  }

  void deleteTasks(List<GroupModel> tasks) {
    GetIt.I<TasksRepository>().deleteTask(tasks, selectedFolderStr!);
  }

  void onChangeGroupModel(GroupModel newModel, int index) {
    GetIt.I<TasksRepository>()
        .onChangedGroupModel(selectedFolderStr!, newModel, index);
  }

  void onReorder(int oldIndex, int newIndex) {
    GetIt.I<TasksRepository>()
        .onReorder(selectedFolderStr!.title, newIndex, oldIndex);
  }
}
