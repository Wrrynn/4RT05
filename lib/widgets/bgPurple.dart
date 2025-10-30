import 'package:flutter/material.dart';

class BackgroundApp extends StatelessWidget {
  final Widget child;
  const BackgroundApp({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors:[
            Color(0xFF07000C),
            Color(0xFF290F52),
            Color(0xFF07000C),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
        ),
      ),
      child: child,
    );

  }
}