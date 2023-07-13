import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../api/tasks_api.dart';
import '../../model/folder_model.dart';
import 'adaptive_dialog.dart';

Future<void> showShareDialog(BuildContext context, FolderModel folder) {
  String email = '';
  return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title:
              const Text('Чтобы поделиться списком введите email пользователя'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              onChanged: (text) {
                email = text;
              },
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () async {
                      try {
                        await GetIt.I<TasksApi>().share(email, folder);
                        await showAlert(title: 'Пользователь добавлен');
                      } on Exception catch (e) {
                        await showAlert(title: e.toString());
                      }

                      /*  if (isSend) {
                          Navigator.pop(context);
                        } */
                    },
                    child: const Text('Share')),
              ],
            ),
          ]),
        );
      });
}
