import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';

import '../main.dart';
import '../model/user_model.dart';
import '../router/router_generator.dart';
import '../services/context_provider.dart';
import 'sidebar/sidebar.dart';
import 'sidebar/sidebar_widget_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

const taskKey = kDebugMode ? 'testKeyV1' : 'taskKeyV2';
const selectedGroupKey = kDebugMode ? 'selectedGroupV1' : 'selectedGroupV1';
final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

class _MyHomePageState extends State<HomePage> {
  late final SidebarWidgetModel sidebarWidgetModel;

  @override
  void initState() {
    sidebarWidgetModel = SidebarWidgetModel();
    super.initState();
  }

  @override
  void dispose() {
    sidebarWidgetModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SidebarWidgetModel>(
      create: (context) => sidebarWidgetModel,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: drawerKey,
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
      ),
    );
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
