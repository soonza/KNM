import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'authentication.dart'; // 로그인 화면 import
import 'constants.dart'; // sharedPreferences 초기화 관련 파일

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await initializeSharedPreferences();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping APP',
      home: const LoginScreen(), // 로그인 화면을 먼저 띄움
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    );
  }
}
