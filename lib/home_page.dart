import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/subjects.dart';
import 'package:todo_task/birthdays/birthdays.dart';
import 'package:todo_task/dialog/input_text_dialog.dart';
import 'package:todo_task/model/user_model.dart';
import 'package:todo_task/sidebar.dart';
import 'package:todo_task/tasks_widget_model.dart';
import 'context_provider.dart';
import 'tasks_page/tasks_page.dart';
import 'main.dart';
import 'model/group_model.dart';
import 'settings/settings_page.dart';
import 'widget/task_item_widget.dart';

class HomePageWrapper extends StatelessWidget {
  const HomePageWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _model = TasksWidgetModel();
    return TaskWidgetModelProvider(
      model: _model,
      child: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

const taskKey = kDebugMode ? 'testKeyV1' : 'taskKeyV2';
const selectedGroupKey = kDebugMode ? 'selectedGroupV1' : 'selectedGroupV1';

const String uid = 'mKSkbFBTiteCnZQjVi2QzaZFF0e2';

class _MyHomePageState extends State<HomePage> {
  UserModel? userModel;
  late ScrollController scrollController;

  void deleteAll() {
    //authDao.deleteUser();
    //userModel = null;
    //tasksDao.removeAll();
    // list.clear();
    // selectedFolder = null;
    setState(() {});
  }

  Future scrollToBottom(ScrollController scrollController) async {
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
  }

  @override
  Widget build(BuildContext context) {
    final _model = TaskWidgetModelProvider.watch(context)?.model;

    log('BUIDL');
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: !isDesktop
            ? AppBar(title: Text(_model?.selectedFolderStr ?? 'TODO TASK'))
            : null,
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
                    observers: [NavObs()],
                    onGenerateRoute: onGenerateRoute,
                    initialRoute: '/',
                  ))
                ],
              ),
            )
          ],
        ),
        floatingActionButton: _model?.selectedFolderStr == null
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: () => _model?.copyToCliboard(),
                    tooltip: 'Copy to clipboard',
                    child: const Icon(Icons.copy_all_outlined),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      final text = await inpuTextDialog2();
                      if (text != null) {
                        _model?.addTask(text);
                      }
                    },
                    tooltip: 'Add new task',
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
      ),
    );
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    late Widget page;
    if (settings.name == 'tasks_page') {
      page = const TasksPage();
    } else if (settings.name == 'birthdays') {
      page = const BirthdaysPage();
    } else if (settings.name == 'settings') {
      page = const SettingsPage();
    } else {
      page = const SizedBox();
    }

    return CustomNavRoute(builder: (ctx) => page, settings: settings);
  }
}

class CustomNavRoute<T> extends MaterialPageRoute<T> {
  CustomNavRoute({WidgetBuilder? builder, RouteSettings? settings})
      : super(builder: builder!, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // if (settings.isInitialRoute) return child;
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    final tween =
        Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: curve));

    return FadeTransition(
      opacity: animation.drive(tween),
      child: child,
    );
  }
}

class NavObs extends NavigatorObserver {
  final NavRepository _navRepository = NavRepository.instance;

  @override
  void didPop(Route route, Route? previousRoute) {
    _navRepository.popRoute();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is CustomNavRoute<dynamic>) {
      _navRepository.add(route);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    // TODO: implement didRemove
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
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
    final routes = List.of(behaviorSubject.value)..add(route);
    behaviorSubject.add(routes);
    lastPageSubj.add(null);
    print('### ${behaviorSubject.value.map((e) => e.settings.name).toList()}');
  }

  void popRoute() {
    final routes = List.of(behaviorSubject.value)..removeLast();
    lastPageSubj.add(behaviorSubject.value.last);
    behaviorSubject.add(routes);

    print('### ${behaviorSubject.value.map((e) => e.settings.name).toList()}');
  }

  Stream<bool> canPop() {
    return behaviorSubject.stream.map((event) => event.length > 1);
  }

  Stream<CustomNavRoute<dynamic>?> nextPage() {
    return lastPageSubj.stream;
  }
}
