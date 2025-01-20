import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/bloc/api_bloc.dart';
import 'package:Gamify/bloc/character_bloc.dart';
import 'package:Gamify/bloc/leaderboard_bloc.dart';
import 'package:Gamify/bloc/milestone_bloc.dart';
import 'package:Gamify/bloc/task_bloc.dart';
import 'package:Gamify/bloc/user_model_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/bloc/quest_model_bloc.dart';
import 'package:Gamify/pages/login.dart';
import 'package:Gamify/ui_elements/themes.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Initialize the FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Firebase messaging background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Show notification in the background
  _showNotification(message);
}

Future<void> _showNotification(RemoteMessage message) async {
  print('Showing notification...');
  print('Title: ${message.notification?.title}, Body: ${message.notification?.body}');

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'your_channel_id', // Channel ID
    'your_channel_name', // Channel name
    channelDescription: 'Your notification channel description',
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

  // Show notification
  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title, // Notification title
    message.notification?.body, // Notification body
    notificationDetails, // Notification details (channel)
    payload: message.data.toString(), // Optional payload
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Flutter Local Notifications plugin
  const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Initialize FCM (Firebase Cloud Messaging)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permission for notifications
  await FirebaseMessaging.instance.requestPermission();

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      _showNotification(message);  // Show notification when the app is in the foreground
    }
  });

  // Handle when the app is opened via a notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Opened app via notification: ${message.data}');
  });

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserModelBloc>(
          create: (context) => UserModelBloc(),
        ),
        BlocProvider<ApiBloc>(
          create: (context) => ApiBloc(apiRepository: ApiRepository()),
        ),
        BlocProvider<QuestModelBloc>(
            create: (context) => QuestModelBloc()
        ),
        BlocProvider<MilestoneBloc>(
            create: (context) => MilestoneBloc()
        ),
        BlocProvider<TaskBloc>(
            create: (context) => TaskBloc()
        ),
        BlocProvider<CharacterBloc>(
            create: (context) => CharacterBloc()
        ),
        BlocProvider<LeaderboardBloc>(
            create: (context) => LeaderboardBloc()
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gamify',
      theme: mytheme,
      home: const LoginPage(),
      navigatorObservers: [routeObserver],
    );
  }
}