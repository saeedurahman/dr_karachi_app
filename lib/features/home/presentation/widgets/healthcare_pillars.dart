import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/lab_test_model.dart';
import '../../data/models/product_model.dart';
import '../../../doctors/presentation/pages/doctor_profile_screen.dart';
import '../../../doctors/presentation/pages/doctors_screen.dart';
import '../../../lab/presentation/pages/lab_screen.dart';
import '../../../pharmacy/presentation/pages/pharmacy_screen.dart';
import '../../../pharmacy/presentation/widgets/prescription_upload_modal.dart';
import '../../../lab/presentation/widgets/book_lab_test_modal.dart';
import '../../../lab/presentation/widgets/lab_accreditations_sheet.dart';
import '../../../lab/presentation/widgets/lab_test_reviews_modal.dart';

class HealthcarePillars extends StatelessWidget {
  final List<ProductModel> products;
  final List<DoctorModel> doctors;
  final List<LabTestModel> labTests;
  final String? branchName;
  final String? branchId;
  final VoidCallback? onFindSpecialist;
  final VoidCallback? onBookHomeSampling;
  final VoidCallback? onUploadPrescription;
  final VoidCallback? onShopPharmacy;

  const HealthcarePillars({
    super.key,
    this.products = const [],
    this.doctors = const [],
    this.labTests = const [],
    this.branchName,
    this.branchId,
    this.onFindSpecialist,
    this.onBookHomeSampling,
    this.onUploadPrescription,
    this.onShopPharmacy,
  });

  static final List<ProductModel> _fallbackProducts = [
    ProductModel(
      id: 'prod-panadol-extra',
      name: 'Panadol Extra 500mg (Paracetamol)',
      sku: 'GSK-PDL-500',
      originalPrice: 150.0,
      discountPercent: 10.0,
      discountedPrice: 135.0,
      requiresPrescription: false,
      stockAtBranch: 50,
    ),
    ProductModel(
      id: 'prod-augmentin',
      name: 'Augmentin 625mg Tablets',
      sku: 'GSK-AUG-625',
      originalPrice: 420.0,
      discountPercent: 12.0,
      discountedPrice: 369.0,
      requiresPrescription: true,
      stockAtBranch: 30,
    ),
    ProductModel(
      id: 'prod-surbex-z',
      name: 'Surbex Z Zinc & High Potency B-Complex',
      sku: 'ABT-SRB-Z',
      originalPrice: 580.0,
      discountPercent: 15.0,
      discountedPrice: 493.0,
      requiresPrescription: false,
      stockAtBranch: 25,
    ),
    ProductModel(
      id: 'prod-cac-1000',
      name: 'CaC-1000 Plus Effervescent Tablets',
      sku: 'GSK-CAC-1000',
      originalPrice: 495.0,
      discountPercent: 8.0,
      discountedPrice: 455.0,
      requiresPrescription: false,
      stockAtBranch: 40,
    ),
  ];

  static final List<DoctorModel> _fallbackDoctors = [
    DoctorModel(
      id: 'doc-ahmed-siddiqui',
      fullName: 'Dr. Ahmed Siddiqui',
      specialization: 'Cardiologist',
      qualification: 'MBBS, FCPS (Cardiology)',
      experienceYears: 15,
      consultationFee: 2500.0,
      profileImageUrl: 'assets/images/doctors/doctor-ahmed-siddiqui.jpg',
      bio: 'Consultant Interventional Cardiologist with 15+ years experience.',
    ),
    DoctorModel(
      id: 'doc-nadia-hussain',
      fullName: 'Dr. Nadia Hussain',
      specialization: 'Dermatologist',
      qualification: 'MBBS, MCPS (Dermatology)',
      experienceYears: 12,
      consultationFee: 2000.0,
      profileImageUrl: 'assets/images/doctors/doctor-nadia-hussain.jpg',
      bio: 'Expert Consultant Dermatologist and Clinical Cosmetologist.',
    ),
    DoctorModel(
      id: 'doc-imran-chaudhry',
      fullName: 'Dr. Imran Chaudhry',
      specialization: 'Pediatrician',
      qualification: 'MBBS, DCH, FCPS (Pediatrics)',
      experienceYears: 18,
      consultationFee: 1800.0,
      profileImageUrl: 'assets/images/doctors/doctor-imran-chaudhry.jpg',
      bio: 'Senior Consultant Child Specialist and Neonatologist.',
    ),
    DoctorModel(
      id: 'doc-sara-malik',
      fullName: 'Dr. Sara Malik',
      specialization: 'General Physician',
      qualification: 'MBBS, FCPS (Medicine)',
      experienceYears: 10,
      consultationFee: 1500.0,
      profileImageUrl: 'assets/images/doctors/doctor-sara-malik.jpg',
      bio: 'Consultant Physician specialized in adult preventive healthcare.',
    ),
  ];

