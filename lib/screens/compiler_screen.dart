// lib/screens/compiler_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/pyodide_service.dart';
import '../services/storage_service.dart';
import 'auth_screen.dart'; // globalCurrentUser

class CompilerScreen extends StatefulWidget {
  const CompilerScreen({super.key});
  @override
  State<CompilerScreen> createState() => _CompilerScreenState();
}

class _CompilerScreenState extends State<CompilerScreen> {
  final _codeController = TextEditingController(text: "print('Сәлем, Python Logic!')");
  String _output = "Нәтиже осында шығады...";
  bool _isRunning = false;
  final _storage = StorageService();
  final _pyodide = PyodideService();

  List<String> _savedCodes = const [];
  Timer? _draftSaveDebounce;

  @override
  void initState() {
    super.initState();
    _loadInitialStateForCurrentUser();
    _codeController.addListener(_onCodeChanged);
  }

  Future<void> _loadInitialStateForCurrentUser() async {
    final user = globalCurrentUser;
    if (user == null) return;

    final loadedSaved = await _storage.loadSavedCodes(user.login);
    final draft = await _storage.loadCompilerDraft(user.login);
    if (!mounted) return;
    setState(() {
      _savedCodes = loadedSaved;
      if (draft['code'] != null && draft['code']!.isNotEmpty) {
        _codeController.text = draft['code']!;
      }
      _output = draft['output'] ?? _output;
    });

    // Подготовим pyodide заранее (чтобы на 1-м запуске не было долгого ожидания).
    // Если провалится — всё равно сможем показать ошибку при запуске.
    unawaited(_pyodide.ensureInitialized().catchError((_) {}));
  }

  @override
  void dispose() {
    _draftSaveDebounce?.cancel();
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    // Дебаунс: сохраняем черновик, когда пользователь перестал печатать.
    _draftSaveDebounce?.cancel();
    _draftSaveDebounce = Timer(const Duration(milliseconds: 900), () async {
      if (!mounted) return;
      final user = globalCurrentUser;
      if (user == null) return;
      if (_isRunning) return; // не трогаем во время выполнения
      await _storage.saveCompilerDraft(
        login: user.login,
        code: _codeController.text,
        output: _output,
      );
    });
  }

  String _shortPreview(String code) {
    final oneLine = code.replaceAll('\n', ' ').trim();
    if (oneLine.length <= 48) return oneLine;
    return '${oneLine.substring(0, 48)}...';
  }

  Future<void> _saveCurrentScript() async {
    final user = globalCurrentUser;
    if (user == null) return;

    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final updated = List<String>.from(_savedCodes)..add(code);
    setState(() {
      _savedCodes = updated;
    });

    await _storage.saveSavedCodes(user.login, _savedCodes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Скрипт сохранен")),
    );

    // Также обновим draft на случай, если пользователь сохранил версию.
    await _storage.saveCompilerDraft(
      login: user.login,
      code: _codeController.text,
      output: _output,
    );
  }

  void _runCode() async {
    setState(() {
      _isRunning = true;
      _output = "Код орындалуда...";
    });

    final user = globalCurrentUser;
    try {
      final result = await _pyodide.runPython(_codeController.text);
      if (!mounted) return;
      setState(() {
        _output = result.trim().isNotEmpty ? result : "Нәтиже жоқ";
        _isRunning = false;
      });

      if (user != null) {
        await _storage.saveCompilerDraft(
          login: user.login,
          code: _codeController.text,
          output: _output,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _output = "Ошибка Python: $e";
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Python Компилятор")),
      body: Column(
        children: [
          // Код редакторы
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: const Color(0xFF1E1E1E),
              child: TextField(
                controller: _codeController,
                maxLines: null,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.greenAccent),
                decoration: const InputDecoration(border: InputBorder.none, hintText: "Python кодын осында жазыңыз..."),
              ),
            ),
          ),
          // Басқару панелі
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _isRunning ? null : _runCode,
                    icon: _isRunning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.play_arrow),
                    label: const Text(
                      "КОДТЫ ІСКЕ ҚОСУ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveCurrentScript,
                    icon: const Icon(Icons.save),
                    label: const Text(
                      "Сохранить скрипт",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 170,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.black87,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Сохраненные скрипты",
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _savedCodes.isEmpty
                        ? const Center(
                            child: Text(
                              "Пока нет сохраненных скриптов",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _savedCodes.length,
                            itemBuilder: (context, i) {
                              final code = _savedCodes[i];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  _shortPreview(code),
                                  style: const TextStyle(color: Colors.white70),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                leading: const Icon(Icons.code, color: Colors.amber),
                                onTap: () {
                                  setState(() {
                                    _codeController.text = code;
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Нәтиже шығару аймағы
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              color: Colors.black87,
              child: SingleChildScrollView(
                child: Text(_output, style: const TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.white70)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}