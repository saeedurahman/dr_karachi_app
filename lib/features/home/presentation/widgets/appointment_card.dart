import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/doctor_model.dart';
import 'auto_rotating_carousel.dart';

class AppointmentCard extends StatefulWidget {
  final AppointmentModel? appointment;
  final List<DoctorModel> doctors;
  final DoctorModel? featuredDoctor;
  final BranchModel? selectedBranch;
  final VoidCallback? onCheckIn;
  final VoidCallback? onBookConsultation;
  final ValueChanged<DoctorModel>? onBookDoctor;
  final VoidCallback? onDirections;

  const AppointmentCard({
    super.key,
    this.appointment,
    this.doctors = const [],
    this.featuredDoctor,
    this.selectedBranch,
    this.onCheckIn,
    this.onBookConsultation,
    this.onBookDoctor,
    this.onDirections,
  });

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  int _currentDoctorIndex = 0;

  static final List<DoctorModel> _defaultDoctors = [
    DoctorModel(
      id: 'doc-imran',
      fullName: 'Dr. Imran Chaudhry',
      specialization: 'Consultant Cardiologist',
      qualification: 'FCPS, MBBS',
      experienceYears: 14,
      consultationFee: 2000,
      profileImageUrl: 'assets/images/doctors/doctor-imran-chaudhry.jpg',
    ),
    DoctorModel(
      id: 'doc-sara',
      fullName: 'Dr. Sara Malik',
      specialization: 'Consultant Gynecologist',
      qualification: 'FCPS, MRCOG',
      experienceYears: 11,
      consultationFee: 2000,
      profileImageUrl: 'assets/images/doctors/doctor-sara-malik.jpg',
    ),
    DoctorModel(
      id: 'doc-ahmed',
      fullName: 'Dr. Ahmed Siddiqui',
      specialization: 'Pediatric Specialist',
      qualification: 'MCPS, MBBS',
      experienceYears: 9,
      consultationFee: 1500,
      profileImageUrl: 'assets/images/doctors/doctor-ahmed-siddiqui.jpg',
    ),
    DoctorModel(
      id: 'doc-nadia',
      fullName: 'Dr. Nadia Hussain',
      specialization: 'Dermatologist & Cosmetologist',
      qualification: 'FCPS, Dip Derm',
      experienceYears: 8,
      consultationFee: 1800,
      profileImageUrl: 'assets/images/doctors/doctor-nadia-hussain.jpg',
    ),
  ];

  List<DoctorModel> get _resolvedDoctors {
    if (widget.doctors.isNotEmpty) {
      return widget.doctors;
    }
    if (widget.featuredDoctor != null) {
      return [widget.featuredDoctor!, ..._defaultDoctors.sublist(1)];
    }
    return _defaultDoctors;
  }

  DoctorModel? get _currentDoctor {
    final list = _resolvedDoctors;
    if (list.isEmpty) return null;
    return list[_currentDoctorIndex % list.length];
  }

  void _handleBookTap() {
    if (widget.appointment != null) {
      widget.onCheckIn?.call();
      return;
    }
    final doc = _currentDoctor;
    if (doc != null && widget.onBookDoctor != null) {
      widget.onBookDoctor!(doc);
    } else {
      widget.onBookConsultation?.call();
    }
  }

