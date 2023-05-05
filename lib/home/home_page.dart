import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';

import '../api/tasks_api.dart';
import '../main.dart';
import '../model/folder_model.dart';
import '../model/user_model.dart';
import '../router/router_generator.dart';
import '../services/context_provider.dart';
import '../tasks_page/tasks_widget_model.dart';
import '../widgets/dialog/adaptive_dialog.dart';
import 'sidebar/sidebar.dart';
import 'sidebar/sidebar_widget_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

const taskKey = kDebugMode ? 'testKeyV1' : 'taskKeyV2';
const selectedGroupKey = kDebugMode ? 'selectedGroupV1' : 'selectedGroupV1';
final GlobalKey<ScaffoldState> drawerKey = GlobalKey(); // Create a key

class _MyHomePageState extends State<HomePage> {
  UserModel? userModel;
  late ScrollController scrollController;

  Future<void> scrollToBottom(ScrollController scrollController) async {
    await scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.easeInOut);

    while (scrollController.position.pixels !=
        scrollController.position.maxScrollExtent) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      await SchedulerBinding.instance.endOfFrame;
    }
  }

  @override
  void initState() {
    scrollController = ScrollController();

    super.initState();
    context.read<SidebarWidgetModel>().setup();
  }

  @override
  Widget build(BuildContext context) {
    final _model = context.watch<TasksWidgetModel>();
    final sidebarWidgetModel = context.watch<SidebarWidgetModel>();

    log('### BUIDL isDesktop: ${MediaQuery.of(context).size.shortestSide}');

    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);

    log('### BUIDL isDesktop: ${data.size.shortestSide}');
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: drawerKey,
        /*    appBar: !isDesktop
            ? AppBar(
                title: _model.isEditingMode
                    ? null
                    : Text(sidebarWidgetModel.selectedFolderStr ?? 'TODO TASK'),
                actions: [
                  if (sidebarWidgetModel.selectedFolderStr != null &&
                      _model.group != null &&
                      _model.group!.members.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          _model.group!.members.length.toString(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Icon(Icons.supervised_user_circle_sharp),
                      ],
                    ),
                  if (sidebarWidgetModel.selectedFolderStr != null &&
                      _model.group != null &&
                      _model.group!.members.isNotEmpty)
                    IconButton(
                        onPressed: () {
                          showShareDialog(_model.selectedFolderStr!);
                        },
                        icon: const Icon(Icons.share)),
                  if (_model.isEditingMode)
                    IconButton(
                        onPressed: () {
                          _model.copyToClipboard(context, _model.selectedTasks);
                        },
                        icon: const Icon(Icons.copy_all)),
                  if (_model.isEditingMode)
                    IconButton(
                        onPressed: _model.selectAllTasks,
                        icon: const Icon(Icons.done_all)),
                  if (_model.isEditingMode)
                    IconButton(
                        onPressed: () {
                          _model.setEditingMode(false);
                        },
                        icon: const Icon(Icons.close)),
                ],
              )
            : null, */
        drawer: !isDesktop ? const SideBar() : null,
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (isDesktop) const SideBar(),
                  Expanded(
                      child: Navigator(
                    key: nestedNavigatorKey,
                    //    observers: [NavObs()],
                    onGenerateRoute: onGenerateRoute,
                    initialRoute: '/',
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class NavObs extends NavigatorObserver {
  final NavRepository _navRepository = NavRepository.instance;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _navRepository.popRoute();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is CustomNavRoute<dynamic>) {
      _navRepository.add(route);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // TODO: implement didRemove
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    // TODO: implement didReplace
  }
}

class NavRepository {
  NavRepository._();

  static final NavRepository instance = NavRepository._();

  BehaviorSubject<List<CustomNavRoute<dynamic>>> behaviorSubject =
      BehaviorSubject.seeded([]);

  BehaviorSubject<CustomNavRoute<dynamic>?> lastPageSubj = BehaviorSubject();

  void add(CustomNavRoute<dynamic> route) {
    // final routes = List.of(behaviorSubject.value)..add(route);
    // behaviorSubject.add(routes);
    // lastPageSubj.add(null);
    // print('### ${behaviorSubject.value.map((e) => e.settings.name).toList()}');
  }

  void popRoute() {
    //  final routes = List.of(behaviorSubject.value)..removeLast();
    //  lastPageSubj.add(behaviorSubject.value.last);
    //  behaviorSubject.add(routes);

    //  print('### ${behaviorSubject.value.map((e) => e.settings.name).toList()}');
  }

  Stream<bool> canPop() {
    return behaviorSubject.stream.map((event) => event.length > 1);
  }

  Stream<CustomNavRoute<dynamic>?> nextPage() {
    return lastPageSubj.stream;
  }
}
