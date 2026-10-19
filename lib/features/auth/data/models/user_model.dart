class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'patient',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'is_active': isActive,
    };
  }
}
