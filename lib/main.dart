import 'package:flutter/material.dart';
import 'package:work_manager/screens/login/login_screen.dart';

void main() {
  runApp(const WorkManagerApp());
}

class WorkManagerApp extends StatelessWidget {
  const WorkManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkManager',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}