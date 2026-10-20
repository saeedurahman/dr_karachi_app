import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'auto_rotating_carousel.dart';
import 'overview_kpi_card.dart';

/// Healthcare Pillars Overview Section with 3D Cube Flip Animated Carousel
class QuickActionsGrid extends StatelessWidget {
  final int? productsCount;
  final int? doctorsCount;
  final int? labTestsCount;
  final int? branchesCount;
  final VoidCallback? onPharmacyTap;
  final VoidCallback? onLabTap;
  final VoidCallback? onDoctorsTap;
  final VoidCallback? onBranchesTap;

  const QuickActionsGrid({
    super.key,
    this.productsCount,
    this.doctorsCount,
    this.labTestsCount,
    this.branchesCount,
    this.onPharmacyTap,
    this.onLabTap,
    this.onDoctorsTap,
    this.onBranchesTap,
  });

  @override
  Widget build(BuildContext context) {
    final overviewCards = <OverviewKpiCard>[
      OverviewKpiCard(
        title: 'Karachi Lab Pharmacy',
        value: productsCount != null && productsCount! > 0
            ? '$productsCount+ Medicines'
            : '100% Genuine',
        subtitle: 'Authentic medicines & doorstep delivery in Balochistan',
        icon: Icons.medication_rounded,
        color: AppColors.primaryAccent,
        onTap: onPharmacyTap,
      ),
      OverviewKpiCard(
        title: 'Diagnostic Laboratory',
        value: labTestsCount != null && labTestsCount! > 0
            ? '$labTestsCount+ Tests'
            : '100,000+ Monthly',
        subtitle: 'Pathology lab tests & free home sample collection',
        icon: Icons.biotech_rounded,
        color: const Color(0xFF0284C7),
        onTap: onLabTap,
      ),
      OverviewKpiCard(
        title: 'Doctor Clinics',
        value: doctorsCount != null && doctorsCount! > 0
            ? '$doctorsCount+ Specialists'
            : 'Verified Doctors',
        subtitle: 'In-clinic & online appointments with consultants',
        icon: Icons.medical_information_rounded,
        color: const Color(0xFF0D9488),
        onTap: onDoctorsTap,
      ),
      OverviewKpiCard(
        title: 'Diagnostic Centres',
        value: branchesCount != null && branchesCount! > 0
            ? '$branchesCount Centres'
            : '5 Centres',
        subtitle: '5 centres across Balochistan for healthcare & labs',
        icon: Icons.store_mall_directory_rounded,
        color: const Color(0xFF7C3AED),
        onTap: onBranchesTap,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Services Overview',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
                letterSpacing: -0.015,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 12,
                    color: AppColors.primaryAccent,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Featured',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AutoRotatingCarousel(
          height: 148,
          cards: overviewCards,
          accentColors: [for (final c in overviewCards) c.color],
          autoPlayInterval: const Duration(seconds: 4),
        ),
      ],
    );
  }
}
