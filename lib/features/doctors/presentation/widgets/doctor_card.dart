import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../home/data/models/doctor_model.dart';
import 'doctor_avatar.dart';

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onBookTap;
  final VoidCallback? onProfileTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onBookTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onProfileTap ?? onBookTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Avatar
              DoctorAvatar(
                doctor: doctor,
                size: 54,
                borderRadius: 15,
                showOnlineIndicator: doctor.isActive,
              ),

              const SizedBox(width: 12),

              // Name, Specialization & Qualifications
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.fullName,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        doctor.specialization,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${doctor.qualification} • ${doctor.experienceYears} yrs experience',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Practicing Branches tags
          if (doctor.branches.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: doctor.branches.map((b) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.canvasBase,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.structuralNavy.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        b.name,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          color: AppColors.structuralNavy,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 14),

          // Fee & Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consultation Fee',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    'Rs. ${doctor.consultationFee.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (onProfileTap != null) ...[
                    OutlinedButton(
                      onPressed: onProfileTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.structuralNavy,
                        side: BorderSide(
                          color: AppColors.structuralNavy.withValues(alpha: 0.18),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 15, color: Color(0xFFF59E0B)),
                          SizedBox(width: 4),
                          Text(
                            'Reviews',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton.icon(
                    onPressed: onBookTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.calendar_month_rounded, size: 15),
                    label: const Text(
                      'Book',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
