import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_task/model/group_model.dart';
import 'package:todo_task/model/user_model.dart';

import 'firestore_repository.dart';
import 'widget/task_item_widget.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key, required this.folderName}) : super(key: key);

  final String folderName;

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    final collection =
        FireStoreRepository.instance.getCollection(widget.folderName);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: collection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null) return const SizedBox();
        final fsdf = snapshot.data!.data() ?? {};
       // log(fsdf.toString());

        final List<GroupModel> listGroups = fsdf.isEmpty
            ? []
            : fsdf.values
                .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
                .toList();

        return Column(children: [
          ...listGroups.map((e) {
            final index = listGroups.indexOf(e);

            return TextItemWidget(
                model: e, index: index, onChanged: (gr) {}, onTapDelete: () {});
          }).toList(),
        ]);
      },
    );
  }
}
