import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CustomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: widget.selectedIndex,
      height: 75,
      backgroundColor: Colors.transparent,
      color: const Color(0xFF3B0078), // warna dasar ungu gelap
      buttonBackgroundColor: const Color(0xFFE2399E), // tombol aktif (pink)
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      items: const <Widget>[
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.group, size: 30, color: Colors.white),
        Icon(Icons.qr_code_2, size: 30, color: Colors.white),
        Icon(Icons.receipt_long, size: 30, color: Colors.white),
      ],
      onTap: (index) => widget.onItemTapped(index),
    );
  }
}
