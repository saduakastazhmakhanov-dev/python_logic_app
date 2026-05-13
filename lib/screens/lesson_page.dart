import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; //
import '../models/lesson_model.dart';
import 'quiz_page.dart';

class LessonPage extends StatelessWidget {
  final Lesson lesson;
  const LessonPage({super.key, required this.lesson});

  // Ссылканы ашу функциясы
  Future<void> _launchVideo(BuildContext context) async {
    final Uri url = Uri.parse(lesson.videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Бейнебаянды ашу мүмкін болмады")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Қара фон
      appBar: AppBar(title: Text(lesson.title), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Теория", style: TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.amber),
            Expanded(
              child: SingleChildScrollView(
                child: Text(lesson.theory, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.6)),
              ),
            ),
            const SizedBox(height: 20),

            // Егер videoUrl бос болмаса, батырма шығады
            if (lesson.videoUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Ютуб түсі
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => _launchVideo(context),
                  icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                  label: const Text("БЕЙНЕБАЯНДЫ КӨРУ", style: TextStyle(color: Colors.white)),
                ),
              ),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => QuizPage(lesson: lesson))),
              icon: const Icon(Icons.quiz, color: Colors.black),
              label: const Text("ТЕСТТЕН ӨТУ", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}