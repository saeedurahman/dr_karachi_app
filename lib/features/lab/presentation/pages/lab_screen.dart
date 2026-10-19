import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/lab_test_model.dart';
import '../cubit/lab_cubit.dart';
import '../cubit/lab_state.dart';
import '../widgets/book_lab_test_modal.dart';
import '../widgets/lab_accreditations_sheet.dart';
import '../widgets/lab_test_card.dart';

class LabScreen extends StatelessWidget {
  final String? initialBranchId;

  const LabScreen({super.key, this.initialBranchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LabCubit>()..loadLabTests(branchId: initialBranchId),
      child: _LabScreenContent(initialBranchId: initialBranchId),
    );
  }
}

class _LabScreenContent extends StatefulWidget {
  final String? initialBranchId;
  const _LabScreenContent({this.initialBranchId});

  @override
  State<_LabScreenContent> createState() => _LabScreenContentState();
}

class _LabScreenContentState extends State<_LabScreenContent> {
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
      context.read<LabCubit>().search(query);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Packages', 'Home Sampling', 'Fast Reports'];

    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF0284C7),
          onRefresh: () => context.read<LabCubit>().refresh(),
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
                              color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.biotech_rounded,
                              color: Color(0xFF0284C7),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diagnostic Laboratory',
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
                                  'Certified Pathology • Home Sample Collection',
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

                      // Home Sampling Highlight Banner
                      _buildHomeSamplingBanner(context),
                      const SizedBox(height: 12),

                      // Certified Accreditations Strip (ISO, CAP, PNRA, NQA, SINDH HC, BALOCHISTAN HC)
                      _buildAccreditationsHeaderStrip(),
                      const SizedBox(height: 14),

                      // Search Bar
                      _buildSearchBar(),
                      const SizedBox(height: 12),

                      // Filter Pills
                      BlocBuilder<LabCubit, LabState>(
                        builder: (context, state) {
                          final selectedCategory = state is LabLoaded
                              ? state.selectedCategory
                              : 'All';

                          return SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                final isSelected = selectedCategory == cat;

                                return GestureDetector(
                                  onTap: () {
                                    context.read<LabCubit>().selectCategory(cat);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF0284C7)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF0284C7)
                                            : AppColors.structuralNavy
                                                .withValues(alpha: 0.12),
                                      ),
                                    ),
                                    child: Text(
                                      cat,
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
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Tests List or Status
              BlocBuilder<LabCubit, LabState>(
                builder: (context, state) {
                  if (state is LabLoading) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    );
                  }

                  if (state is LabError) {
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
                                color: Color(0xFF0284C7),
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
                                    context.read<LabCubit>().refresh(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
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

                  if (state is LabLoaded) {
                    if (state.filteredTests.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.biotech_outlined,
                                  size: 56,
                                  color:
                                      AppColors.secondary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No lab tests found',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.structuralNavy,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Try searching with a test code (e.g. CBC, LFT) or resetting filters.',
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
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final test = state.filteredTests[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: LabTestCard(
                                test: test,
                                onBookTap: () => BookLabTestModal.show(
                                  context,
                                  test: test,
                                  initialBranchId: widget.initialBranchId,
                                ),
                              ),
                            );
                          },
                          childCount: state.filteredTests.length,
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
          hintText: 'Search test name (e.g. CBC, COVID PCR, Vitamin D)...',
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

  Widget _buildHomeSamplingBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0284C7).withValues(alpha: 0.08),
            const Color(0xFF0284C7).withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF0284C7).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.home_repair_service_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book Free Home Sample Collection',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.structuralNavy,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Trained phlebotomist with sterile kit arrives at your home',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              final cubitState = context.read<LabCubit>().state;
              final defaultTest = cubitState is LabLoaded &&
                      cubitState.allTests.isNotEmpty
                  ? cubitState.allTests.first
                  : LabTestModel(
                      id: 'home-sample-routine',
                      name: 'Routine Diagnostic & Blood Panel',
                      code: 'LAB-ROUTINE',
                      description:
                          'Comprehensive doorstep collection by certified sterile phlebotomist.',
                      price: 1200.0,
                      homeSamplingAvailable: true,
                      homeSamplingFee: 0.0,
                      turnaroundHours: 24,
                    );
              BookLabTestModal.show(
                context,
                test: defaultTest,
                initialBranchId: widget.initialBranchId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Request',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccreditationsHeaderStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.verified_rounded,
              size: 14,
              color: Color(0xFF0284C7),
            ),
            SizedBox(width: 5),
            Text(
              'Certified Quality Standards & Accreditations',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: LabAccreditation.all.map((acc) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: LabAccreditationButtonChip(accreditation: acc),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
