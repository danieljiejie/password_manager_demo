import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/email_service.dart'; // put sendOtpEmail function here

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _otpController = TextEditingController();

  String _error = "";
  String? _generatedOtp;
  bool _otpSent = false;

  // Password policy check
  bool _isPasswordStrong(String password) {
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$&*~]'));
    final hasLength = password.length > 10;
    return hasUpper && hasLower && hasDigit && hasSpecial && hasLength;
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = "Please enter your email first");
      return;
    }
    // Generate 6-digit OTP
    final otp = (Random().nextInt(900000) + 100000).toString();
    setState(() {
      _generatedOtp = otp;
      _otpSent = true;
      _error = "";
    });
    await sendOtpEmail(email, otp);
  }

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final otp = _otpController.text.trim();

    if (!_isPasswordStrong(password)) {
      setState(() => _error =
          "Password must include uppercase, lowercase, number, special char and >10 length");
      return;
    }
    if (password != confirm) {
      setState(() => _error = "Passwords do not match");
      return;
    }
    if (_generatedOtp == null || otp != _generatedOtp) {
      setState(() => _error = "Invalid OTP");
      return;
    }

    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    final authBox = Hive.box('auth');
    if (authBox.containsKey('email')) {
      setState(() => _error = "Account already exists. Please login.");
      return;
    }

    authBox.put('email', email);
    authBox.put('password', hashedPassword);

    // Success → show snackbar and go back to login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registration successful! Please login.")),
    );

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Master Password"),
              ),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirm Password"),
              ),
              const SizedBox(height: 10),
              if (_otpSent) ...[
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(labelText: "Enter OTP"),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _otpSent ? _register : _sendOtp,
                child: Text(_otpSent ? "Register" : "Send OTP"),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(_error, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
