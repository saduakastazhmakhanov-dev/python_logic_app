// lib/screens/lesson_page.dart
import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import 'quiz_page.dart';

class LessonPage extends StatelessWidget {
  final Lesson lesson;
  const LessonPage({super.key, required this.lesson});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.library_books, color: Colors.amber),
                SizedBox(width: 10),
                Text("Теория", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
            const Divider(color: Colors.amber, height: 25),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  lesson.theory, 
                  style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.white70)
                )
              )
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60), 
                backgroundColor: Colors.amber, 
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => QuizPage(lesson: lesson))), 
              icon: const Icon(Icons.quiz),
              label: const Text("ТЕСТТЕН ӨТУ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            ),
          ],
        ),
      ),
    );
  }
}