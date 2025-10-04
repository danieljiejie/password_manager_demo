class PasswordItem {
  final String id;
  final String title;
  final String username;
  final String password;
  final String category;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PasswordItem({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.category,
    this.isFavorite = false,
    required this.createdAt,
    this.updatedAt,
  });

  PasswordItem copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PasswordItem(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'category': category,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PasswordItem.fromJson(Map<String, dynamic> json) {
    return PasswordItem(
      id: json['id'],
      title: json['title'],
      username: json['username'],
      password: json['password'],
      category: json['category'],
      isFavorite: json['isFavorite'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
}