  static final List<LabTestModel> _fallbackLabTests = [
    LabTestModel(
      id: 'lt1',
      name: 'Complete Blood Count (CBC)',
      code: 'LAB-CBC',
      description: 'Comprehensive evaluation of blood cells – RBCs, WBCs, platelets.',
      price: 650.0,
      homeSamplingAvailable: true,
      homeSamplingFee: 0.0,
      turnaroundHours: 24,
    ),
    LabTestModel(
      id: 'lt2',
      name: 'Lipid Profile Panel',
      code: 'LAB-LIPID',
      description: 'Cholesterol, triglycerides, HDL and LDL measurement panel.',
      price: 1200.0,
      homeSamplingAvailable: true,
      homeSamplingFee: 0.0,
      turnaroundHours: 24,
    ),
    LabTestModel(
      id: 'lt3',
      name: 'Thyroid Panel (TSH)',
      code: 'LAB-TSH',
      description: 'Thyroid stimulating hormone test for thyroid function assessment.',
      price: 900.0,
      homeSamplingAvailable: true,
      homeSamplingFee: 0.0,
      turnaroundHours: 48,
    ),
    LabTestModel(
      id: 'lt4',
      name: 'Fasting Blood Sugar (FBS)',
      code: 'LAB-FBS',
      description: 'Glucose measurement after 8 hours of fasting – diabetes monitoring.',
      price: 350.0,
      homeSamplingAvailable: true,
      homeSamplingFee: 0.0,
      turnaroundHours: 12,
    ),
    LabTestModel(
      id: 'lt6',
      name: 'HbA1c (Glycated Haemoglobin)',
      code: 'LAB-HBA1C',
      description: '3-month average blood sugar – essential diabetes management test.',
      price: 1500.0,
      homeSamplingAvailable: true,
      homeSamplingFee: 0.0,
      turnaroundHours: 24,
    ),
  ];

  List<DoctorModel> get _resolvedDoctors {
    if (doctors.length >= 3) {
      return doctors;
    }
    final list = List<DoctorModel>.from(doctors);
    for (final fb in _fallbackDoctors) {
      if (!list.any((d) =>
          d.id == fb.id ||
          d.fullName.toLowerCase() == fb.fullName.toLowerCase())) {
        list.add(fb);
      }
    }
    return list;
  }

  List<LabTestModel> get _resolvedLabTests {
    if (labTests.length >= 3) {
      return labTests;
    }
    final list = List<LabTestModel>.from(labTests);
    for (final fb in _fallbackLabTests) {
      if (!list.any((t) =>
          t.id == fb.id ||
          t.name.toLowerCase() == fb.name.toLowerCase())) {
        list.add(fb);
      }
    }
    return list;
  }

  List<ProductModel> get _resolvedProducts =>
      products.isNotEmpty ? products : _fallbackProducts;

