import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/password_generator.dart';

class GeneratePasswordDialog extends StatefulWidget {
  final Function(String) onPasswordGenerated;

  const GeneratePasswordDialog({
    super.key,
    required this.onPasswordGenerated,
  });

  @override
  State<GeneratePasswordDialog> createState() => _GeneratePasswordDialogState();
}

class _GeneratePasswordDialogState extends State<GeneratePasswordDialog> {
  String _generatedPassword = '';
  double _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    try {
      final password = PasswordGenerator.generate(
        length: _length.toInt(),
        includeUppercase: _includeUppercase,
        includeLowercase: _includeLowercase,
        includeNumbers: _includeNumbers,
        includeSymbols: _includeSymbols,
      );
      setState(() {
        _generatedPassword = password;
        _copied = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one character type'),
        ),
      );
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.pink],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.key, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Generate Strong Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_generatedPassword.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _generatedPassword,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _copied ? Icons.check : Icons.copy,
                        color: _copied ? Colors.green : Colors.blue,
                      ),
                      onPressed: _copyToClipboard,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Password Length: ${_length.toInt()}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Slider(
              value: _length,
              min: 8,
              max: 32,
              divisions: 24,
              label: _length.toInt().toString(),
              onChanged: (value) {
                setState(() => _length = value);
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Uppercase (A-Z)'),
              value: _includeUppercase,
              onChanged: (value) {
                setState(() => _includeUppercase = value ?? true);
              },
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Lowercase (a-z)'),
              value: _includeLowercase,
              onChanged: (value) {
                setState(() => _includeLowercase = value ?? true);
              },
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Numbers (0-9)'),
              value: _includeNumbers,
              onChanged: (value) {
                setState(() => _includeNumbers = value ?? true);
              },
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Symbols (!@#\$%...)'),
              value: _includeSymbols,
              onChanged: (value) {
                setState(() => _includeSymbols = value ?? true);
              },
              dense: true,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generatePassword,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Regenerate'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onPasswordGenerated(_generatedPassword);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Use Password'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}