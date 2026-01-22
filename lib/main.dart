import 'package:class_management_app/screens/login_screen.dart';
import 'package:class_management_app/screens/register_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "login",
      routes: {
        "login":(context)=>LoginScreen(),
        "register":(context)=>RegisterScreen(),
      },
    );
  }
}

