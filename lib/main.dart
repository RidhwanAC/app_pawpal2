import 'dart:convert';
import 'package:app_pawpal2/config/app_theme.dart';
import 'package:app_pawpal2/models/user.dart';
import 'package:app_pawpal2/views/sc_auth.dart';
import 'package:app_pawpal2/views/sc_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userData = prefs.getString('user_data');
  Widget homeScreen = const AuthScreen();

  if (userData != null) {
    homeScreen = MainScreen(user: User.fromJson(jsonDecode(userData)));
  }

  runApp(MainApp(homeScreen: homeScreen));
}

class MainApp extends StatelessWidget {
  final Widget homeScreen;
  const MainApp({super.key, required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: homeScreen,
    );
  }
}
