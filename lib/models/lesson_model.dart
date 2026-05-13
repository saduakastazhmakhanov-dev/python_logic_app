class Lesson {
  final int id;
  final String title;
  final String theory;
  final String videoUrl; 
  final List<QuizQuestion> quiz;

  Lesson({
    required this.id, 
    required this.title, 
    required this.theory, 
    required this.videoUrl,
    required this.quiz,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? 0,
      title: map['title'] ?? "",
      theory: map['theory'] ?? "",
      videoUrl: map['videoUrl'] ?? "", 
      quiz: (map['quiz'] as List?)?.map((q) => QuizQuestion.fromMap(q)).toList() ?? [],
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
    required this.description,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] ?? map['q'] ?? "",
      answers: List<String>.from(map['answers'] ?? map['a'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? map['c'] ?? 0,
      description: map['description'] ?? map['desc'] ?? "",
    );
  }
}