import 'package:flutter/material.dart';
import '../models/password_item.dart';
import '../services/password_service.dart';
import '../widgets/password_card.dart';
import '../widgets/add_password_dialog.dart';
import '../widgets/generate_password_dialog.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final PasswordService _passwordService = PasswordService();
  List<PasswordItem> _passwords = [];
  List<PasswordItem> _filteredPasswords = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPasswords() async {
    setState(() => _isLoading = true);
    try {
      final passwords = await _passwordService.loadPasswords();
      setState(() {
        _passwords = passwords;
        _filteredPasswords = passwords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load passwords');
    }
  }

  void _filterPasswords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPasswords = _passwords;
      } else {
        _filteredPasswords = _passwords.where((password) {
          final lowerQuery = query.toLowerCase();
          return password.title.toLowerCase().contains(lowerQuery) ||
              password.username.toLowerCase().contains(lowerQuery) ||
              password.category.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  Future<void> _addPassword() async {
    final result = await showDialog<PasswordItem>(
      context: context,
      builder: (context) => const AddPasswordDialog(),
    );

    if (result != null) {
      try {
        await _passwordService.addPassword(result);
        await _loadPasswords();
        _showSuccessSnackBar('Password added successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to add password');
      }
    }
  }

  Future<void> _editPassword(PasswordItem password) async {
    final result = await showDialog<PasswordItem>(
      context: context,
      builder: (context) => AddPasswordDialog(passwordToEdit: password),
    );

    if (result != null) {
      try {
        await _passwordService.updatePassword(result);
        await _loadPasswords();
        _showSuccessSnackBar('Password updated successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to update password');
      }
    }
  }

  Future<void> _deletePassword(String id) async {
    try {
      await _passwordService.deletePassword(id);
      await _loadPasswords();
      _showSuccessSnackBar('Password deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete password');
    }
  }

  Future<void> _toggleFavorite(String id) async {
    try {
      await _passwordService.toggleFavorite(id);
      await _loadPasswords();
    } catch (e) {
      _showErrorSnackBar('Failed to update favorite');
    }
  }

  void _showGeneratePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => GeneratePasswordDialog(
        onPasswordGenerated: (password) {
          // Just show the dialog, user can copy the password
        },
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.indigo.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.indigo],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.security,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'My Vault',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_passwords.length} passwords stored securely',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showGeneratePasswordDialog,
                            icon: const Icon(Icons.key),
                            label: const Text('Generate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addPassword,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Password'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search passwords, usernames, or categories...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterPasswords('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: _filterPasswords,
                    ),
                  ],
                ),
              ),

              // Password List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredPasswords.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadPasswords,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _filteredPasswords.length,
                              itemBuilder: (context, index) {
                                final password = _filteredPasswords[index];
                                return PasswordCard(
                                  password: password,
                                  onEdit: () => _editPassword(password),
                                  onDelete: () => _deletePassword(password.id),
                                  onToggleFavorite: () =>
                                      _toggleFavorite(password.id),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'No passwords yet'
                : 'No passwords found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Add your first password to get started'
                : 'Try adjusting your search',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addPassword,
              icon: const Icon(Icons.add),
              label: const Text('Add Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}