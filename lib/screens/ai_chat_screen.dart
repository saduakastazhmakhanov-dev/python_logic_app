// lib/screens/ai_chat_screen.dart
import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../models/chat_message.dart';
import 'auth_screen.dart'; // globalCurrentUser

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});
  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _controller = TextEditingController();
  final _ai = AIService();
  final _storage = StorageService();
  final List<Message> _messages = [
    Message(
      role: 'ai',
      text: 'Сәлем! Мен сенің Python тьюторыңмын. Код жазуда қандай сұрағың бар?',
      time: DateTime.now(),
    ),
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistoryForCurrentUser();
  }

  Future<void> _loadHistoryForCurrentUser() async {
    final user = globalCurrentUser;
    if (user == null) return;

    final loaded = await _storage.loadChatHistory(user.login);
    if (!mounted) return;

    if (loaded.isNotEmpty) {
      setState(() {
        _messages
          ..clear()
          ..addAll(loaded);
      });
    }
  }

  void _sendMessage() async {
    final login = globalCurrentUser?.login;
    if (login == null) return;

    final userMsg = _controller.text.trim();
    if (userMsg.isEmpty) return;
    _controller.clear();
    
    setState(() {
      _messages.add(Message(
        role: 'user',
        text: userMsg,
        time: DateTime.now(),
      ));
      _isLoading = true;
    });

    await _storage.saveChatHistory(login, _messages);
    if (!mounted) return;

    final response = await _ai.sendMessage(userMsg);
    
    if (!mounted) return;
    setState(() {
      _messages.add(Message(
        role: 'ai',
        text: response ?? 'Жауап алу мүмкін болмады.',
        time: DateTime.now(),
      ));
      _isLoading = false;
    });

    await _storage.saveChatHistory(login, _messages);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                final isUser = _messages[i].role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.amber : Colors.white10,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          _messages[i].text,
                          style: TextStyle(
                            color: isUser ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          // Формат: HH:mm (локальное время устройства)
                          '${_messages[i].time.hour.toString().padLeft(2, '0')}:${_messages[i].time.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isUser ? Colors.black54 : Colors.white54,
                          ),
                        ),
                      ],
                    ),
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