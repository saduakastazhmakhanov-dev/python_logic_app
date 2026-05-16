import 'package:flutter/material.dart';

class AppLogoPainter extends StatelessWidget {
  final double size;
  const AppLogoPainter({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF121212), // Қосымшаның негізгі қара түсі
        borderRadius: BorderRadius.circular(size * 0.22), // Дөңгеленген квадрат
        border: Border.all(color: const Color(0xFFFACC15), width: 2), // Сары жиек
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Артқы жағындағы стильді "ABC" әріптері (Ағылшын тілі символы)
            Text(
              'ABC',
              style: TextStyle(
                fontSize: size * 0.28,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.15),
                letterSpacing: 2,
              ),
            ),
            // Алдыңғы жағындағы Python стиліндегі ерекше белгі
            Icon(
              Icons.terminal_rounded, 
              size: size * 0.45,
              color: const Color(0xFFFACC15), // Сары түсті акцент
            ),
          ],
        ),
      ),
    );
  }
}