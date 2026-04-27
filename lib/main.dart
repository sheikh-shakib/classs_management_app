import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/schedule_provider.dart';
import 'screens/login_screen.dart';
import 'screens/schedule_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // initialize auth provider and check session
  final authProvider = AuthProvider();
  //await authProvider.checkLoginStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Classroom Manager',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      // auto-navigate based on login state
      home: context.watch<AuthProvider>().user != null 
          ? const ScheduleScreen() 
          : const LoginScreen(),
    );
  }
}