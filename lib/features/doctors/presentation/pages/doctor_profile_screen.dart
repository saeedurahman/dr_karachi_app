import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../home/data/models/doctor_model.dart';
import '../../data/models/doctor_review_model.dart';
import '../../domain/repositories/doctors_repository.dart';
import 'book_appointment_screen.dart';
import '../widgets/doctor_avatar.dart';

class DoctorProfileScreen extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorProfileScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  late final DoctorsRepository _repository;

  bool _isLoadingReviews = true;
  DoctorReviewSummaryModel _reviewSummary = DoctorReviewSummaryModel.empty();
  List<DoctorReviewItemModel> _reviews = [];
  DoctorReviewEligibilityModel? _eligibility;

  // Review Form State
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingReview = false;
  bool _reviewSubmittedSuccess = false;

  final List<String> _ratingLabels = [
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
  ];

  @override
  void initState() {
    super.initState();
    _repository = sl<DoctorsRepository>();
    _loadReviewsData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviewsData() async {
    setState(() => _isLoadingReviews = true);

    try {
      final summaryFuture = _repository.getDoctorReviewSummary(widget.doctor.id);
      final reviewsFuture = _repository.getDoctorReviews(widget.doctor.id);
      final eligibilityFuture = _repository.checkReviewEligibility(widget.doctor.id);

      final results = await Future.wait([
        summaryFuture,
        reviewsFuture,
        eligibilityFuture,
      ]);

      if (mounted) {
        setState(() {
          _reviewSummary = results[0] as DoctorReviewSummaryModel;
          _reviews = results[1] as List<DoctorReviewItemModel>;
          _eligibility = results[2] as DoctorReviewEligibilityModel?;

          // If user previously reviewed, prefill rating & comment
          if (_eligibility?.existingReview != null) {
            _selectedRating = _eligibility!.existingReview!.rating;
            if (_eligibility!.existingReview!.comment != null) {
              _commentController.text = _eligibility!.existingReview!.comment!;
            }
          }
          _isLoadingReviews = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  Future<void> _handleSubmitReview() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      _showLoginPrompt();
      return;
    }

    if (_selectedRating < 1 || _selectedRating > 5) return;

    setState(() => _isSubmittingReview = true);

    try {
      await _repository.submitDoctorReview(
        doctorId: widget.doctor.id,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _isSubmittingReview = false;
        _reviewSubmittedSuccess = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Your rating & review has been submitted.'),
          backgroundColor: Color(0xFF0D9488),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh reviews
      _loadReviewsData();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmittingReview = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit review. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLoginPrompt() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: Color(0xFFD97706), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign In Required',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.structuralNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please sign in to your account to rate and review this doctor.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign In Now',
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

  @override
  Widget build(BuildContext context) {
    final feeFormatted = widget.doctor.consultationFee.toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      appBar: AppBar(
        title: const Text(
          'Doctor Profile',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.structuralNavy,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.structuralNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.structuralNavy.withValues(alpha: 0.08),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Doctor Main Profile Hero Card
              _buildDoctorHeroCard(feeFormatted),
              const SizedBox(height: 16),

              // 2. Doctor Bio / About Section
              _buildAboutDoctorCard(),
              const SizedBox(height: 16),

              // 3. Reviews & Ratings Section
              _buildReviewsAndRatingsSection(),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomBookBar(feeFormatted),
    );
  }

  // ── Hero Profile Card ───────────────────────────────────────────────────────
  Widget _buildDoctorHeroCard(String feeFormatted) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.04),
            blurRadius: 14,
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
              // Premium Doctor Avatar
              DoctorAvatar(
                doctor: widget.doctor,
                size: 72,
                borderRadius: 20,
                showOnlineIndicator: widget.doctor.isActive,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.doctor.fullName,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.structuralNavy,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: Color(0xFF0D9488),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.doctor.specialization,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.doctor.qualification,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Stats: Experience & Fee
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.military_tech_rounded,
                  title: 'Experience',
                  value: '${widget.doctor.experienceYears} Years',
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.structuralNavy.withValues(alpha: 0.08),
              ),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.payments_rounded,
                  title: 'Consultation Fee',
                  value: 'Rs. $feeFormatted',
                  highlightValue: true,
                ),
              ),
            ],
          ),

          // Practicing Branches
          if (widget.doctor.branches.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Available Clinic Locations:',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.doctor.branches.map((b) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: Color(0xFFE11D48)),
                      const SizedBox(width: 4),
                      Text(
                        b.name,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9F1239),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String title,
    required String value,
    bool highlightValue = false,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: (highlightValue ? AppColors.primaryAccent : const Color(0xFF0D9488))
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: highlightValue ? AppColors.primaryAccent : const Color(0xFF0D9488),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                color: AppColors.secondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: highlightValue ? AppColors.primaryAccent : AppColors.structuralNavy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── About Doctor Card ───────────────────────────────────────────────────────
  Widget _buildAboutDoctorCard() {
    final bioText = (widget.doctor.bio != null && widget.doctor.bio!.trim().isNotEmpty)
        ? widget.doctor.bio!.trim()
        : 'Senior medical specialist dedicated to providing personalized clinical consultation and evidence-based treatment at Dr. Karachi clinics.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: Color(0xFF0D9488)),
              const SizedBox(width: 8),
              Text(
                'About ${widget.doctor.fullName}',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.structuralNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            bioText,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reviews & Ratings Section ───────────────────────────────────────────────
  Widget _buildReviewsAndRatingsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Row(
            children: [
              Icon(Icons.star_rounded, size: 20, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text(
                'Patient Reviews & Ratings',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.structuralNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rating Overview (Average score + breakdown bars)
          _buildRatingOverviewBox(),
          const SizedBox(height: 20),

          const Divider(height: 1),
          const SizedBox(height: 18),

          // Review Form Card
          _buildReviewFormCard(),
          const SizedBox(height: 20),

          const Divider(height: 1),
          const SizedBox(height: 18),

          // Reviews List
          _buildReviewsList(),
        ],
      ),
    );
  }

  Widget _buildRatingOverviewBox() {
    final avg = _reviewSummary.avgRating;
    final total = _reviewSummary.totalCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Big Rating Number
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              avg > 0 ? avg.toStringAsFixed(1) : '—',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: AppColors.structuralNavy,
                letterSpacing: -1,
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: (avg >= starValue)
                      ? const Color(0xFFF59E0B)
                      : (avg >= starValue - 0.5)
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFE2E8F0),
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              '$total ${total == 1 ? "review" : "reviews"}',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),

        // Right Star Breakdown Bars
        Expanded(
          child: Column(
            children: [5, 4, 3, 2, 1].map((star) {
              final count = _reviewSummary.distribution[star] ?? 0;
              final percent = total > 0 ? (count / total) : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      '$star',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star_rounded,
                        size: 11, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 20,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Write / Edit Review Form ────────────────────────────────────────────────
  Widget _buildReviewFormCard() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded,
                    color: Color(0xFFD97706), size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Sign in to leave a review and rate this doctor.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showLoginPrompt,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB45309),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_reviewSubmittedSuccess) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 16, color: Color(0xFF0D9488)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your review has been submitted successfully!',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                _eligibility?.existingReview != null
                    ? 'Update Your Review'
                    : 'Rate Your Consultation Experience',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.structuralNavy,
                ),
              ),
              const SizedBox(height: 10),

              // Interactive 5 Star Row
              Row(
                children: List.generate(5, (index) {
                  final star = index + 1;
                  final isFilled = star <= _selectedRating;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedRating = star);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.star_rounded,
                        size: 32,
                        color: isFilled
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                _ratingLabels[_selectedRating - 1],
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 12),

              // Comment text area
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: AppColors.structuralNavy,
                  ),
                  decoration: const InputDecoration(
                    hintText:
                        'Share details about consultation, diagnosis, or demeanor (optional)...',
                    hintStyle: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Submit Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isSubmittingReview ? null : _handleSubmitReview,
                  icon: _isSubmittingReview
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 14),
                  label: Text(
                    _isSubmittingReview
                        ? 'Submitting...'
                        : (_eligibility?.existingReview != null
                            ? 'Update Review'
                            : 'Submit Review'),
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Reviews List ────────────────────────────────────────────────────────────
  Widget _buildReviewsList() {
    if (_isLoadingReviews) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
          ),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 32,
              color: AppColors.secondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'No patient reviews yet',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Be the first to share your consultation experience!',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _reviews.map((rev) => _buildReviewItemCard(rev)).toList(),
    );
  }

  Widget _buildReviewItemCard(DoctorReviewItemModel review) {
    final initials = review.authorName.isNotEmpty
        ? review.authorName
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'P';

    final dateStr =
        '${review.createdAt.day} ${_monthShort(review.createdAt.month)} ${review.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.authorName,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.structuralNavy,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0D9488).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Verified Patient',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10.5,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < review.rating
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFCBD5E1),
                  );
                }),
              ),
            ],
          ),

          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!.trim(),
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12.5,
                height: 1.4,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Bottom Fixed CTA Bar ────────────────────────────────────────────────────
  Widget _buildBottomBookBar(String feeFormatted) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.structuralNavy.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consultation Fee',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  'Rs. $feeFormatted',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookAppointmentScreen(
                          doctor: widget.doctor,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthShort(int month) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return m[month - 1];
  }
}
