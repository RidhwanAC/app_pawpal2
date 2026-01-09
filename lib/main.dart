import 'package:app_pawpal2/views/sc_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF28C28),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF3E3),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF4A321F)),
          bodyMedium: TextStyle(color: Color(0xFF5C4633)),
          titleLarge: TextStyle(color: Color(0xFF4A321F)),
          titleMedium: TextStyle(color: Color(0xFF5C4633)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF28C28),
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Color(0xFF8B5E3B), width: 2),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFF8B5E3B), width: 1),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}
