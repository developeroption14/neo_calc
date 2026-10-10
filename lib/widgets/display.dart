import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Display extends StatelessWidget {
  final String input;
  final String result;
  final Color accent;
  final VoidCallback onTap;

  const Display({
    super.key,
    required this.input,
    required this.result,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                input.isEmpty ? '0' : input,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.45),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                result,
                style: TextStyle(
                  fontSize: 68,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -1,
                  shadows: [
                    Shadow(
                      color: accent.withOpacity(0.4),
                      blurRadius: 24,
                    ),
                  ],
                ),
              )
                  .animate(key: ValueKey(result))
                  .fadeIn(duration: 180.ms)
                  .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
            ),
          ],
        ),
      ),
    );
  }
}