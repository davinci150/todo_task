import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'api/auth_api.dart';
import 'auth/sign_in_page.dart';
import 'auth/sign_up_page.dart';
import 'core/di/service_locator.dart';
import 'core/fcm.dart';
import 'dao/tasks_dao.dart';
import 'firebase/firebase_options.dart';
import 'home/home_page.dart';
import 'home/sidebar/sidebar_widget_model.dart';
import 'model/user_model.dart';
import 'providers/theme_provider.dart';
import 'services/context_provider.dart';
import 'services/notification_service.dart';
import 'tasks_page/tasks_widget_model.dart';
import 'widgets/dialog/adaptive_dialog.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  /*  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyAEklKa9flkKnVKUQyz6uOcEVdzvjgPTd8',
          // appId: '1:668468006082:ios:2ff7f4830a135bcd79ff5b',
          appId: '1:668468006082:android:941183f42cb9661679ff5b',
          messagingSenderId: '668468006082',
          projectId: 'todo-dcf3a')); */
  await NotificationService().singleNotification(Random().nextInt(10 * 100),
      message.notification?.title ?? '', message.notification?.body ?? '');

  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();

  await GetIt.I<TasksDao>().initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!Platform.isMacOS) {
    await FirebaseMessaging.instance.subscribeToTopic('all');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await registerNotification();
  }

  final mediaQueryData =
      MediaQueryData.fromWindow(WidgetsBinding.instance.window);

  if (Platform.isAndroid || Platform.isIOS) {
    isDesktop = mediaQueryData.size.shortestSide > 600;
  } else {
    isDesktop = true;
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<ModelTheme>(create: (_) => ModelTheme()),
    ChangeNotifierProvider<TasksWidgetModel>(create: (_) => TasksWidgetModel()),
    ChangeNotifierProvider<SidebarWidgetModel>(
        create: (_) => SidebarWidgetModel()),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

MaterialPage<dynamic> homePage() => const MaterialPage<void>(child: HomePage());
MaterialPage<dynamic> signInPage() =>
    const MaterialPage<void>(child: SignInPage());
MaterialPage<dynamic> signUpPage() =>
    const MaterialPage<void>(child: SignUpPage());

class _MyAppState extends State<MyApp> {
  // late Page<dynamic> homeWidget;

  late String initRoute;
  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser == null) {
      initRoute = 'sign_in';
      /*  isAutorizated = false;
      homeWidget = signInPage(); */
    } else {
      initRoute = '/';
      /*   isAutorizated = true;
      homeWidget = homePage(); */
    }
    FirebaseAuth.instance
        .authStateChanges()
        .distinct((previous, next) => previous?.email == next?.email)
        .listen((event) {
      print('##### ${event?.email}');

      if (event == null) {
        // isAutorizated = false;

        initRoute = 'sign_in';
        Navigator.of(navigatorKeyStart.currentContext!)
            .pushNamedAndRemoveUntil('sign_in', (l) => false);

        // setState(() {});
        //  homeWidget = signInPage();
      } else {
        // isAutorizated = true;
        if (initRoute != '/') {
          initRoute = '/';
          Navigator.of(navigatorKeyStart.currentContext!)
              .pushNamedAndRemoveUntil('/', (l) => false);
        }

        //setState(() {});
        // homeWidget = homePage();
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final theme = context.watch<ModelTheme>();

    return MaterialApp(
      title: 'TODO task',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        fontFamily: 'Rubik-Regular',
      ),

      //theme: theme.isDark == true ? darkTheme : lightTheme,
      debugShowCheckedModeBanner: false,
      home: Navigator(
        initialRoute: initRoute,
        key: navigatorKeyStart,
        onGenerateRoute: (settings) {
          print('##### NAME; ${settings.name}');
          if (settings.name == 'sign_up') {
            return MaterialPageRoute<dynamic>(
                builder: (context) => const SignUpPage(), settings: settings);
          } else if (settings.name == 'sign_in') {
            return MaterialPageRoute<dynamic>(
                builder: (context) => const SignInPage(), settings: settings);
          } else {
            return MaterialPageRoute<dynamic>(
                builder: (context) => const HomePage(), settings: settings);
          }
        },
        onPopPage: (route, dynamic result) => route.didPop(result),
        //pages: [homeWidget],
      ),
    );
  }
}

late bool isDesktop;