  Widget _buildDoctorAvatar(DoctorModel doc, Color accentColor) {
    String? localAsset;
    final nameLower = doc.fullName.toLowerCase();
    if (doc.profileImageUrl != null &&
        doc.profileImageUrl!.startsWith('assets/')) {
      localAsset = doc.profileImageUrl;
    } else if (nameLower.contains('imran')) {
      localAsset = 'assets/images/doctors/doctor-imran-chaudhry.jpg';
    } else if (nameLower.contains('sara') || nameLower.contains('malik')) {
      localAsset = 'assets/images/doctors/doctor-sara-malik.jpg';
    } else if (nameLower.contains('ahmed') || nameLower.contains('siddiqui')) {
      localAsset = 'assets/images/doctors/doctor-ahmed-siddiqui.jpg';
    } else if (nameLower.contains('nadia') || nameLower.contains('hussain')) {
      localAsset = 'assets/images/doctors/doctor-nadia-hussain.jpg';
    }

    final hasNetworkImage = doc.profileImageUrl != null &&
        (doc.profileImageUrl!.startsWith('http://') ||
            doc.profileImageUrl!.startsWith('https://'));

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceVariant,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: hasNetworkImage
            ? CachedNetworkImage(
                imageUrl: doc.profileImageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.primaryAccent,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildFallbackAsset(localAsset),
              )
            : _buildFallbackAsset(localAsset),
      ),
    );
  }

  Widget _buildFallbackAsset(String? assetPath) {
    return Image.asset(
      assetPath ?? 'assets/images/doctors/doctor-hero-showcase.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.person_rounded, size: 24, color: AppColors.tertiary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveAppointment = widget.appointment != null;

    final String title = hasActiveAppointment
        ? 'ACTIVE APPOINTMENT'
        : 'CONSULTATION AVAILABLE';
    final String chipText =
        hasActiveAppointment ? 'In 45 mins' : 'Instant Slot';
    final IconData chipIcon =
        hasActiveAppointment ? Icons.timer_rounded : Icons.bolt_rounded;

    final String actionText =
        hasActiveAppointment ? 'Tap to Fast Check-in' : 'Book Consultation';
    final IconData actionIcon = hasActiveAppointment
        ? Icons.how_to_reg_rounded
        : Icons.calendar_month_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status + Badge chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.onPrimaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                              letterSpacing: 0.04,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  hasActiveAppointment
                                      ? widget.appointment!.appointmentTime
                                      : 'Available Today • Next slot in 15m',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.structuralNavy,
                                    letterSpacing: 0.01,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Time / Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.tertiary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(chipIcon, size: 13, color: AppColors.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      chipText,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tertiary,
                        letterSpacing: 0.02,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Doctor info section: Animated Carousel or Active Appointment
          if (hasActiveAppointment)
            _buildActiveAppointmentRow(widget.appointment!)
          else
            _buildAnimatedDoctorsCarousel(),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _handleBookTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryAccent.withValues(
                            alpha: 0.30,
                          ),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(actionIcon, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          actionText,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.02,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onDirections,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.near_me_rounded,
                        size: 15,
                        color: AppColors.tertiary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Directions',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.structuralNavy,
                          letterSpacing: 0.02,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAppointmentRow(AppointmentModel apt) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/doctors/doctor-hero-showcase.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.person_rounded,
                  size: 24,
                  color: AppColors.tertiary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        apt.doctorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.structuralNavy,
                          letterSpacing: -0.015,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: AppColors.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${apt.specialization} • ${apt.room ?? "OPD Room 3B"}',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondary,
                    letterSpacing: 0.01,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  apt.branchName,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.01,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDoctorsCarousel() {
    final doctorsList = _resolvedDoctors;
    final accentColors = [
      AppColors.primaryAccent,
      const Color(0xFF0D9488),
      const Color(0xFF0284C7),
      const Color(0xFF7C3AED),
    ];

    final cards = <Widget>[];
    for (int i = 0; i < doctorsList.length; i++) {
      final doc = doctorsList[i];
      final accentColor = accentColors[i % accentColors.length];
      final campusInfo = doc.branches.isNotEmpty
          ? doc.branches.first.name
          : (widget.selectedBranch?.name ?? 'Quetta Main Campus');

      final expText =
          doc.experienceYears > 0 ? '${doc.experienceYears}+ Yrs' : '10+ Yrs';

      cards.add(
        GestureDetector(
          onTap: () {
            if (widget.onBookDoctor != null) {
              widget.onBookDoctor!(doc);
            } else {
              widget.onBookConsultation?.call();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.structuralNavy.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                _buildDoctorAvatar(doc, accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    doc.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.structuralNavy,
                                      letterSpacing: -0.015,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 13,
                                  color: AppColors.tertiary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Experience Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              expText,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${doc.specialization} • ${doc.qualification}',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondary,
                          letterSpacing: 0.01,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              campusInfo,
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.01,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cardAccentColors = List.generate(
      cards.length,
      (i) => accentColors[i % accentColors.length],
    );

    return AutoRotatingCarousel(
      height: 90,
      autoPlayInterval: const Duration(seconds: 4),
      showDots: true,
      dotsSpacing: 8,
      cards: cards,
      accentColors: cardAccentColors,
      onPageChanged: (index) {
        if (mounted) {
          setState(() {
            _currentDoctorIndex = index;
          });
        }
      },
    );
  }
}
