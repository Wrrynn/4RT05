import 'package:artos/pages/homePage.dart';
import 'package:artos/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:artos/pages/topup.dart';
import 'package:artos/pages/send.dart';
import 'package:artos/pages/payment.dart';
import 'package:artos/pages/scan.dart';
import 'package:artos/pages/moneyManagement.dart';
import 'package:artos/pages/moneyReport.dart';




void main() {
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
        '/home': (context) => const Homepage(),
        '/topup': (context) => const TopUpPage(),
        '/send' : (context) => const SendMoneyPage(),
        '/payment': (context) => const PaymentPage(),
        '/scan': (context) => const ScanQrPage(),
        '/moneyManagement': (context) => const ManajemenKeuanganPage(),
        '/moneyReport': (context) => const LaporanKeuanganPage(),
      },
    );
  }
}