  void _navigateToLab(BuildContext context) {
    if (onBookHomeSampling != null) {
      onBookHomeSampling!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const LabScreen(),
        ),
      );
    }
  }

  void _bookLabTest(BuildContext context, LabTestModel test) {
    BookLabTestModal.show(context, test: test, initialBranchId: branchId);
  }

  void _navigateToDoctors(BuildContext context, {String? specialization}) {
    if (specialization != null && specialization != 'All Specialists') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DoctorsScreen(
            initialSpecialization: specialization,
          ),
        ),
      );
    } else if (onFindSpecialist != null) {
      onFindSpecialist!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DoctorsScreen(),
        ),
      );
    }
  }

  void _bookDoctor(BuildContext context, DoctorModel doctor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoctorProfileScreen(doctor: doctor),
      ),
    );
  }

  void _navigateToPharmacy(BuildContext context) {
    if (onShopPharmacy != null) {
      onShopPharmacy!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PharmacyScreen(initialBranchId: branchId),
        ),
      );
    }
  }

  void _showPrescriptionSheet(BuildContext context) {
    if (onUploadPrescription != null) {
      onUploadPrescription!();
      return;
    }

    PrescriptionUploadModal.show(
      context,
      branchId: branchId,
      branchName: branchName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Integrated Healthcare',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
                letterSpacing: -0.015,
              ),
            ),
            const Text(
              'Karachi Labs & Pharmacy',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
                letterSpacing: 0.04,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Pillar 1: Online Pharmacy (Buy Medicines)
        _buildPillar(
          iconData: Icons.medication_rounded,
          iconBgColor: AppColors.onPrimaryContainer,
          iconColor: AppColors.primaryAccent,
          title: 'Buy Medicines',
          badge: 'Online Pharmacy',
          badgeBg: AppColors.secondaryContainer,
          badgeText: AppColors.secondary,
          subtitle: 'Browse authentic medicines, prescription drugs & healthcare products with express doorstep delivery.',
          extra: _buildPharmacyExtra(context),
        ),
        const SizedBox(height: 10),

        // Pillar 2: Consult Doctors
        _buildPillar(
          iconData: Icons.medical_services_outlined,
          iconBgColor: AppColors.surfaceVariant,
          iconColor: AppColors.tertiary,
          title: 'Consult Doctors',
          badge:
              '${doctors.isNotEmpty ? "${doctors.length * 35}+" : "180+"} PMDC',
          badgeBg: const Color(0xFFDCE9FF),
          badgeText: AppColors.tertiary,
          subtitle: 'Book in-clinic appointments with verified specialists across branches',
          extra: _buildDoctorsExtra(context),
        ),
        const SizedBox(height: 10),

        // Pillar 3: Lab Diagnostics
        _buildPillar(
          iconData: Icons.biotech_rounded,
          iconBgColor: const Color(0xFFE0F2FE),
          iconColor: const Color(0xFF0284C7),
          title: 'Lab Diagnostics',
          badge: 'ISO 15189 & CAP',
          badgeBg: const Color(0xFFE0F2FE),
          badgeText: const Color(0xFF0284C7),
          subtitle:
              'Certified pathology evaluation with sterile home phlebotomy & 24h reports',
          extra: _buildLabExtra(context),
        ),
      ],
    );
  }

  Widget _buildPillar({
    required IconData iconData,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String badge,
    required Color badgeBg,
    required Color badgeText,
    required String subtitle,
    required Widget extra,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.structuralNavy,
                              letterSpacing: -0.015,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: badgeText,
                              letterSpacing: 0.03,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: AppColors.secondary,
                        letterSpacing: 0.01,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          extra,
        ],
      ),
    );
  }

  // --- Enhanced Pharmacy extra: Website style with live product cards & actions ---
  Widget _buildPharmacyExtra(BuildContext context) {
    final displayProducts = _resolvedProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Value propositions (Website Bullets)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: const Wrap(
            spacing: 10,
            runSpacing: 6,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _PharmacyMicroBadge(
                icon: Icons.verified_rounded,
                text: '100% DRAP Genuine',
                color: Color(0xFF047857),
              ),
              _PharmacyMicroBadge(
                icon: Icons.ac_unit_rounded,
                text: 'Cold-Chain Storage',
                color: Color(0xFF0284C7),
              ),
              _PharmacyMicroBadge(
                icon: Icons.bolt_rounded,
                text: 'Same-Day Delivery',
                color: AppColors.primaryAccent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Interactive Search Bar + Prescription Upload Row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _navigateToPharmacy(context),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.structuralNavy.withValues(alpha: 0.08),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search medicines, generics...',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: AppColors.secondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showPrescriptionSheet(context),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primaryAccent.withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.upload_file_rounded,
                      size: 16,
                      color: AppColors.primaryAccent,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Rx Upload',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 3. Featured Products Header & Horizontal Cards (Website style)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Products',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToPharmacy(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Catalog',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: AppColors.primaryAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Horizontal Product Cards: Auto-scrolling carousel (Moves card by card)
        _FeaturedProductsAutoCarousel(
          products: displayProducts,
          itemWidth: 154,
          spacing: 12,
          height: 216,
          itemBuilder: (context, product) =>
              _buildProductCard(context, product),
        ),
        const SizedBox(height: 12),

        // 4. Shop Pharmacy CTA Button (Website Primary Button)
        GestureDetector(
          onTap: () => _navigateToPharmacy(context),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  'Shop Pharmacy Online',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.02,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final hasDiscount = product.discountPercent > 0;

    return GestureDetector(
      onTap: () => _navigateToPharmacy(context),
      child: Container(
        width: 154,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Box with Corner Badges (Matching Pharmacy Screen style)
            Container(
              height: 96,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Prominent Centered Product Image
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child:
                          product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
                                  _buildProductPlaceholder(),
                            )
                          : _buildProductPlaceholder(),
                    ),
                  ),

                  // Rx Required Badge (Top Left)
                  if (product.requiresPrescription)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Rx',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Discount Badge (Top Right)
                  if (hasDiscount)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercent.toInt()}%',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Product Name
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
                height: 1.25,
              ),
            ),
            const Spacer(),

            // Price Row + Quick Add
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasDiscount)
                        Text(
                          'Rs. ${product.originalPrice.toInt()}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 9.5,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.secondary,
                          ),
                        ),
                      Text(
                        'Rs. ${product.discountedPrice.toInt()}',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                // Pill Add Cart Button
                GestureDetector(
                  onTap: () => _navigateToPharmacy(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00706B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPlaceholder() {
    return Center(
      child: Icon(
        Icons.medication_liquid_rounded,
        color: AppColors.primaryAccent.withValues(alpha: 0.35),
        size: 42,
      ),
    );
  }

  // --- Enhanced Doctors extra: Website style with live doctor cards, badges & filters ---
  Widget _buildDoctorsExtra(BuildContext context) {
    final resolvedDocs = _resolvedDoctors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Value propositions (Website 3 Trust Pillars)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: const Wrap(
            spacing: 10,
            runSpacing: 6,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _PharmacyMicroBadge(
                icon: Icons.verified_user_rounded,
                text: '100% PMDC Verified',
                color: Color(0xFF047857),
              ),
              _PharmacyMicroBadge(
                icon: Icons.people_alt_rounded,
                text: '180+ Specialists',
                color: Color(0xFF0284C7),
              ),
              _PharmacyMicroBadge(
                icon: Icons.calendar_month_rounded,
                text: 'In-Clinic Appointments',
                color: Color(0xFF0F766E),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Interactive Search Bar for Doctors
        GestureDetector(
          onTap: () => _navigateToDoctors(context),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.structuralNavy.withValues(alpha: 0.08),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search doctors, cardiology, skin...',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Specialization Quick Filter Chips (Website Specializations)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildSpecialtyChip(
                context,
                'All Specialists',
                Icons.medical_services_rounded,
              ),
              const SizedBox(width: 8),
              _buildSpecialtyChip(
                context,
                'Cardiology',
                Icons.favorite_rounded,
              ),
              const SizedBox(width: 8),
              _buildSpecialtyChip(
                context,
                'General Physician',
                Icons.health_and_safety_rounded,
              ),
              const SizedBox(width: 8),
              _buildSpecialtyChip(
                context,
                'Pediatrics',
                Icons.child_care_rounded,
              ),
              const SizedBox(width: 8),
              _buildSpecialtyChip(
                context,
                'Dermatology',
                Icons.auto_awesome_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 4. Featured Doctors Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Specialists',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToDoctors(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tertiary,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: AppColors.tertiary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Horizontal Doctor Cards: Auto-scrolling carousel (Moves card by card)
        _FeaturedDoctorsAutoCarousel(
          doctors: resolvedDocs,
          itemWidth: 240,
          spacing: 12,
          height: 160,
          itemBuilder: (context, doctor, index) =>
              _buildDoctorFeaturedCard(context, doctor, index),
        ),
        const SizedBox(height: 14),

        // 5. Find Specialist Doctor Full-width CTA Button
        GestureDetector(
          onTap: () => _navigateToDoctors(context),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_search_rounded,
                  size: 17,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  'Find Specialist Doctor',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.02,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorFeaturedCard(
    BuildContext context,
    DoctorModel doctor,
    int index,
  ) {
    final specIcon = _getSpecializationIcon(doctor.specialization);
    final scheduleText = _getDoctorSchedule(doctor.specialization);

    return GestureDetector(
      onTap: () => _bookDoctor(context, doctor),
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
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
                // Squircle Doctor Frame
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFCE7F3),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildDoctorImage(doctor, index),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Specialization Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFECDD3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              specIcon,
                              size: 10,
                              color: const Color(0xFFA82222),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                doctor.specialization,
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFA82222),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.fullName,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.structuralNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        doctor.qualification,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          color: AppColors.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Experience & Consultation Fee Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.history_edu_rounded,
                        size: 12,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${doctor.experienceYears} yrs exp',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.structuralNavy,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Fee: Rs. ${doctor.consultationFee.toInt()}',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Bottom Availability + Book Button Row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          scheduleText,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _bookDoctor(context, doctor),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA82222),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Book',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyChip(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _navigateToDoctors(
        context,
        specialization: label == 'All Specialists' ? null : label,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF0F766E)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.structuralNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorImage(DoctorModel doctor, int index) {
    String? assetPath;
    final name = doctor.fullName.toLowerCase();
    if (name.contains('ahmed') || name.contains('siddiqui')) {
      assetPath = 'assets/images/doctors/doctor-ahmed-siddiqui.jpg';
    } else if (name.contains('nadia') || name.contains('hussain')) {
      assetPath = 'assets/images/doctors/doctor-nadia-hussain.jpg';
    } else if (name.contains('imran') || name.contains('chaudhry')) {
      assetPath = 'assets/images/doctors/doctor-imran-chaudhry.jpg';
    } else if (name.contains('sara') || name.contains('malik')) {
      assetPath = 'assets/images/doctors/doctor-sara-malik.jpg';
    } else if (doctor.profileImageUrl != null &&
        doctor.profileImageUrl!.startsWith('assets/')) {
      assetPath = doctor.profileImageUrl;
    }

    if (doctor.profileImageUrl != null &&
        doctor.profileImageUrl!.startsWith('http')) {
      return Image.network(
        doctor.profileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            _buildDoctorAssetOrInitial(assetPath, doctor),
      );
    }

    return _buildDoctorAssetOrInitial(assetPath, doctor);
  }

  Widget _buildDoctorAssetOrInitial(String? assetPath, DoctorModel doctor) {
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildDoctorInitial(doctor),
      );
    }
    return _buildDoctorInitial(doctor);
  }

  Widget _buildDoctorInitial(DoctorModel doctor) {
    return Container(
      color: const Color(0xFFFFF1F2),
      child: Center(
        child: Text(
          doctor.fullName.isNotEmpty
              ? doctor.fullName.replaceAll('Dr. ', '').trim().substring(0, 1)
              : 'D',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFFA82222),
          ),
        ),
      ),
    );
  }

  IconData _getSpecializationIcon(String specialization) {
    final s = specialization.toLowerCase();
    if (s.contains('cardio') || s.contains('heart')) {
      return Icons.favorite_rounded;
    }
    if (s.contains('pediatric') || s.contains('child')) {
      return Icons.child_care_rounded;
    }
    if (s.contains('derma') || s.contains('skin')) {
      return Icons.auto_awesome_rounded;
    }
    if (s.contains('physician') ||
        s.contains('general') ||
        s.contains('family')) {
      return Icons.medical_services_rounded;
    }
    return Icons.health_and_safety_rounded;
  }

  String _getDoctorSchedule(String specialization) {
    final s = specialization.toLowerCase();
    if (s.contains('cardio')) return 'Today 4:30 PM • Quetta City';
    if (s.contains('derma')) return 'Today 6:00 PM • Cantt Branch';
    if (s.contains('pediatric')) return 'Today 3:00 PM • Quetta Center';
    return 'Today 5:00 PM • Main Branch';
  }

  // --- Enhanced Lab Diagnostics extra: Website style with live test cards, trust badges & carousel ---
  Widget _buildLabExtra(BuildContext context) {
    final displayTests = _resolvedLabTests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Clinical Certifications Trust Badges (Website Trust Strip)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: SingleChildScrollView(
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
        ),
        const SizedBox(height: 12),

        // 2. Interactive Search Bar for Lab Diagnostics
        GestureDetector(
          onTap: () => _navigateToLab(context),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.structuralNavy.withValues(alpha: 0.08),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search tests, CBC, lipid, thyroid...',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Category Filter Chips (Website Lab Test Categories)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildLabCategoryChip(
                context,
                'All Tests',
                Icons.biotech_rounded,
              ),
              const SizedBox(width: 8),
              _buildLabCategoryChip(
                context,
                'Routine Blood',
                Icons.water_drop_rounded,
              ),
              const SizedBox(width: 8),
              _buildLabCategoryChip(
                context,
                'Diabetes Panel',
                Icons.monitor_heart_rounded,
              ),
              const SizedBox(width: 8),
              _buildLabCategoryChip(
                context,
                'Thyroid & Hormones',
                Icons.healing_rounded,
              ),
              const SizedBox(width: 8),
              _buildLabCategoryChip(
                context,
                'Home Sampling',
                Icons.home_work_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 4. Featured Diagnostic Tests Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Lab Tests',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToLab(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Catalog',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: Color(0xFF0284C7),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Horizontal Lab Test Cards: Auto-scrolling carousel (Moves card by card)
        _FeaturedLabTestsAutoCarousel(
          tests: displayTests,
          itemWidth: 240,
          spacing: 12,
          height: 164,
          itemBuilder: (context, test) => _buildLabTestFeaturedCard(context, test),
        ),
        const SizedBox(height: 12),

        // 5. Free Home Phlebotomy Value Proposition Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0284C7).withValues(alpha: 0.08),
                const Color(0xFF0284C7).withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF0284C7).withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.home_repair_service_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Free Sterile Home Sampling',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      branchName != null && branchName!.isNotEmpty
                          ? 'Certified phlebotomist at doorstep • $branchName'
                          : 'Certified phlebotomist at doorstep across Quetta',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 6. Browse All Diagnostic Tests Full-width CTA Button
        GestureDetector(
          onTap: () => _navigateToLab(context),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.biotech_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  'Browse All Diagnostic Tests',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.02,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabCategoryChip(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _navigateToLab(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF0284C7)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.structuralNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabTestFeaturedCard(
    BuildContext context,
    LabTestModel test,
  ) {
    final isHomeSampling = test.homeSamplingAvailable;
    final turnaroundText = test.turnaroundHours != null
        ? 'Report: ${test.turnaroundHours}h'
        : 'Same Day';
    final testCode = test.code.isNotEmpty
        ? test.code
        : 'LAB-${test.id.length >= 4 ? test.id.substring(0, 4).toUpperCase() : "TEST"}';

    return GestureDetector(
      onTap: () => _navigateToLab(context),
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Flask Icon Box + Code & Home Sample Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFBAE6FD),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.biotech_rounded,
                      size: 20,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'CODE: $testCode',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (isHomeSampling)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFA7F3D0),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 2.5,
                                backgroundColor: Color(0xFF10B981),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Home Sample',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Test Title
            Text(
              test.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
            // Clinical Short Description
            Text(
              test.description ?? 'Certified clinical pathology diagnostic evaluation.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 6),

            // Turnaround & ISO Cert Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 11,
                        color: Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        turnaroundText,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.structuralNavy,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ISO 15189',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

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
                        fontSize: 8.5,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      'Rs. ${test.price.toInt()}',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => LabTestReviewsModal.show(
                        context,
                        test: test,
                        initialBranchId: branchId,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFBAE6FD),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_outline_rounded,
                              size: 13,
                              color: Color(0xFF0284C7),
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Reviews',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _bookLabTest(context, test),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Book Test',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                          ],
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

class _PharmacyMicroBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _PharmacyMicroBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}


/// Auto-scrolling animated carousel for featured products (moves card by card)
class _FeaturedProductsAutoCarousel extends StatefulWidget {
  final List<ProductModel> products;
  final Widget Function(BuildContext, ProductModel) itemBuilder;
  final double itemWidth;
  final double spacing;
  final double height;
  static const Duration autoPlayInterval = Duration(milliseconds: 3200);

  const _FeaturedProductsAutoCarousel({
    required this.products,
    required this.itemBuilder,
    this.itemWidth = 154.0,
    this.spacing = 12.0,
    this.height = 216.0,
  });

  @override
  State<_FeaturedProductsAutoCarousel> createState() =>
      _FeaturedProductsAutoCarouselState();
}

class _FeaturedProductsAutoCarouselState
    extends State<_FeaturedProductsAutoCarousel> {
  late final ScrollController _scrollController;
  Timer? _autoPlayTimer;
  Timer? _resumeTimer;
  bool _isInteracting = false;

  double get _step => widget.itemWidth + widget.spacing;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (widget.products.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void didUpdateWidget(covariant _FeaturedProductsAutoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products.length != widget.products.length) {
      if (widget.products.length > 1) {
        _startAutoPlay();
      } else {
        _stopAutoPlay();
      }
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.products.length <= 1) return;

    _autoPlayTimer = Timer.periodic(
      _FeaturedProductsAutoCarousel.autoPlayInterval,
      (_) {
        if (!mounted || _isInteracting || !_scrollController.hasClients) return;

        final currentOffset = _scrollController.offset;
        final nextIndex = (currentOffset / _step).round() + 1;
        final targetOffset = nextIndex * _step;

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      },
    );
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _resumeTimer?.cancel();
  }

  void _onPointerDown() {
    _isInteracting = true;
    _stopAutoPlay();
  }

  void _onPointerUp() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _isInteracting = false;
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    if (widget.products.length == 1) {
      return SizedBox(
        height: widget.height,
        child: widget.itemBuilder(context, widget.products.first),
      );
    }

    const virtualMultiplier = 1000;
    final totalItems = widget.products.length * virtualMultiplier;

    return SizedBox(
      height: widget.height,
      child: Listener(
        onPointerDown: (_) => _onPointerDown(),
        onPointerUp: (_) => _onPointerUp(),
        onPointerCancel: (_) => _onPointerUp(),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            final product = widget.products[index % widget.products.length];
            return Padding(
              padding: EdgeInsets.only(right: widget.spacing),
              child: widget.itemBuilder(context, product),
            );
          },
        ),
      ),
    );
  }
}

/// Auto-scrolling animated carousel for featured specialists (moves card by card)
class _FeaturedDoctorsAutoCarousel extends StatefulWidget {
  final List<DoctorModel> doctors;
  final Widget Function(BuildContext, DoctorModel, int) itemBuilder;
  final double itemWidth;
  final double spacing;
  final double height;
  static const Duration autoPlayInterval = Duration(milliseconds: 3200);

  const _FeaturedDoctorsAutoCarousel({
    required this.doctors,
    required this.itemBuilder,
    this.itemWidth = 240.0,
    this.spacing = 12.0,
    this.height = 160.0,
  });

  @override
  State<_FeaturedDoctorsAutoCarousel> createState() =>
      _FeaturedDoctorsAutoCarouselState();
}

class _FeaturedDoctorsAutoCarouselState
    extends State<_FeaturedDoctorsAutoCarousel> {
  late final ScrollController _scrollController;
  Timer? _autoPlayTimer;
  Timer? _resumeTimer;
  bool _isInteracting = false;

  double get _step => widget.itemWidth + widget.spacing;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (widget.doctors.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void didUpdateWidget(covariant _FeaturedDoctorsAutoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doctors.length != widget.doctors.length) {
      if (widget.doctors.length > 1) {
        _startAutoPlay();
      } else {
        _stopAutoPlay();
      }
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.doctors.length <= 1) return;

    _autoPlayTimer = Timer.periodic(
      _FeaturedDoctorsAutoCarousel.autoPlayInterval,
      (_) {
        if (!mounted || _isInteracting || !_scrollController.hasClients) return;

        final currentOffset = _scrollController.offset;
        final nextIndex = (currentOffset / _step).round() + 1;
        final targetOffset = nextIndex * _step;

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      },
    );
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _resumeTimer?.cancel();
  }

  void _onPointerDown() {
    _isInteracting = true;
    _stopAutoPlay();
  }

  void _onPointerUp() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _isInteracting = false;
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.doctors.isEmpty) return const SizedBox.shrink();

    if (widget.doctors.length == 1) {
      return SizedBox(
        height: widget.height,
        child: widget.itemBuilder(context, widget.doctors.first, 0),
      );
    }

    const virtualMultiplier = 1000;
    final totalItems = widget.doctors.length * virtualMultiplier;

    return SizedBox(
      height: widget.height,
      child: Listener(
        onPointerDown: (_) => _onPointerDown(),
        onPointerUp: (_) => _onPointerUp(),
        onPointerCancel: (_) => _onPointerUp(),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            final realIndex = index % widget.doctors.length;
            final doctor = widget.doctors[realIndex];
            return Padding(
              padding: EdgeInsets.only(right: widget.spacing),
              child: widget.itemBuilder(context, doctor, realIndex),
            );
          },
        ),
      ),
    );
  }
}

