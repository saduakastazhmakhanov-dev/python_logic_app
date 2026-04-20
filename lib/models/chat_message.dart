class Message {
  final String role;
  final String text;
  final DateTime time;

  Message({
    required this.role,
    required this.text,
    required this.time,
  });

  // Деректерді сақтау үшін Map-қа айналдыру (toMap)
  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'text': text,
      'time': time.toIso8601String(), // Уақытты мәтін ретінде сақтаймыз
    };
  }

  // Сақталған Map-ты қайтадан модельге айналдыру (fromMap)
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      role: map['role'] ?? 'ai',
      text: map['text'] ?? '',
      time: DateTime.parse(map['time'] ?? DateTime.now().toIso8601String()),
    );
  }
}