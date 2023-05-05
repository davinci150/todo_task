import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:todo_task/model/group_model.dart';

class ClipboardUtils {
  static bool copyFolderToClipboard(List<GroupModel> tasks) {
        print('### ${tasks.length}');
    String res = '';
    tasks
       /*  .where((element) => element.isVisible == true)
        .toList() */
        .asMap()
        .forEach((key, value) {
      res = res +
          '${key + 1})' +
          (value.isDone! ? ' ✓ ' : ' ☐ ') +
          value.text +
          '\n';
      if (value.tasks.isNotEmpty) {
        final listTasks =
            value.tasks.where((element) => element.isVisible == true).toList();
        if (listTasks.isNotEmpty) {
          for (var task in listTasks) {
            res = res +
                (task.isDone! ? '       ✓ ' : '       ☐ ') +
                task.text! +
                '\n';
          }
        }
      }
    });

    if (res.isNotEmpty) {
      log('### ${res}');
      Clipboard.setData(ClipboardData(text: res));
      return true;
    }
    return false;
  }

  static bool copyGroupToClipboard(GroupModel model) {
    String res = '';

    res = res + model.text + '\n';
    if (model.tasks.isNotEmpty) {
      final listTasks =
          model.tasks.where((element) => element.isVisible == true).toList();
      if (listTasks.isNotEmpty) {
        for (var task in listTasks) {
          res = res + (task.isDone! ? '✓ ' : '☐ ') + task.text! + '\n';
        }
      }
    }
    // log(res);
    if (res.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: res));
      return true;
    }
    return false;
  }
}
