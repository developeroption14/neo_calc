import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'calculator_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1800), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => const CalculatorScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C5CFF), Color(0xFF4DA6FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C5CFF).withOpacity(0.5),
                    blurRadius: 50,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text('∑',
                    style: TextStyle(
                        fontSize: 56,
                        color: Colors.white,
                        fontWeight: FontWeight.w300)),
              ),
            )
                .animate()
                .scale(
                    duration: 900.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.2, 0.2))
                .fadeIn(duration: 500.ms),
            const SizedBox(height: 32),
            const Text(
              'NEO CALC',
              style: TextStyle(
                fontSize: 22,
                letterSpacing: 8,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 700.ms)
                .slideY(begin: 0.4, end: 0, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}