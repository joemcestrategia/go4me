import 'package:flutter/material.dart';

// ignore: camel_case_types
class Go4MeLogo extends StatelessWidget {
  final double height;
  final bool useDark;

  const Go4MeLogo({super.key, this.height = 32, this.useDark = false});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      useDark ? 'assets/Logo_black.png' : 'assets/Logo_white.png',
      height: height,
      errorBuilder: (_, __, ___) => Text(
        'Go4Me',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: height * 0.55,
          color: useDark ? Colors.black : Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

// Backward-compat alias
typedef MissionAppLogo = Go4MeLogo;
