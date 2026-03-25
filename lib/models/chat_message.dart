import 'dart:convert';

class Message {
  final String role; // "user" / "ai"
  final String text;
  final DateTime time;

  const Message({
    required this.role,
    required this.text,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'text': text,
        // ISO 8601 удобен для отладки и стабилен при json сериализации.
        'time': time.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    final timeRaw = json['time'];
    final parsedTime = switch (timeRaw) {
      String s => DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0),
      int i => DateTime.fromMillisecondsSinceEpoch(i),
      _ => DateTime.fromMillisecondsSinceEpoch(0),
    };

    return Message(
      role: (json['role'] as String?) ?? 'ai',
      text: (json['text'] as String?) ?? '',
      time: parsedTime,
    );
  }

  @override
  String toString() => 'Message(role: $role, textLen: ${text.length}, time: $time)';
}

// Вспомогательные функции, чтобы не дублировать код преобразования списков.
List<Message> messagesFromJson(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const [];
  return decoded
      .whereType<Map<String, dynamic>>()
      .map(Message.fromJson)
      .toList(growable: false);
}

String messagesToJson(List<Message> messages) {
  final list = messages.map((m) => m.toJson()).toList(growable: false);
  return jsonEncode(list);
}

