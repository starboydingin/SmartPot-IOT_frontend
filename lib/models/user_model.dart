class User {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.location,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] ?? json['createdAt'];
    final updated = json['updated_at'] ?? json['updatedAt'];

    return User(
      id: json['id'] as String,
      fullName: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] as String,
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      location: json['location'],
      createdAt: created != null ? DateTime.parse(created) : DateTime.now(),
      updatedAt: updated != null ? DateTime.parse(updated) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['access_token'],
      user: User.fromJson(json['user']),
    );
  }
}
