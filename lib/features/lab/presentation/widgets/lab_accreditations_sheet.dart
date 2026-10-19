import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LabAccreditation {
  final String code;
  final String shortLabel;
  final String fullName;
  final String authority;
  final String description;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const LabAccreditation({
    required this.code,
    required this.shortLabel,
    required this.fullName,
    required this.authority,
    required this.description,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  static const List<LabAccreditation> all = [
    LabAccreditation(
      code: 'ISO',
      shortLabel: 'ISO 15189',
      fullName: 'ISO 15189:2022 Medical Laboratories',
      authority: 'International Organization for Standardization (ISO)',
      description:
          'International gold standard specifying rigorous requirements for clinical quality, precision calibration, automated pathology analyzers, and competent medical diagnostics.',
      icon: Icons.verified_user_rounded,
      color: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
    ),
    LabAccreditation(
      code: 'CAP',
      shortLabel: 'CAP',
      fullName: 'College of American Pathologists (CAP)',
      authority: 'College of American Pathologists Global Quality Network',
      description:
          'World-recognized pathology accreditation ensuring peak analytical accuracy, rigorous blind sample testing, and state-of-the-art diagnostic peer comparisons.',
      icon: Icons.biotech_rounded,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF3E8FF),
    ),
    LabAccreditation(
      code: 'PNRA',
      shortLabel: 'PNRA',
      fullName: 'Pakistan Nuclear Regulatory Authority (PNRA)',
      authority: 'Federal Regulatory Authority of Pakistan',
      description:
          'Licensed compliance for radioimmunoassay (RIA), clinical radiation monitoring, and certified diagnostic isotope handling bio-safety protocols.',
      icon: Icons.shield_rounded,
      color: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
    ),
    LabAccreditation(
      code: 'NQA',
      shortLabel: 'NQA / NEQAS',
      fullName: 'National External Quality Assessment (NEQAS - NQA)',
      authority: 'National Quality Assurance Committee for Clinical Pathology',
      description:
          'Continuous nationwide external quality assessment ensuring standardized laboratory calibration, error-free automated assays, and cross-lab benchmark verification.',
      icon: Icons.task_alt_rounded,
      color: Color(0xFF059669),
      bgColor: Color(0xFFD1FAE5),
    ),
    LabAccreditation(
      code: 'SINDH HC',
      shortLabel: 'SINDH HC',
      fullName: 'Sindh Health Care Commission (SHCC)',
      authority: 'Provincial Health Care Commission of Sindh',
      description:
          'Officially registered and licensed diagnostic pathology network fulfilling provincial clinical guidelines, sterile phlebotomy regulations, and bio-waste protocols.',
      icon: Icons.health_and_safety_rounded,
      color: Color(0xFFDC2626),
      bgColor: Color(0xFFFEE2E2),
    ),
    LabAccreditation(
      code: 'BALOCHISTAN HC',
      shortLabel: 'BALOCHISTAN HC',
      fullName: 'Balochistan Health Care Commission (BHCC)',
      authority: 'Balochistan Health Care Commission Regulatory Body',
      description:
          'Licensed clinical diagnostic operations providing verified pathology testing, mobile home sample collection, and high-standard patient care across Balochistan.',
      icon: Icons.domain_verification_rounded,
      color: Color(0xFF4F46E5),
      bgColor: Color(0xFFE0E7FF),
    ),
  ];

  static void showDetails(BuildContext context, LabAccreditation acc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: acc.bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: acc.color.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(acc.icon, color: acc.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: acc.bgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              acc.code,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: acc.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 11,
                                  color: Color(0xFF059669),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Active & Verified',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        acc.fullName,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.structuralNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accreditation Authority',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    acc.authority,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.structuralNavy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 10),
                  const Text(
                    'Scope & Clinical Standards',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    acc.description,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      color: AppColors.structuralNavy,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Understood',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A button-type accreditation chip mimicking the website's Book Diagnostic badges
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => LabAccreditation.showDetails(context, accreditation),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 7 : 10,
            vertical: compact ? 3.5 : 6,
          ),
          decoration: BoxDecoration(
            color: accreditation.bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: accreditation.color.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: accreditation.color.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                accreditation.icon,
                size: compact ? 11 : 13,
                color: accreditation.color,
              ),
              const SizedBox(width: 4),
              Text(
                accreditation.shortLabel,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: compact ? 10 : 11.5,
                  fontWeight: FontWeight.w800,
                  color: accreditation.color,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
