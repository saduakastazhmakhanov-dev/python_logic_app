// lib/screens/quiz_page.dart
import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../services/storage_service.dart';
import 'auth_screen.dart'; // globalCurrentUser үшін

class QuizPage extends StatefulWidget {
  final Lesson lesson;
  const QuizPage({super.key, required this.lesson});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0; 
  int _score = 0; 
  bool _isAnswered = false; 
  int? _selectedAnswerIndex;
  final _storage = StorageService();

  void _nextQuestion() async {
    // Егер бұл соңғы сұрақ болса
    if (_currentQuestionIndex >= widget.lesson.quiz.length - 1) {
      
      // Прогресті сақтау логикасы
      if (_score >= 1 && globalCurrentUser!.progress == widget.lesson.id) { 
        globalCurrentUser!.progress++; 
      }
      globalCurrentUser!.xp += _score * 10;
      await _storage.saveUser(globalCurrentUser!);

      // Нәтиже диалогы
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              _score >= 1 ? "Керемет! 🎉" : "Талпыныс 😕", 
              style: TextStyle(
                color: _score >= 1 ? Colors.greenAccent : Colors.redAccent, 
                fontWeight: FontWeight.bold
              ),
            ),
            content: Text(
              "Нәтиже: $_score / ${widget.lesson.quiz.length}\nXP: +${_score * 10}",
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () { 
                  Navigator.pop(dialogContext); // Диалогты жабу
                  Navigator.pop(context);       // Сабақ бетін жабу
                  Navigator.pop(context);       // Тізімге қайту
                }, 
                child: const Text(
                  "МӘЗІРГЕ ҚАЙТУ", 
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                ),
              ),
            ], // <--- МЫНАУ КВАДРАТ ЖАҚША actions-ТІ ЖАБАДЫ
          ), // <--- МЫНАУ AlertDialog-ТЫ ЖАБАДЫ
        ); // <--- МЫНАУ showDialog-ТЫ ЖАБАДЫ
      }
    } else {
      // Келесі сұраққа өту
      setState(() { 
        _currentQuestionIndex++; 
        _isAnswered = false; 
        _selectedAnswerIndex = null; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.lesson.quiz[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(title: Text("Тест: ${widget.lesson.title}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.lesson.quiz.length,
              backgroundColor: Colors.white10,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            Text(question.question, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 30),
            // Жауап нұсқалары
            ...List.generate(question.answers.length, (index) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: _isAnswered 
                ? (index == question.correctAnswerIndex 
                    ? Colors.green.withValues(alpha: 0.4) 
                    : (index == _selectedAnswerIndex ? Colors.red.withValues(alpha: 0.4) : Colors.white10)) 
                : Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(question.answers[index], style: const TextStyle(fontSize: 18)),
                trailing: _isAnswered && index == question.correctAnswerIndex ? const Icon(Icons.check_circle, color: Colors.greenAccent) : null,
                onTap: _isAnswered ? null : () => setState(() { 
                  _selectedAnswerIndex = index; 
                  _isAnswered = true; 
                  if(index == question.correctAnswerIndex) _score++; 
                }),
              ),
            )),
            // Түсіндірме
            if (_isAnswered) Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
              child: Text(question.description, style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontStyle: FontStyle.italic)),
            ),
            const Spacer(),
            if (_isAnswered) ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), backgroundColor: Colors.amber),
              onPressed: _nextQuestion, 
              child: Text(_currentQuestionIndex >= widget.lesson.quiz.length - 1 ? "АЯҚТАУ" : "КЕЛЕСІ СҰРАҚ", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
            ),
          ],
        ),
      ),
    );
  }
}