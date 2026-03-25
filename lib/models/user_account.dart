// lib/models/user_account.dart
class UserAccount {
  String login;
  String password;
  int progress; 
  int xp;

  UserAccount({
    required this.login, 
    required this.password, 
    this.progress = 1, 
    this.xp = 0
  });
}