import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final double? width;
  final double? height; // ✅ Ubah jadi opsional (nullable)
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Gradient? gradient;
  final Color? borderColor;

  const GlassContainer({
    super.key,
    this.width,
    this.height, // ✅ Hapus kata 'required'
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding = const EdgeInsets.all(0),
    this.margin = const EdgeInsets.all(0),
    this.gradient,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            width: width,
            height: height, // ✅ Jika null, tinggi akan otomatis mengikuti isi
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: gradient ??
                  LinearGradient(
                    colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.08)],
                  ),
              border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}