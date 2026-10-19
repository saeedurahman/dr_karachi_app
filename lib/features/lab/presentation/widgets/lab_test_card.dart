import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../home/data/models/lab_test_model.dart';
import 'book_lab_test_modal.dart';
import 'lab_accreditations_sheet.dart';
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
            // Top Row: Code badge + Turnaround time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        test.code.isNotEmpty ? test.code : 'LAB TEST',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
                if (test.turnaroundHours != null)
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
                        'Report: ${test.turnaroundHours}h',
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
              ),
            ),

            // Description
            if (test.description != null && test.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                test.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  color: AppColors.secondary.withValues(alpha: 0.85),
                  height: 1.35,
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Website-Style Accreditation Buttons: ISO, CAP, PNRA, NQA, SINDH HC, BALOCHISTAN HC
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: LabAccreditation.all.map((acc) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: LabAccreditationButtonChip(
                      accreditation: acc,
                      compact: true,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Home Sampling Badge if available
            if (test.homeSamplingAvailable) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.home_work_rounded,
                      size: 12,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      test.homeSamplingFee > 0
                          ? 'Home Sampling Available (+Rs. ${test.homeSamplingFee.toStringAsFixed(0)})'
                          : 'Free Home Sampling Available',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Price & Book Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Standard Price',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      'Rs. ${test.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
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
                        size: 15,
                        color: Color(0xFFF59E0B),
                      ),
                      label: const Text(
                        'Reviews',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11.5,
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
                        backgroundColor: const Color(0xFF0284C7),
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
                      icon: const Icon(Icons.bookmark_add_rounded, size: 15),
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
