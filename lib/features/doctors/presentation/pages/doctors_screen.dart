import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/doctors_cubit.dart';
import '../cubit/doctors_state.dart';
import '../widgets/doctor_card.dart';
import 'book_appointment_screen.dart';
import 'doctor_profile_screen.dart';



class DoctorsScreen extends StatelessWidget {
  final String? initialBranchId;
  final String? initialSpecialization;

  const DoctorsScreen({
    super.key,
    this.initialBranchId,
    this.initialSpecialization,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DoctorsCubit>()
        ..loadDoctors(
          branchId: initialBranchId,
          initialSpecialization: initialSpecialization,
        ),
      child: const _DoctorsScreenContent(),
    );
  }
}

class _DoctorsScreenContent extends StatefulWidget {
  const _DoctorsScreenContent();

  @override
  State<_DoctorsScreenContent> createState() => _DoctorsScreenContentState();
}

class _DoctorsScreenContentState extends State<_DoctorsScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context.read<DoctorsCubit>().search(query);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryAccent,
          onRefresh: () => context.read<DoctorsCubit>().refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // 1. Clinical Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.medical_information_rounded,
                              color: Color(0xFF0D9488),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Doctor Clinics',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.structuralNavy,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Specialist Consultants • Instant Appointment',
                                  style: TextStyle(
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
                      const SizedBox(height: 14),

                      // Doctor Search Bar
                      _buildSearchBar(),
                      const SizedBox(height: 12),

                      // City Filter Chips (Dynamic from Branches)
                      BlocBuilder<DoctorsCubit, DoctorsState>(
                        builder: (context, state) {
                          if (state is DoctorsLoaded && state.cities.length > 1) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 32,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: state.cities.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final city = state.cities[index];
                                      final isSelected =
                                          state.selectedCity == city;

                                      return GestureDetector(
                                        onTap: () {
                                          context
                                              .read<DoctorsCubit>()
                                              .selectCity(city);
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryAccent
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primaryAccent
                                                  : AppColors.structuralNavy
                                                      .withValues(alpha: 0.12),
                                            ),
                                          ),
                                          child: Text(
                                            city,
                                            style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 11.5,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppColors.structuralNavy,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Specialization Pills Filter
                      BlocBuilder<DoctorsCubit, DoctorsState>(
                        builder: (context, state) {
                          if (state is DoctorsLoaded &&
                              state.specializations.isNotEmpty) {
                            return SizedBox(
                              height: 36,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: state.specializations.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final spec = state.specializations[index];
                                  final isSelected =
                                      state.selectedSpecialization == spec;

                                  return GestureDetector(
                                    onTap: () {
                                      context
                                          .read<DoctorsCubit>()
                                          .selectSpecialization(spec);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF0D9488)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF0D9488)
                                              : AppColors.structuralNavy
                                                  .withValues(alpha: 0.12),
                                        ),
                                      ),
                                      child: Text(
                                        spec,
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.structuralNavy,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Doctors List or State View
              BlocBuilder<DoctorsCubit, DoctorsState>(
                builder: (context, state) {
                  if (state is DoctorsLoading) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    );
                  }

                  if (state is DoctorsError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: AppColors.primaryAccent,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14,
                                  color: AppColors.structuralNavy,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<DoctorsCubit>().refresh(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is DoctorsLoaded) {
                    if (state.filteredDoctors.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_search_rounded,
                                  size: 56,
                                  color:
                                      AppColors.secondary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No doctors found',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.structuralNavy,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Try searching another doctor name or resetting specialization filter.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 13,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doc = state.filteredDoctors[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DoctorCard(
                                doctor: doc,
                                onProfileTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DoctorProfileScreen(
                                        doctor: doc,
                                      ),
                                    ),
                                  );
                                },
                                onBookTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BookAppointmentScreen(
                                        doctor: doc,
                                      ),
                                    ),
                                  );
                                },
                              ),

                            );
                          },
                          childCount: state.filteredDoctors.length,
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          color: AppColors.structuralNavy,
        ),
        decoration: InputDecoration(
          hintText: 'Search by doctor name or specialization...',
          hintStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: AppColors.secondary.withValues(alpha: 0.7),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.secondary,
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    );
  }
}
