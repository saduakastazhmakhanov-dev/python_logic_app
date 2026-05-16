import 'package:flutter/material.dart';
import 'dart:async';
import '../services/compiler_service.dart'; // ЖАҢАРТЫЛДЫ: Жаңа компилятор
import '../services/ai_service.dart';       // ЖАҢАРТЫЛДЫ: Gemini ИИ қызметі
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
  
  // ЖАҢАРТЫЛДЫ: Жаңа қызметтерді шақыру
  final _compilerService = CompilerService();
  final _aiTutorService = AiTutorService();

  List<String> _savedCodes = [];
  Timer? _draftSaveDebounce;

  @override
  void initState() {
    super.initState();
    _loadInitialStateForCurrentUser();
    _codeController.addListener(_onCodeChanged);
  }

  Future<void> _loadInitialStateForCurrentUser() async {
    if (globalCurrentUser == null) return;

    final loadedSaved = await _storage.loadSavedCodes();
    final draft = await _storage.loadCompilerDraft();
    
    if (!mounted) return;
    
    setState(() {
      _savedCodes = List<String>.from(loadedSaved);
      
      if (draft['code'] != null && draft['code']!.isNotEmpty) {
        _codeController.text = draft['code']!;
      }
      _output = draft['output'] ?? "Нәтиже осында шығады...";
    });
    
    // Ескі Pyodide баптаулары бұл жерден толық алынып тасталды
  }

  @override
  void dispose() {
    _draftSaveDebounce?.cancel();
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    _draftSaveDebounce?.cancel();
    _draftSaveDebounce = Timer(const Duration(milliseconds: 900), () async {
      if (!mounted || globalCurrentUser == null || _isRunning) return;
      
      await _storage.saveCompilerDraft({
        'code': _codeController.text,
        'output': _output,
      });
    });
  }

  String _shortPreview(String code) {
    final oneLine = code.replaceAll('\n', ' ').trim();
    if (oneLine.length <= 40) return oneLine;
    return '${oneLine.substring(0, 40)}...';
  }

  Future<void> _saveCurrentScript() async {
    if (globalCurrentUser == null) return;

    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      if (!_savedCodes.contains(code)) {
        _savedCodes.add(code);
      }
    });

    await _storage.saveSavedCodes(_savedCodes);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Скрипт сақталды!")),
    );

    await _storage.saveCompilerDraft({
      'code': _codeController.text,
      'output': _output,
    });
  }

  // ЖАҢАРТЫЛДЫ: Жаңа компилятор мен ИИ логикасы бар функция
  void _runCode() async {
    setState(() {
      _isRunning = true;
      _output = "Код орындалуда...";
    });

    try {
      // 1. Кодты Piston API арқылы іске қосу
      final result = await _compilerService.executePythonCode(_codeController.text);
      
      if (!mounted) return;
      
      setState(() {
        _output = result;
      });

      // 2. Егер кодта логикалық/синтаксистік қате болса, ИИ көмегін қосамыз
      if (result.contains("Error") || result.contains("Exception") || result.contains("line")) {
        setState(() {
          _output += "\n\n🤖 [ИИ Тьютор жүктелуде...]";
        });

        final aiHint = await _aiTutorService.getAiHint(_codeController.text, result);
        
        if (!mounted) return;
        setState(() {
          _output += "\n\n🤖 ИИ Тьютор кеңесі:\n$aiHint";
        });
      }

      setState(() {
        _isRunning = false;
      });

      await _storage.saveCompilerDraft({
        'code': _codeController.text,
        'output': _output,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _output = "Байланыс немесе жүйелік қате: $e";
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Python Компилятор"),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Код редакторы
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _codeController,
                maxLines: null,
                style: const TextStyle(
                  fontFamily: 'monospace', 
                  fontSize: 15, 
                  color: Colors.greenAccent
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none, 
                  hintText: "Python кодын осында жазыңыз...",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
            ),
          ),
          
          // Басқару түймелері
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isRunning ? null : _runCode,
                    icon: _isRunning 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.play_arrow),
                    label: const Text("ІСКЕ ҚОСУ"),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _saveCurrentScript,
                  icon: const Icon(Icons.bookmark_add, color: Colors.amber),
                  tooltip: "Сақтау",
                ),
              ],
            ),
          ),

          // Сақталған кодтар тізімі
          if (_savedCodes.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _savedCodes.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      backgroundColor: Colors.white10,
                      label: Text(_shortPreview(_savedCodes[i]), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      onPressed: () => setState(() => _codeController.text = _savedCodes[i]),
                    ),
                  );
                },
              ),
            ),

          // Нәтиже шығару (Терминал)
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withAlpha(76)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _output, 
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}