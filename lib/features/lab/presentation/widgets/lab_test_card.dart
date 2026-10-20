import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../home/data/models/lab_test_model.dart';
import 'book_lab_test_modal.dart';
import 'lab_test_reviews_modal.dart';

class LabTestCard extends StatelessWidget {
  final LabTestModel test;
  final VoidCallback? onBookTap;

  const LabTestCard({
    super.key,
    required this.test,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    final reportingText = test.reportingTime?.trim().isNotEmpty == true
        ? test.reportingTime!
        : (test.turnaroundHours != null ? 'Report in ${test.turnaroundHours}h' : null);

    final hasCategory = test.category != null && test.category!.trim().isNotEmpty;
    final hasSpecimen = test.specimen != null && test.specimen!.trim().isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (onBookTap != null) {
          onBookTap!();
        } else {
          BookLabTestModal.show(context, test: test);
        }
      },
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
            // Top Row: Code badge + Category badge + Reporting Time
            Row(
              children: [
                if (test.code.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      test.code,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (hasCategory) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      test.category!,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (reportingText != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reportingText,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Test Title
            Text(
              test.name,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
                height: 1.25,
              ),
            ),

            // Specimen row (hidden if null or empty)
            if (hasSpecimen) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.biotech_outlined,
                    size: 14,
                    color: Color(0xFF0D9488),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Specimen: ${test.specimen!}',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11.5,
                        color: Color(0xFF0F766E),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Description (if present and non-empty)
            if (test.description != null && test.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                test.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11.5,
                  color: AppColors.secondary.withValues(alpha: 0.85),
                  height: 1.35,
                ),
              ),
            ],

            // Home Sampling Badge if available
            if (test.homeSamplingAvailable) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.home_work_rounded,
                      size: 11,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      test.homeSamplingFee > 0
                          ? 'Home Sampling (+PKR ${test.homeSamplingFee.toStringAsFixed(0)})'
                          : 'Free Home Sampling Available',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Price & Book Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Standard Fee',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      'PKR ${test.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => LabTestReviewsModal.show(context, test: test),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0284C7),
                        side: BorderSide(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.star_outline_rounded,
                        size: 14,
                        color: Color(0xFFF59E0B),
                      ),
                      label: const Text(
                        'Reviews',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (onBookTap != null) {
                          onBookTap!();
                        } else {
                          BookLabTestModal.show(context, test: test);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.calendar_month_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Book Test',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11.5,
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
