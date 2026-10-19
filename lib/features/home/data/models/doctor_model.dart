import 'branch_model.dart';

class DoctorModel {
  final String id;
  final String fullName;
  final String specialization;
  final String qualification;
  final int experienceYears;
  final double consultationFee;
  final String? profileImageUrl;
  final String? bio;
  final bool isActive;
  final List<BranchModel> branches;

  DoctorModel({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.qualification,
    required this.experienceYears,
    required this.consultationFee,
    this.profileImageUrl,
    this.bio,
    this.isActive = true,
    this.branches = const [],
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val, double fallback) {
      if (val == null) return fallback;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? fallback;
      return fallback;
    }

    return DoctorModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Doctor',
      specialization: json['specialization'] as String? ?? 'General Physician',
      qualification: json['qualification'] as String? ?? 'MBBS',
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      consultationFee: parseDouble(json['consultation_fee'], 1500.0),
      profileImageUrl: json['profile_image_url'] as String?,
      bio: json['bio'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      branches: (json['branches'] as List<dynamic>?)
              ?.map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
