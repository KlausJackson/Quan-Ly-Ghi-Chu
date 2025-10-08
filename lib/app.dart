import 'package:flutter/material.dart';
import 'package:notes/core/routing/app_go_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Nodes App",
      debugShowCheckedModeBanner: false,
      routerConfig: AppGoRouter.router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF252525)),
        scaffoldBackgroundColor: Color(0xFF252525),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF252525), brightness: Brightness.dark),
        scaffoldBackgroundColor: Color(0xFF252525),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
    );
  }
}