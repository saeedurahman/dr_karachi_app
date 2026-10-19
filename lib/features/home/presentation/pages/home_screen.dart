import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/models/branch_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/appointment_card.dart';

import '../widgets/healthcare_pillars.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/trust_footer.dart';
import '../../../doctors/presentation/pages/book_appointment_screen.dart';
import '../../../doctors/presentation/pages/doctor_profile_screen.dart';
import '../../../doctors/presentation/pages/doctors_screen.dart';
import '../../../lab/presentation/pages/lab_screen.dart';
import 'clinics_locations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..loadHomeData(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final String userName = authState is Authenticated
        ? authState.user.fullName.split(' ').first
        : 'Patient';

    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final isInitialLoading =
              state is HomeInitial ||
              (state is HomeLoading && (state as dynamic) is! HomeLoaded);
          final homeLoaded = state is HomeLoaded ? state : null;

          final selectedBranch = homeLoaded?.selectedBranch;
          final branchCity = selectedBranch?.city ?? 'Quetta';
          final branchDisplayName = selectedBranch != null
              ? '${selectedBranch.name.split(" ").first}, $branchCity'
              : 'KLDC';

          return RefreshIndicator(
            color: AppColors.primaryAccent,
            onRefresh: () async {
              await context.read<HomeCubit>().loadHomeData(
                branchId: selectedBranch?.id,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // â”€â”€ Glassmorphic App Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  expandedHeight: 64,
                  toolbarHeight: 64,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: ClipRect(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFE2E8F0)
                                .withValues(alpha: 0.8),
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.structuralNavy.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            // Logo from website
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/logo/logo.png',
                                width: 36,
                                height: 36,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Brand text
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Karachi Lab Pharmacy',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.structuralNavy,
                                      letterSpacing: -0.015,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 11,
                                        color: AppColors.tertiary,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        branchDisplayName,
                                        style: const TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 10,
                                          color: AppColors.secondary,
                                          letterSpacing: 0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Profile avatar
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceVariant,
                                border: Border.all(
                                  color: AppColors.primaryAccent.withValues(
                                    alpha: 0.15,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // â”€â”€ Scrollable Content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // 1. Welcome section
                      _buildWelcomeSection(
                        context,
                        userName: userName,
                        city: branchCity,
                        branches: homeLoaded?.branches ?? [],
                        selectedBranch: selectedBranch,
                      ),
                      const SizedBox(height: 14),

                      // 3. Active Appointment (Dynamic)
                      if (isInitialLoading)
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryAccent,
                              ),
                            ),
                          ),
                        )
                      else
                        AppointmentCard(
                          appointment: homeLoaded?.activeAppointment,
                          doctors: homeLoaded?.doctors ?? const [],
                          selectedBranch: selectedBranch,
                          onBookDoctor: (doc) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DoctorProfileScreen(
                                  doctor: doc,
                                ),
                              ),
                            );
                          },
                          onBookConsultation: () {
                            final doc = homeLoaded?.doctors.isNotEmpty == true
                                ? homeLoaded!.doctors.first
                                : null;
                            if (doc != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BookAppointmentScreen(
                                    doctor: doc,
                                    initialBranch: selectedBranch,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const DoctorsScreen(),
                                ),
                              );
                            }
                          },
                          onDirections: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ClinicsLocationsScreen(
                                  initialBranchId: selectedBranch?.id,
                                  initialBranches: homeLoaded?.branches ?? [],
                                ),
                              ),
                            );
                          },
                          onCheckIn: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Fast Check-in confirmed! Clinic reception notified.',
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Color(0xFF047857),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 20),

                      // 4. Healthcare Pillars (Dynamic)
                      HealthcarePillars(
                        products: homeLoaded?.products ?? [],
                        doctors: homeLoaded?.doctors ?? [],
                        labTests: homeLoaded?.labTests ?? [],
                        branchName: selectedBranch?.name,
                        branchId: selectedBranch?.id,
                        onFindSpecialist: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DoctorsScreen(),
                            ),
                          );
                        },
                        onBookHomeSampling: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LabScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // 5. Healthcare Pillars Overview (3D Animated Carousel)
                      QuickActionsGrid(
                        productsCount: homeLoaded?.products.length,
                        doctorsCount: homeLoaded?.doctors.length,
                        labTestsCount: homeLoaded?.labTests.length,
                        branchesCount: homeLoaded?.branches.length,
                      ),
                      const SizedBox(height: 20),

                      // 6. Trust Footer (60+ Years Legacy & Trust)
                      const TrustFooter(),
                      // Bottom padding so card sits comfortably above floating glassmorphic nav bar (height 72 + bottom 24)
                      const SizedBox(height: 116),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context, {
    required String userName,
    required String city,
    required List<BranchModel> branches,
    required BranchModel? selectedBranch,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C), Color(0xFF991B1B)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFC92A2A).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      'AssalamoAlaikum\n $userName',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.02,
                      ),
                    ),
                    // Verified badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.04,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Dynamic Branch selector
          _DynamicBranchSelector(
            branches: branches,
            selectedBranch: selectedBranch,
            onSelect: (branch) {
              context.read<HomeCubit>().selectBranch(branch);
            },
            onRedCard: true,
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Dynamic Branch Selector Dropdown â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DynamicBranchSelector extends StatefulWidget {
  final List<BranchModel> branches;
  final BranchModel? selectedBranch;
  final ValueChanged<BranchModel> onSelect;
  final bool onRedCard;

  const _DynamicBranchSelector({
    required this.branches,
    required this.selectedBranch,
    required this.onSelect,
    this.onRedCard = false,
  });

  @override
  State<_DynamicBranchSelector> createState() => _DynamicBranchSelectorState();
}

class _DynamicBranchSelectorState extends State<_DynamicBranchSelector> {
  bool _open = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleDropdown() {
    if (_open) {
      _removeOverlay();
      setState(() => _open = false);
    } else {
      _overlayEntry = _buildOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _open = true);
    }
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (_) => GestureDetector(
        // Tap anywhere outside â†’ close
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _removeOverlay();
          if (mounted) setState(() => _open = false);
        },
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              // Shift: right-align dropdown (220px wide) below the pill
              offset: const Offset(0, 38),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  // Prevent close when tapping inside dropdown
                  onTap: () {},
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.structuralNavy.withValues(
                              alpha: 0.15,
                            ),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(12, 10, 12, 4),
                            child: Text(
                              'SELECT HOSPITAL BRANCH',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                                letterSpacing: 0.08,
                              ),
                            ),
                          ),
                          ...widget.branches.map((b) {
                            final isActive = widget.selectedBranch?.id == b.id;
                            return GestureDetector(
                              onTap: () {
                                _removeOverlay();
                                if (mounted) setState(() => _open = false);
                                widget.onSelect(b);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primaryContainer.withValues(
                                          alpha: 0.08,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        b.name,
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 12,
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isActive
                                              ? AppColors.primaryAccent
                                              : AppColors.structuralNavy,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isActive)
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 15,
                                        color: AppColors.primaryAccent,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
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
    final label = widget.selectedBranch != null
        ? '${widget.selectedBranch!.name.split(' ').first}, ${widget.selectedBranch!.city}'
        : 'Quetta, Balochistan';

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: widget.onRedCard
                ? Colors.white.withValues(alpha: 0.2)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: widget.onRedCard
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 0.8,
                  )
                : null,
            boxShadow: widget.onRedCard
                ? null
                : [
                    BoxShadow(
                      color: AppColors.structuralNavy.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 14,
                color: widget.onRedCard
                    ? Colors.white
                    : AppColors.primaryAccent,
              ),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.onRedCard
                        ? Colors.white
                        : AppColors.structuralNavy,
                    letterSpacing: 0.01,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.expand_more_rounded,
                  size: 16,
                  color: widget.onRedCard
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
