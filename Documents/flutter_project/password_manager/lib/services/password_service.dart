import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/password_item.dart';

class PasswordService {
  static const String _storageKey = 'password_vault';

  Future<List<PasswordItem>> loadPasswords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? passwordsJson = prefs.getString(_storageKey);
      
      if (passwordsJson == null) {
        return _getDefaultPasswords();
      }

      final List<dynamic> decoded = json.decode(passwordsJson);
      return decoded.map((item) => PasswordItem.fromJson(item)).toList();
    } catch (e) {
      print('Error loading passwords: $e');
      return _getDefaultPasswords();
    }
  }

  Future<void> savePasswords(List<PasswordItem> passwords) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        passwords.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      print('Error saving passwords: $e');
      rethrow;
    }
  }

  Future<void> addPassword(PasswordItem password) async {
    final passwords = await loadPasswords();
    passwords.add(password);
    await savePasswords(passwords);
  }

  Future<void> updatePassword(PasswordItem password) async {
    final passwords = await loadPasswords();
    final index = passwords.indexWhere((p) => p.id == password.id);
    if (index != -1) {
      passwords[index] = password;
      await savePasswords(passwords);
    }
  }

  Future<void> deletePassword(String id) async {
    final passwords = await loadPasswords();
    passwords.removeWhere((p) => p.id == id);
    await savePasswords(passwords);
  }

  Future<void> toggleFavorite(String id) async {
    final passwords = await loadPasswords();
    final index = passwords.indexWhere((p) => p.id == id);
    if (index != -1) {
      passwords[index] = passwords[index].copyWith(
        isFavorite: !passwords[index].isFavorite,
        updatedAt: DateTime.now(),
      );
      await savePasswords(passwords);
    }
  }

  List<PasswordItem> _getDefaultPasswords() {
    return [
      PasswordItem(
        id: '1',
        title: 'Gmail',
        username: 'user@gmail.com',
        password: 'SecurePass123!',
        category: 'Email',
        isFavorite: true,
        createdAt: DateTime.now(),
      ),
      PasswordItem(
        id: '2',
        title: 'Facebook',
        username: 'john.doe',
        password: 'Fb@2024Secure',
        category: 'Social',
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
      PasswordItem(
        id: '3',
        title: 'Netflix',
        username: 'john@email.com',
        password: 'N3tfl!x2024',
        category: 'Entertainment',
        isFavorite: true,
        createdAt: DateTime.now(),
      ),
      PasswordItem(
        id: '4',
        title: 'GitHub',
        username: 'johndoe',
        password: 'Git@Hub456!',
        category: 'Development',
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
    ];
  }
}