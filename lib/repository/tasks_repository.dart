import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:todo_task/model/group_model.dart';
import 'package:rxdart/rxdart.dart';
import '../api/tasks_api.dart';
import '../services/context_provider.dart';
import '../dao/tasks_dao.dart';
import '../widgets/dialog/adaptive_dialog.dart';
import '../model/folder_model.dart';

@LazySingleton()
class TasksRepository {
  TasksRepository({required this.taskApi, required this.tasksDao});
  final TasksApi taskApi;
  final TasksDao tasksDao;

  BehaviorSubject<List<GroupModel>>? streamGroups;
  BehaviorSubject<List<FolderModel>>? streamFolders;

  String? selectedFolderStr;

  Stream<List<FolderModel>?> foldersStream() {
    final Stream<List<FolderModel>> firestoreStream = taskApi.foldersStream();

    streamFolders ??= BehaviorSubject();

    final fold = List.of(tasksDao.getFolders());
    log('load folder ${fold.length}');

    streamFolders!.sink.add(fold);

    return firestoreStream;
    Rx.merge([
      firestoreStream,
      // streamFolders!.stream,
    ]);
  }

  Stream<GroupWrapper?> groupsStream(FolderModel? folder) {
    if (folder == null) return Stream.value(null);
    streamGroups ??= BehaviorSubject();
    // final Stream<GroupWrapper> firestoreStream =
    return taskApi.getGroups(folder);

    /*   if (selectedFolderStr != folderKey) {
      selectedFolderStr = folderKey;
      final list = tasksDao.getGroups(folderKey);
      log('load list ${list.length}');

      streamGroups!.sink.add(list);
    } */
    // return Rx.merge([
    //   firestoreStream,
    //   streamGroups!.stream,
    // ]);
    /*  return Rx.combineLatest2(firestoreStream, streamGroups!.stream,
        (List<GroupModel> firestore, List<GroupModel> local) {
      //  if()
      return firestore;
    }); */
  }

  Future<void> createTask(FolderModel folder, GroupModel task) async {
    log('create task to ${folder.title}');
    // int i = 0;
    // for (var element in streamGroups!.value) {
    //   if (element.indexInList! > i) {
    //     i = element.indexInList!;
    //   }
    // }
    // i++;

    /*   final i = streamGroups!.value.isEmpty
        ? 0
        : streamGroups!.value
                .reduce((value, element) =>
                    value.indexInList! > element.indexInList! ? value : element)
                .indexInList! +
            1; */

    /*   final group = GroupModel.empty(i)
        .copyWith(text: task.text, notificationDate: () => task.date); */
    /*   final list = streamGroups!.value..add(task);
    streamGroups!.sink.add(list);

    saveTasks(list, folderName); */

    //--
    taskApi.createGroup(folder, task);
  }

  Future<void> deleteTask(List<GroupModel> tasks, FolderModel folder) async {
    log('remove task ${folder.title}');

    /*   final list = streamGroups!.value..remove(model);

    saveTasks(list, folderName);
    streamGroups!.sink.add(list); */
    //--
    for (final element in tasks) {
      taskApi.deleteGroup(folder, element);
    }
  }

  Future<void> createFolder(FolderModel model) async {
    final l = streamFolders!.value..add(model);
    streamFolders!.add(l);

    tasksDao.createFolder(model);

    //--
    await taskApi.createFolder(model.title);
  }

  Future<void> renameFolder(String title, FolderModel folder) async {
    await taskApi.renameFolder(folder, title);
  }

  void onChangedGroupModel(FolderModel folder, GroupModel newModel, int index) {
    // log(streamGroups!.value.length.toString());
    // final list = streamGroups!.value..[index] = newModel;
//
    // saveTasks(list, folderName);
    // streamGroups!.sink.add(list);

    //--
    taskApi.onChangeGroupModel(folder, newModel);
    /*   taskApi.updateGroups(folderName, <String, dynamic>{
      newModel.createdOn.millisecondsSinceEpoch.toString(): newModel.toJson()
    }); */
  }

  void deleteFolder(FolderModel model) {
    final l = streamFolders!.value..remove(model);
    streamFolders!.add(l);
    tasksDao.deleteFolder(model);
    tasksDao.setSelectedGroup(null);

    //--
    taskApi.deleteFolder(model.title);
  }

  void onReorder(String folderKey, int oldIndex, int newIndex) {
    /*  final oldIndexModel = streamGroups!.value[oldIndex];
    final list = List.of(streamGroups!.value)
      ..removeAt(oldIndex)
      ..insert(newIndex, oldIndexModel);

    saveTasks(list, folderKey);
    streamGroups!.sink.add(list);

    //--
    final Map<String, dynamic> map = <String, dynamic>{};
    list.asMap().forEach((key, value) {
      map[value.createdOn.millisecondsSinceEpoch.toString()] =
          value.copyWith(indexInList: key).toJson();
    });
    taskApi.updateGroups(folderKey, map); */
  }

  void saveTasks(List<GroupModel> list, String folderKey) {
    tasksDao.saveTasks(list, folderKey);
  }

  bool isShowDialog = false;
  Future<void> showConflictDialog(List<GroupModel> local,
      List<GroupModel> firestore, String folderKey) async {
    if (isShowDialog) return;
    isShowDialog = true;
    await showDialog<void>(
        context: navigatorKey.currentContext!,
        builder: (ctx) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        final map = <String, dynamic>{};
                        for (final element in local) {
                          map[element.createdOn.millisecondsSinceEpoch
                              .toString()] = element.toJson();
                        }
                        // taskApi.updateGroups(folderKey, map);

                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Local'),
                            ...local
                                .map((e) => Row(
                                      children: [
                                        Icon(e.isDone == true
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank),
                                        Expanded(
                                            child: Text(
                                          e.text,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                      ],
                                    ))
                                .toList()
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: () {
                        streamGroups!.sink.add(firestore);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Firestore'),
                            ...firestore
                                .map((e) => Row(
                                      children: [
                                        Icon(e.isDone == true
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank),
                                        Expanded(
                                          child: Text(
                                            e.text,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ))
                                .toList()
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Compire'))
              ],
            ),
          );
        }).then((value) => isShowDialog = false);
  }
}
