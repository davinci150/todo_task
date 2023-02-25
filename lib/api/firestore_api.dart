import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_task/model/group_model.dart';

import '../dialog/input_text_dialog.dart';
import '../home_page.dart';
import '../model/folder_model.dart';

class TasksApi {
  Stream<List<FolderModel>> foldersStream() {
    return FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .snapshots()
        .map((event) {
      final List<FolderModel> list = [];
      for (final element in event.docs) {
        list.add(FolderModel(title: element.id));
      }
      return list;
    });
  }

  Future<void> renameFolder(String folderKey, String title) async {
    final doc = await FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(folderKey)
        .get();
    if (doc.exists) {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(uid)
          .collection('folders')
          .doc(folderKey)
          .delete();

      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(uid)
          .collection('folders')
          .doc(title)
          .set(doc.data()!);
    }
  }

  Stream<List<GroupModel>> getGroups(String? folderKey) {
    return FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(folderKey)
        .snapshots()
        .map((event) {
      if (event.data() == null) {
        return [];
      }

      return event
          .data()!
          .values
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  void updateGroups(String folderKey, Map<String, dynamic> map) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(folderKey)
        .update(map);
  }

  void createFolder(String title) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(title)
        .get()
        .then((value) {
      if (value.exists) {
        showAlert(title: 'This folder is exists');
      } else {
        FirebaseFirestore.instance
            .collection('tasks')
            .doc(uid)
            .collection('folders')
            .doc(title)
            .set({});
      }
    });
  }

  void deleteFolder(String folderKey) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(folderKey)
        .delete();
  }
}
