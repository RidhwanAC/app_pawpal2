import 'package:app_pawpal2/models/user.dart';
import 'package:app_pawpal2/views/sc_home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(
        user: User(name: 'User', userId: '4'),
      ),
    );
  }
}
