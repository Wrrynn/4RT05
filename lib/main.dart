//import 'package:artos/pages/homePage.dart';
import 'package:artos/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:artos/pages/topup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xszsnzmwltkoyfxrobgn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzenNuem13bHRrb3lmeHJvYmduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4ODkzNjQsImV4cCI6MjA3NzQ2NTM2NH0.m0Y9-Qs1DoNJdMf-TjSyQq8E5Z9RmkkXK_ycrPCtNt8',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      
      initialRoute: '/login',

      routes: {
        '/login':(context) => const Login(),
        //'/home': (context) => const Homepage(),
        '/topup': (context) => const TopUpPage()
      },
    );
  }
}
