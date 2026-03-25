// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'auth_screen.dart'; // globalCurrentUser үшін

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    
    return Scaffold(
      appBar: AppBar(title: const Text("Жеке кабинет")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 60, backgroundColor: Colors.amber, child: Icon(Icons.person, size: 60, color: Colors.black)),
              const SizedBox(height: 25),
              Text("@${globalCurrentUser!.login}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              // Статистика
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBox("Прогресс", "${globalCurrentUser!.progress}/10", Icons.trending_up),
                  _buildStatBox("XP Ұпай", "${globalCurrentUser!.xp}", Icons.star),
                ],
              ),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 55), 
                  backgroundColor: Colors.redAccent, 
                  foregroundColor: Colors.white
                ),
                onPressed: () async {
                  await storage.clearUser(); // Жадты тазалау
                  globalCurrentUser = null;
                  if(context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
                }, 
                icon: const Icon(Icons.logout),
                label: const Text("ЖҮЙЕДЕН ШЫҒУ", style: TextStyle(fontWeight: FontWeight.bold))
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Icon(icon, color: Colors.amber, size: 30),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}