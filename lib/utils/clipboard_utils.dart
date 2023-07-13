import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:todo_task/model/task_model.dart';

class ClipboardUtils {
  static bool copyFolderToClipboard(List<TaskModel> tasks) {
       // print('### ${tasks.length}');
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
      if (value.subtasks.isNotEmpty) {
        final listTasks =
            value.subtasks.where((element) => element.isVisible == true).toList();
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
     // log('### ${res}');
      Clipboard.setData(ClipboardData(text: res));
      return true;
    }
    return false;
  }

  static bool copyGroupToClipboard(TaskModel model) {
    String res = '';

    res = res + model.text + '\n';
    if (model.subtasks.isNotEmpty) {
      final listTasks =
          model.subtasks.where((element) => element.isVisible == true).toList();
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
