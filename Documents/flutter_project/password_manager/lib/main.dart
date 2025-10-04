import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/register_screen.dart';
//import 'screens/login_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/login_screen2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('auth'); // for storing email + hashed password
  await Hive.openBox('vault'); // for storing saved accounts

  runApp(const PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
      primaryColor: Colors.amber[100],
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen2(),
        '/register': (context) => const RegisterScreen(),
        '/vault': (context) => const VaultScreen(),
      },
    );
  }
}
