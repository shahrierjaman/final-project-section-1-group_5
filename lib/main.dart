import 'package:expanse_calculation_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/add_expance.dart';
import 'screens/all_expanse.dart';
import 'screens/home.dart';
import 'screens/report.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/landingpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",

      home: LandingPage(),

      routes: {
        '/add': (context) => AddExpance(),
        '/all': (context) => AllExpanse(),
        '/report': (context) => Report(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/landing': (context) => LandingPage(),
      },
    );
  }
}
