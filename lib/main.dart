import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:task_manager_app/screens/home_screen.dart';
import "firebase_options.dart";
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: "Task Manager",

      initialRoute: "/signup",

      routes: {
        "/signup": (context) => const SignUpScreen(),
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const HomeScreen(),
      },

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}





