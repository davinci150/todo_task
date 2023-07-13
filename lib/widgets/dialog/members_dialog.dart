import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../api/tasks_api.dart';

void showMembersDialog(BuildContext context, List<String> usersUid) {
  showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: FutureBuilder<List<String?>>(
              future: GetIt.I<TasksApi>().getUsersByIds(usersUid),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return const SizedBox(
                      width: 30,
                      height: 30,
                      child: Center(child: CircularProgressIndicator()));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data!
                      .map((e) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_outline),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                e ?? 'unknown',
                                style: TextStyle(
                                    color: e == null ? Colors.grey : null),
                              ),
                            ],
                          ))
                      .toList(),
                );
              }),
        );
      });
}
