import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiTutorService {
  static const String _apiKey = String.fromEnvironment('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');
  static const String _modelName = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-5-mini',
  );
  static final Uri _responsesUrl =
      Uri.parse('https://api.openai.com/v1/responses');

  Future<String> sendChatMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) {
      return 'Сұрақ бос болмауы керек.';
    }

    final keyError = _validateApiKey();
    if (keyError != null) return keyError;

    const instructions = '''
Сен мектептегі Python бағдарламалау тьюторысың.
Оқушыға қазақ тілінде қысқа, түсінікті жауап бер.
Дайын кодты толығымен берме, тек логикалық бағыт-бағдар бер.
''';

    try {
      return await _createResponse(
        instructions: instructions,
        input: 'Оқушы сұрағы: $userMessage',
      );
    } catch (e, st) {
      debugPrint('OpenAI sendChatMessage error: $e');
      debugPrintStack(stackTrace: st);
      return _formatError(e);
    }
  }

  Future<String> getAiHint(String studentCode, String compilerOutput) async {
    final keyError = _validateApiKey();
    if (keyError != null) return keyError;

    const instructions = '''
Сен мектептегі ағылшын тілі мен Python бағдарламалау логикасын біріктіріп үйрететін AI тьюторсың.
Оқушыға қазақ тілінде өте қарапайым, қысқа және түсінікті жауап бер.
Ешқашан дайын дұрыс кодты толық берме.
Тек қатенің себебін түсіндіріп, оқушы өзі түзетуі үшін логикалық бағыт-бағдар бер.
''';

    final input = '''
Оқушы мына Python кодын жазды:
$studentCode

Компилятордың қайтарған нәтижесі немесе қатесі:
$compilerOutput
''';

    try {
      return await _createResponse(
        instructions: instructions,
        input: input,
      );
    } catch (e, st) {
      debugPrint('OpenAI getAiHint error: $e');
      debugPrintStack(stackTrace: st);
      return _formatError(e);
    }
  }

  Future<String> _createResponse({
    required String instructions,
    required String input,
  }) async {
    final response = await http
        .post(
          _responsesUrl,
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _modelName,
            'instructions': instructions,
            'input': input,
            'max_output_tokens': 450,
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

  String? _validateApiKey() {
    if (_apiKey.isEmpty) {
      return 'OpenAI API кілті орнатылмаған. Қосымшаны '
          '--dart-define=OPENAI_API_KEY=ЖАҢА_OPENAI_KEY арқылы іске қосыңыз.';
    }

    if (!_apiKey.startsWith('sk-')) {
      return 'OpenAI API кілті дұрыс емес сияқты. OpenAI API кілті әдетте sk- деп басталады.';
    }

    return null;
  }

  String _extractText(Map<String, dynamic> data) {
    final outputText = data['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }

    final output = data['output'];
    if (output is List) {
      final buffer = StringBuffer();
      for (final item in output) {
        if (item is! Map<String, dynamic>) continue;
        final content = item['content'];
        if (content is! List) continue;
        for (final part in content) {
          if (part is! Map<String, dynamic>) continue;
          final text = part['text'];
          if (text is String && text.trim().isNotEmpty) {
            if (buffer.isNotEmpty) buffer.writeln();
            buffer.write(text.trim());
          }
        }
      }
      if (buffer.isNotEmpty) return buffer.toString();
    }

    return 'OpenAI бос жауап қайтарды.';
  }

  String _formatError(Object error) {
    if (error is OpenAiApiException) {
      if (error.statusCode == 401 ||
          error.code == 'invalid_api_key' ||
          error.type == 'invalid_request_error') {
        return 'OpenAI API кілті жарамсыз немесе рұқсаты жоқ. OPENAI_API_KEY мәнін тексеріңіз.';
      }
      if (error.statusCode == 429 ||
          error.code == 'rate_limit_exceeded' ||
          error.code == 'insufficient_quota') {
        return 'OpenAI API лимиті аяқталды немесе баланс жеткіліксіз. Біраз күтіп, қайта көріңіз.';
      }
      if (error.statusCode == 404 || error.code == 'model_not_found') {
        return 'OpenAI моделі табылмады ($_modelName). OPENAI_MODEL мәнін тексеріңіз.';
      }
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

