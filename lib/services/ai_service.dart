import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
 
class AiTutorService {
  static const String _apiKey = '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'; // Мұнда өз кілтіңізді қойыңыз
  static const String _modelName = 'gpt-4o-mini';
  static final Uri _chatUrl =
      Uri.parse('https://api.openai.com/v1/chat/completions');
 
  Future<String> sendChatMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) {
      return 'Сұрақ бос болмауы керек.';
    }
 
    const systemPrompt = '''
Сен мектептегі Python бағдарламалау тьюторысың.
Оқушыға қазақ тілінде қысқа, түсінікті жауап бер.
Дайын кодты толығымен берме, тек логикалық бағыт-бағдар бер.
''';
 
    try {
      return await _sendRequest(
        systemPrompt: systemPrompt,
        userMessage: 'Оқушы сұрағы: $userMessage',
      );
    } catch (e, st) {
      debugPrint('OpenAI sendChatMessage error: $e');
      debugPrintStack(stackTrace: st);
      return _formatError(e);
    }
  }
 
  Future<String> getAiHint(String studentCode, String compilerOutput) async {
    const systemPrompt = '''
Сен мектептегі Python бағдарламалау логикасын үйрететін AI тьюторсың.
Оқушыға қазақ тілінде өте қарапайым, қысқа және түсінікті жауап бер.
Ешқашан дайын дұрыс кодты толық берме.
Тек қатенің себебін түсіндіріп, оқушы өзі түзетуі үшін логикалық бағыт-бағдар бер.
''';
 
    final userMessage = '''
Оқушы мына Python кодын жазды:
$studentCode
 
Компилятордың қайтарған нәтижесі немесе қатесі:
$compilerOutput
''';
 
    try {
      return await _sendRequest(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
      );
    } catch (e, st) {
      debugPrint('OpenAI getAiHint error: $e');
      debugPrintStack(stackTrace: st);
      return _formatError(e);
    }
  }
 
  Future<String> _sendRequest({
    required String systemPrompt,
    required String userMessage,
  }) async {
    final response = await http
        .post(
          _chatUrl,
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _modelName,
            'max_tokens': 450,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userMessage},
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));
 
    final data = jsonDecode(response.body) as Map<String, dynamic>;
 
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        throw OpenAiApiException(
          error['message']?.toString() ?? response.body,
          statusCode: response.statusCode,
          type: error['type']?.toString(),
          code: error['code']?.toString(),
        );
      }
      throw OpenAiApiException(response.body, statusCode: response.statusCode);
    }
 
    return _extractText(data);
  }
 
  String _extractText(Map<String, dynamic> data) {
    final choices = data['choices'] as List?;
    if (choices != null && choices.isNotEmpty) {
      final message = choices[0]['message'] as Map<String, dynamic>?;
      final content = message?['content']?.toString().trim() ?? '';
      if (content.isNotEmpty) return content;
    }
    return 'OpenAI бос жауап қайтарды.';
  }
 
  String _formatError(Object error) {
    if (error is OpenAiApiException) {
      return 'OpenAI қатесі: ${error.message}';
    }
    return 'OpenAI-ға қосылу кезінде қате: $error';
  }
}
 
class OpenAiApiException implements Exception {
  OpenAiApiException(
    this.message, {
    required this.statusCode,
    this.type,
    this.code,
  });
 
  final String message;
  final int statusCode;
  final String? type;
  final String? code;
 
  @override
  String toString() => message;
}
