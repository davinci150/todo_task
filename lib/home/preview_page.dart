import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/fcm.dart';
import '../main.dart';
import '../services/context_provider.dart';
import '../services/notification_service.dart';
import '../tasks_page/tasks_page.dart';
import '../widgets/dialog/adaptive_dialog.dart';
import 'sidebar/sidebar_widget_model.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _model = context.read<SidebarWidgetModel>();
    return Scaffold(
      appBar: isDesktop
          ? null
          : CustomAppBar(
              title: '',
            ),
      body: Center(
        child: InkWell(
          onTap: () async {
            final title = await inputTextDialog();
            if (title != null && title.isNotEmpty) {
              _model.addFolder(title);
              await Navigator.of(nestedNavigatorKey.currentContext!)
                  .pushNamed('tasks_page', arguments: title);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.add,
                size: 40,
              ),
              SizedBox(
                width: 8,
              ),
              Flexible(
                child: Text(
                  'Create new folder',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
