import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/bloc/api_bloc.dart';
import 'package:Gamify/bloc/character_bloc.dart';
import 'package:Gamify/bloc/leaderboard_bloc.dart';
import 'package:Gamify/bloc/milestone_bloc.dart';
import 'package:Gamify/bloc/task_bloc.dart';
import 'package:Gamify/bloc/user_model_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/bloc/quest_model_bloc.dart';
import 'package:Gamify/pages/login.dart';
import 'package:Gamify/ui_elements/themes.dart';
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
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