/// Auto-scrolling animated carousel for featured lab tests (moves card by card)
class _FeaturedLabTestsAutoCarousel extends StatefulWidget {
  final List<LabTestModel> tests;
  final Widget Function(BuildContext, LabTestModel) itemBuilder;
  final double itemWidth;
  final double spacing;
  final double height;
  static const Duration autoPlayInterval = Duration(milliseconds: 3200);

  const _FeaturedLabTestsAutoCarousel({
    required this.tests,
    required this.itemBuilder,
    this.itemWidth = 240.0,
    this.spacing = 12.0,
    this.height = 164.0,
  });

  @override
  State<_FeaturedLabTestsAutoCarousel> createState() =>
      _FeaturedLabTestsAutoCarouselState();
}

class _FeaturedLabTestsAutoCarouselState
    extends State<_FeaturedLabTestsAutoCarousel> {
  late final ScrollController _scrollController;
  Timer? _autoPlayTimer;
  Timer? _resumeTimer;
  bool _isInteracting = false;

  double get _step => widget.itemWidth + widget.spacing;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (widget.tests.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void didUpdateWidget(covariant _FeaturedLabTestsAutoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tests.length != widget.tests.length) {
      if (widget.tests.length > 1) {
        _startAutoPlay();
      } else {
        _stopAutoPlay();
      }
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.tests.length <= 1) return;

    _autoPlayTimer = Timer.periodic(
      _FeaturedLabTestsAutoCarousel.autoPlayInterval,
      (_) {
        if (!mounted || _isInteracting || !_scrollController.hasClients) return;

        final currentOffset = _scrollController.offset;
        final nextIndex = (currentOffset / _step).round() + 1;
        final targetOffset = nextIndex * _step;

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      },
    );
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _resumeTimer?.cancel();
  }

  void _onPointerDown() {
    _isInteracting = true;
    _stopAutoPlay();
  }

  void _onPointerUp() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _isInteracting = false;
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tests.isEmpty) return const SizedBox.shrink();

    if (widget.tests.length == 1) {
      return SizedBox(
        height: widget.height,
        child: widget.itemBuilder(context, widget.tests.first),
      );
    }

    const virtualMultiplier = 1000;
    final totalItems = widget.tests.length * virtualMultiplier;

    return SizedBox(
      height: widget.height,
      child: Listener(
        onPointerDown: (_) => _onPointerDown(),
        onPointerUp: (_) => _onPointerUp(),
        onPointerCancel: (_) => _onPointerUp(),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            final test = widget.tests[index % widget.tests.length];
            return Padding(
              padding: EdgeInsets.only(right: widget.spacing),
              child: widget.itemBuilder(context, test),
            );
          },
        ),
      ),
    );
  }
}
