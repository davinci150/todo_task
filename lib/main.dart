import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'auth/sign_in_page.dart';
import 'auth/sign_up_page.dart';
import 'core/di/service_locator.dart';
import 'core/fcm.dart';
import 'dao/tasks_dao.dart';
import 'firebase/firebase_options.dart';
import 'home/home_page.dart';
import 'providers/theme_provider.dart';
import 'router/router_generator.dart';
import 'services/context_provider.dart';
import 'services/notification_service.dart';

/* @pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService().singleNotification(Random().nextInt(10 * 100),
      message.notification?.title ?? '', message.notification?.body ?? '');

  print('Handling a background message: ${message.messageId}');
}
 */
Future<void> main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const WindowOptions windowOptions = WindowOptions(
      minimumSize: Size(400, 500),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  configureDependencies();

  await GetIt.I<TasksDao>().initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await registerNotification();

  final mediaQueryData =
      MediaQueryData.fromWindow(WidgetsBinding.instance.window);

  if (Platform.isAndroid || Platform.isIOS) {
    isDesktop = mediaQueryData.size.shortestSide > 600;
  } else {
    isDesktop = true;
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<ModelTheme>(create: (_) => ModelTheme()),
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
  User? currentUser;

  @override
  void initState() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      currentUser = user;
    }

    FirebaseAuth.instance
        .authStateChanges()
        .distinct((previous, next) => previous?.email == next?.email)
        .listen((event) {
      currentUser = event;
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO task',
      theme: ThemeData(
        fontFamily: 'Rubik-Regular',
      ),
      debugShowCheckedModeBanner: false,
      home: Navigator(
        key: navigatorKey,
        onGenerateRoute: RouteGenerator.generateRoute,
        onPopPage: (route, dynamic result) => route.didPop(result),
        pages: [
          if (Platform.isMacOS || currentUser != null)
            homePage()
          else
            signInPage()
        ],
      ),
    );
  }
}

late bool isDesktop;
