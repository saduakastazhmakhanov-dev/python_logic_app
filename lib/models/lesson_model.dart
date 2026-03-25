// lib/models/lesson_model.dart
class Lesson {
  final int id;
  final String title;
  final String theory;
  final List<QuizQuestion> quiz;

  Lesson({
    required this.id, 
    required this.title, 
    required this.theory, 
    required this.quiz
  });

  // JSON-нан объект жасау (болашақта пайдалы болуы мүмкін)
  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      title: map['title'],
      theory: map['theory'],
      quiz: (map['quiz'] as List).map((q) => QuizQuestion.fromMap(q)).toList(),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> answers;
  final int correctAnswerIndex;
  final String description;

  QuizQuestion({
    required this.question, 
    required this.answers, 
    required this.correctAnswerIndex, 
    required this.description
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['q'],
      answers: List<String>.from(map['a']),
      correctAnswerIndex: map['c'],
      description: map['desc'],
    );
  }
}