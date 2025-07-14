import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SnowLoader extends StatelessWidget {
  const SnowLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/snowloaderbgless.json',
        width: 120,        // resize here
        height: 120,
        repeat: true,      // loops forever
      ),
    );
  }
}

