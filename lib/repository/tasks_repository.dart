import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_task/model/group_model.dart';
import 'package:rxdart/rxdart.dart';
import '../api/firestore_api.dart';
import '../context_provider.dart';
import '../dao/tasks_dao.dart';
import '../dialog/input_text_dialog.dart';
import '../model/folder_model.dart';

class TasksRepository {
  TasksRepository._();

  static final TasksRepository instance = TasksRepository._();

  BehaviorSubject<List<GroupModel>>? streamGroups;
  BehaviorSubject<List<FolderModel>>? streamFolders;

  String? selectedFolderStr;

  Stream<List<FolderModel>?> foldersStream() {
    final Stream<List<FolderModel>> firestoreStream =
        TasksApi().foldersStream();

    streamFolders ??= BehaviorSubject();

    final fold = List.of(TasksDao.instance.getFolders());
    log('load folder ${fold.length}');

    streamFolders!.sink.add(fold);

    return Rx.merge([
      firestoreStream,
      // streamFolders!.stream,
    ]);
  }

  Stream<List<GroupModel>?> groupsStream(String? folderKey) {
    log('getStream: $folderKey');
    if (folderKey == null) return Stream.value(null);
    streamGroups ??= BehaviorSubject();
    final Stream<List<GroupModel>> firestoreStream =
        TasksApi().getGroups(folderKey).asyncMap((event) async {
      // for (var element in event) {
      //   final mod =
      //       streamGroups!.value.firstWhereOrNull((item) => item == element);
      //   if (mod == null) {
      //     await showConflictDialog(streamGroups!.value, event, folderKey);
      //     break;
      //   }
      // }
      return event;
    });

    if (selectedFolderStr != folderKey) {
      selectedFolderStr = folderKey;
      final list = TasksDao.instance.getGroups(folderKey);
      log('load list ${list.length}');

      streamGroups!.sink.add(list);
    }
    // return Rx.merge([
    //   firestoreStream,
    //   streamGroups!.stream,
    // ]);
    return Rx.combineLatest2(firestoreStream, streamGroups!.stream,
        (List<GroupModel> firestore, List<GroupModel> local) {
      //  if()
      return firestore;
    });
  }

  Future<void> createTask(String folderName, TaskCreated task) async {
    log('create task to $folderName');
    // int i = 0;
    // for (var element in streamGroups!.value) {
    //   if (element.indexInList! > i) {
    //     i = element.indexInList!;
    //   }
    // }
    // i++;

    final i = streamGroups!.value.isEmpty
        ? 0
        : streamGroups!.value
                .reduce((value, element) =>
                    value.indexInList! > element.indexInList! ? value : element)
                .indexInList! +
            1;

    final group = GroupModel.empty(i)
        .copyWith(text: task.text, notificationDate: task.date);
    final list = streamGroups!.value..add(group);
    streamGroups!.sink.add(list);

    saveTasks(list, folderName);

    //--
    TasksApi().updateGroups(folderName,
        {group.createdOn!.millisecondsSinceEpoch.toString(): group.toJson()});
  }

  Future<void> deleteTask(GroupModel model, String folderName) async {
    log('remove task $folderName');

    final list = streamGroups!.value..remove(model);

    saveTasks(list, folderName);
    streamGroups!.sink.add(list);
    //--
    TasksApi().updateGroups(folderName, {
      model.createdOn!.millisecondsSinceEpoch.toString(): FieldValue.delete()
    });
  }

  Future<void> createFolder(FolderModel model) async {
    final l = streamFolders!.value..add(model);
    streamFolders!.add(l);

    TasksDao.instance.createFolder(model);

    //--
    TasksApi().createFolder(model.title);
  }

  Future<void> renameFolder(String title, String folderKey) async {
    await TasksApi().renameFolder(folderKey, title);
  }

  void onChangedGroupModel(String folderName, GroupModel newModel, int index) {
    // log(streamGroups!.value.length.toString());
    // final list = streamGroups!.value..[index] = newModel;
//
    // saveTasks(list, folderName);
    // streamGroups!.sink.add(list);

    //--
    TasksApi().updateGroups(folderName, {
      newModel.createdOn!.millisecondsSinceEpoch.toString(): newModel.toJson()
    });
  }

  void deleteGroup(FolderModel model) {
    final l = streamFolders!.value..remove(model);
    streamFolders!.add(l);
    TasksDao.instance.deleteFolder(model);
    TasksDao.instance.setSelectedGroup(null);

    //--
    TasksApi().deleteFolder(model.title);
  }

  void onReorder(String folderKey, int oldIndex, int newIndex) {
    final oldIndexModel = streamGroups!.value[oldIndex];
    final list = List.of(streamGroups!.value)
      ..removeAt(oldIndex)
      ..insert(newIndex, oldIndexModel);

    saveTasks(list, folderKey);
    streamGroups!.sink.add(list);

    //--
    Map<String, dynamic> map = {};
    list.asMap().forEach((key, value) {
      map[value.createdOn!.millisecondsSinceEpoch.toString()] =
          value.copyWith(indexInList: key).toJson();
    });
    TasksApi().updateGroups(folderKey, map);
  }

  void saveTasks(List<GroupModel> list, String folderKey) {
    TasksDao.instance.saveTasks(list, folderKey);
  }

  bool isShowDialog = false;
  Future<void> showConflictDialog(List<GroupModel> local,
      List<GroupModel> firestore, String folderKey) async {
    if (isShowDialog) return;
    isShowDialog = true;
    showDialog(
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
                        for (var element in local) {
                          map[element.createdOn!.millisecondsSinceEpoch
                              .toString()] = element.toJson();
                        }
                        TasksApi().updateGroups(folderKey, map);

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
                                          e.text ?? '',
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
                                            e.text ?? '',
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
