import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_item.dart';
import '../services/password_generator.dart';

class PasswordCard extends StatefulWidget {
  final PasswordItem password;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const PasswordCard({
    super.key,
    required this.password,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  State<PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<PasswordCard> {
  bool _isPasswordVisible = false;
  String? _copiedField;

  void _copyToClipboard(String text, String field) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copiedField = field);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$field copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copiedField = null);
      }
    });
  }

  Color _getCategoryColor() {
    switch (widget.password.category.toLowerCase()) {
      case 'email':
        return Colors.blue;
      case 'social':
        return Colors.purple;
      case 'banking':
        return Colors.green;
      case 'entertainment':
        return Colors.orange;
      case 'development':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = PasswordGenerator.getStrength(widget.password.password);
    final strengthColor = strength == PasswordStrength.strong
        ? Colors.green
        : strength == PasswordStrength.medium
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        widget.password.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.password.category,
                          style: TextStyle(
                            color: _getCategoryColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (widget.password.isFavorite) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.password.isFavorite
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: widget.onToggleFavorite,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Password'),
                        content: Text(
                          'Are you sure you want to delete "${widget.password.title}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onDelete();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Username',
              widget.password.username,
              'username',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Password',
              _isPasswordVisible ? widget.password.password : '••••••••••',
              'password',
              isPassword: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(
                  width: 90,
                  child: Text(
                    'Strength:',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: strength.progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(strengthColor),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strength.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: strengthColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String field,
      {bool isPassword = false}) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: isPassword ? 'monospace' : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (isPassword)
          IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
        IconButton(
          icon: Icon(
            _copiedField == field ? Icons.check : Icons.copy,
            size: 20,
            color: _copiedField == field ? Colors.green : Colors.grey,
          ),
          onPressed: () => _copyToClipboard(
            isPassword ? widget.password.password : widget.password.username,
            label,
          ),
        ),
      ],
    );
  }
}