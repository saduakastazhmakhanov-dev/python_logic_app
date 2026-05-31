import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'pyodide_service.dart';

class CompilerService {
  final PyodideService _pyodideService;

  CompilerService({PyodideService? pyodideService})
      : _pyodideService = pyodideService ?? PyodideService();

  Future<String> executePythonCode(String code) async {
    if (code.trim().isEmpty) {
      return 'Код бос болмауы керек.';
    }

    if (kIsWeb) {
      return _pyodideService.runPython(code);
    }

    return _runWithPiston(code);
  }

  Future<String> _runWithPiston(String code) async {
    final url = Uri.parse('https://emkc.org/api/v2/piston/execute');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'language': 'python',
              'version': '3.10.0',
              'files': [
                {'content': code}
              ],
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return 'Сервер қатесі: ${response.statusCode}\n${response.body}';
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final run = data['run'] as Map<String, dynamic>?;
      final output = run?['output']?.toString() ?? '';
      return output.isEmpty ? 'Нәтиже жоқ' : output;
    } catch (e) {
      return 'Python кодын орындау мүмкін болмады: $e';
    }
  }
}
