// lib/screens/ai_chat_screen.dart
import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});
  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _controller = TextEditingController();
  final _ai = AIService();
  final List<Map<String, String>> _messages = [
    {"role": "assistant", "content": "Сәлем! Мен сенің Python тьюторыңмын. Код жазуда қандай сұрағың бар?"}
  ];
  bool _isLoading = false;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    final userMsg = _controller.text;
    _controller.clear();
    
    setState(() {
      _messages.add({"role": "user", "content": userMsg});
      _isLoading = true;
    });

    final response = await _ai.sendMessage(userMsg);
    
    setState(() {
      _messages.add({"role": "assistant", "content": response ?? "Жауап алу мүмкін болмады."});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Python AI Тьютор")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                bool isUser = _messages[i]["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.amber : Colors.white10,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(_messages[i]["content"]!, style: TextStyle(color: isUser ? Colors.black : Colors.white)),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(color: Colors.amber),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Сұрақ қойыңыз...", border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                FloatingActionButton.small(onPressed: _sendMessage, backgroundColor: Colors.amber, child: const Icon(Icons.send, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}