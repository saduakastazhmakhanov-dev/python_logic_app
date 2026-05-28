import 'package:flutter/material.dart';
import 'dart:async';
import 'package:python_logic_app/services/ai_service.dart';
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
 final AiTutorService aiService = AiTutorService();
  final _storage = StorageService();
  final _scrollController = ScrollController();
  
  // Бастапқы хабарлама
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

  // ТҮЗЕЛГЕН: Чат тарихын жүктеу
  Future<void> _loadHistoryForCurrentUser() async {
    if (globalCurrentUser == null) return;

    // StorageService-тен List<dynamic> аламыз
    final List<dynamic> loadedRaw = await _storage.loadChatHistory();
    
    if (!mounted) return;

    if (loadedRaw.isNotEmpty) {
      setState(() {
        _messages.clear();
        // dynamic деректерді Message моделіне айналдырамыз
        for (var item in loadedRaw) {
          _messages.add(Message.fromMap(item));
        }
      });
    }
  }

  // ТҮЗЕЛГЕН: Хабарлама жіберу
 // ТҮЗЕЛГЕН: Хабарлама жіберу
  void _sendMessage() async {
    if (_isLoading) return;
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

    try {
      if (globalCurrentUser != null) {
        await _storage.saveChatHistory(_messages.map((e) => e.toMap()).toList());
      }

      final response = await aiService
          .sendChatMessage(userMsg)
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      setState(() {
        _messages.add(Message(
          role: 'ai',
          text: response,
          time: DateTime.now(),
        ));
      });

      if (_scrollController.hasClients) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }

      if (globalCurrentUser != null) {
        await _storage.saveChatHistory(_messages.map((e) => e.toMap()).toList());
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _messages.add(Message(
          role: 'ai',
          text: 'Қате: ИИ 30 секунд ішінде жауап қайтармады. '
              'Интернет/блоктау/CORS болуы мүмкін. Қайта көріңіз.',
          time: DateTime.now(),
        ));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(Message(
          role: 'ai',
          text: 'Қате: $e',
          time: DateTime.now(),
        ));
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Дизайнды сәл жақсарту
      appBar: AppBar(
        title: const Text("Python AI Тьютор"),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final isUser = _messages[i].role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.amber : Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          _messages[i].text,
                          style: TextStyle(
                            color: isUser ? Colors.black : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_messages[i].time.hour.toString().padLeft(2, '0')}:${_messages[i].time.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 10,
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
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.black26,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Сұрақ қойыңыз...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  }