import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LabAccreditation {
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const LabAccreditation({
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  // Backward compatibility getters
  String get code => name;
  String get shortLabel => name;
  String get fullName => name;

  static const List<String> certificationNames = [
    'ISO',
    'PNRA',
    'NQA',
    'CAP',
    'Sindh Healthcare Commission',
    'Balochistan Healthcare Commission',
  ];

  static const List<LabAccreditation> all = [
    LabAccreditation(
      name: 'ISO',
      icon: Icons.shield_rounded,
      color: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
    ),
    LabAccreditation(
      name: 'PNRA',
      icon: Icons.shield_rounded,
      color: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
    ),
    LabAccreditation(
      name: 'NQA',
      icon: Icons.verified_user_rounded,
      color: Color(0xFF059669),
      bgColor: Color(0xFFD1FAE5),
    ),
    LabAccreditation(
      name: 'CAP',
      icon: Icons.shield_rounded,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF3E8FF),
    ),
    LabAccreditation(
      name: 'Sindh Healthcare Commission',
      icon: Icons.check_circle_rounded,
      color: Color(0xFFDC2626),
      bgColor: Color(0xFFFEE2E2),
    ),
    LabAccreditation(
      name: 'Balochistan Healthcare Commission',
      icon: Icons.check_circle_rounded,
      color: Color(0xFF4F46E5),
      bgColor: Color(0xFFE0E7FF),
    ),
  ];
}

/// A clean badge widget displaying the certification name with check/shield icon
class CertificationBadge extends StatelessWidget {
  final String name;
  final bool compact;

  const CertificationBadge({
    super.key,
    required this.name,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              size: 11,
              color: Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: compact ? 10.5 : 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.structuralNavy,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward compatibility button chip
class LabAccreditationButtonChip extends StatelessWidget {
  final LabAccreditation accreditation;
  final bool compact;

  const LabAccreditationButtonChip({
    super.key,
    required this.accreditation,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3.5 : 5,
      ),
      decoration: BoxDecoration(
        color: accreditation.bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accreditation.color.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            accreditation.icon,
            size: compact ? 11 : 12,
            color: accreditation.color,
          ),
          const SizedBox(width: 4),
          Text(
            accreditation.name,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: accreditation.color,
            ),
          ),
        ],
      ),
    );
  }
}
