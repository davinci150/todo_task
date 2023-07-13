import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

import '../services/context_provider.dart';

@Singleton(as: RouterI)
class Router implements RouterI {
  Router();

  @override
  Future<dynamic> navigateTo(String routeName, {Object? arg}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arg);
  }

  @override
  Future<dynamic> navigateReplacementTo(String routeName, {dynamic? arg}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arg);
  }

  @override
  Future<dynamic> pushNamedAndRemoveUntil(String routeName, {dynamic? arg}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
        routeName, ModalRoute.withName('home_page'),
        arguments: arg);
  }

  @override
  void pop<T extends Object>([T? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  @override
  bool canPop() {
    return navigatorKey.currentState!.canPop();
  }
}

abstract class RouterI {
  static const String signIn = 'signIn';
  static const String signUp = 'signUp';
  static const String homePage = 'homePage';

  static const String tasksPage = 'tasksPage';
  static const String birthdays = 'birthdays';
  static const String settings = 'settings';

  Future<dynamic> navigateTo(String routeName, {Object? arg});

  Future<dynamic> navigateReplacementTo(String routeName, {dynamic? arg});

  Future<dynamic> pushNamedAndRemoveUntil(String routeName, {dynamic? arg});

  void pop<T extends Object>([T? result]);

  bool canPop();
}

class RouteModel {
  RouteModel({required this.routeName, this.arguments});

  final String routeName;
  final Object? arguments;
}
