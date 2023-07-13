import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import '../model/folder_model.dart';
import '../model/task_model.dart';
import '../repository/tasks_repository.dart';
import '../utils/clipboard_utils.dart';

// ignore: constant_identifier_names
enum TasksSort { old_first, new_first }

class TasksWidgetModel extends ChangeNotifier {
  TasksWidgetModel(this.folder) {
    setup();
  }
  final FolderModel folder;

  List<TaskModel>? group;

  FolderModel? selectedFolderStr;

  bool isEditingMode = false;
  List<TaskModel> selectedTasks = [];

  BehaviorSubject<TasksSort> taskSort =
      BehaviorSubject.seeded(TasksSort.old_first);

  void selectTask(TaskModel model) {
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
    if (selectedTasks.length == group!.length) {
      selectedTasks.clear();
    } else {
      selectedTasks = List.of(group!);
    }

    notifyListeners();
  }

  StreamSubscription<List<TaskModel>?>? tasksSub;

  void setup() {
    if (folder.name == selectedFolderStr?.name) return;
    //print('### SETUP ${folder.title}');
    isEditingMode = false;
    selectedTasks.clear();
    selectedFolderStr = folder;
    tasksSub = Rx.combineLatest2(
        GetIt.I<TasksRepository>().groupsStream(folder), taskSort,
        (List<TaskModel>? event, TasksSort sort) {
      if (event != null) {
        if (sort == TasksSort.old_first) {
          event.sort((a, b) => a.createdOn.compareTo(b.createdOn));
        } else if (sort == TasksSort.new_first) {
          event.sort((a, b) => b.createdOn.compareTo(a.createdOn));
        }
      }

      return event;
    }).listen((a) {
      if (a != null) {
        // Future<void>.delayed(Duration(seconds: 5)).then((value) {
        group = a;
        notifyListeners();
        // });
      }
    });
  }

  void changeSort(TasksSort sort) {
    taskSort.add(sort);
  }

  bool _disposed = false;

  @override
  void notifyListeners() {
    // print('### CHANGE NOTI');
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    //print('###  dispose');

    tasksSub?.cancel();
    taskSort.close();
    if (!_disposed) {
      super.dispose();
    }

    _disposed = true;
  }

  void addTask(TaskModel task) {
    GetIt.I<TasksRepository>().createTask(selectedFolderStr!, task);
  }

  void copyToClipboard(BuildContext context, List<TaskModel> tasks) {
    final bool hasData = ClipboardUtils.copyFolderToClipboard(tasks);
    if (hasData) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('All tasks copied to buffer'),
        duration: Duration(milliseconds: 500),
      ));
    }
  }

  void deleteTasks(List<TaskModel> tasks) {
    GetIt.I<TasksRepository>().deleteTask(tasks, selectedFolderStr!);
  }

  void onChangeGroupModel(TaskModel newModel, int index) {
    GetIt.I<TasksRepository>()
        .onChangedGroupModel(selectedFolderStr!, newModel, index);
  }

  void onReorder(int oldIndex, int newIndex) {
    GetIt.I<TasksRepository>()
        .onReorder(selectedFolderStr!.name, newIndex, oldIndex);
  }
}
