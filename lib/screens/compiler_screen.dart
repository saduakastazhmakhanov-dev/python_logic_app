// lib/screens/compiler_screen.dart
import 'package:flutter/material.dart';
import '../services/compiler_service.dart';

class CompilerScreen extends StatefulWidget {
  const CompilerScreen({super.key});
  @override
  State<CompilerScreen> createState() => _CompilerScreenState();
}

class _CompilerScreenState extends State<CompilerScreen> {
  final _codeController = TextEditingController(text: "print('Сәлем, Python Logic!')");
  String _output = "Нәтиже осында шығады...";
  bool _isRunning = false;
  final _compiler = CompilerService();

  void _runCode() async {
    setState(() {
      _isRunning = true;
      _output = "Код орындалуда...";
    });

    final result = await _compiler.executePythonCode(_codeController.text);
    
    setState(() {
      _output = result;
      _isRunning = false;
    });
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
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              onPressed: _isRunning ? null : _runCode,
              icon: _isRunning 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
                : const Icon(Icons.play_arrow),
              label: const Text("КОДТЫ ІСКЕ ҚОСУ", style: TextStyle(fontWeight: FontWeight.bold)),
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