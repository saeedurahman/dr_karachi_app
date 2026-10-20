import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/branch_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class ClinicsLocationsScreen extends StatelessWidget {
  final String? initialBranchId;
  final List<BranchModel>? initialBranches;

  const ClinicsLocationsScreen({
    super.key,
    this.initialBranchId,
    this.initialBranches,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..loadHomeData(branchId: initialBranchId),
      child: _ClinicsLocationsScreenContent(
        initialBranchId: initialBranchId,
        fallbackBranches: initialBranches ?? [],
      ),
    );
  }
}

class _ClinicsLocationsScreenContent extends StatefulWidget {
  final String? initialBranchId;
  final List<BranchModel> fallbackBranches;

  const _ClinicsLocationsScreenContent({
    this.initialBranchId,
    required this.fallbackBranches,
  });

  @override
  State<_ClinicsLocationsScreenContent> createState() =>
      _ClinicsLocationsScreenContentState();
}

class _ClinicsLocationsScreenContentState
    extends State<_ClinicsLocationsScreenContent> {
  String _selectedCity = 'All';

  Future<void> _openDirections(BuildContext context, BranchModel branch) async {
    final urlString = branch.getDirectionsUrl();
    final uri = Uri.parse(urlString);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening maps for ${branch.name}...'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.structuralNavy,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Directions: ${branch.address}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.structuralNavy,
          ),
        );
      }
    }
  }

  Future<void> _callBranch(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Call: $phone'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      appBar: AppBar(
        title: const Text(
          'Our Locations',
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
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final branches = (state is HomeLoaded && state.branches.isNotEmpty)
              ? state.branches
              : widget.fallbackBranches;

          debugPrint(
            '[ClinicsLocationsScreen] Build with state: ${state.runtimeType}, '
            'branches loaded: ${branches.length}, fallback: ${widget.fallbackBranches.length}',
          );

          final isLoading = state is HomeLoading && branches.isEmpty;
          final isError = state is HomeError && branches.isEmpty;

          // Unique cities
          final cities = <String>['All'];
          for (final b in branches) {
            if (b.city.isNotEmpty && !cities.contains(b.city)) {
              cities.add(b.city);
            }
          }

          final filtered = branches.where((b) {
            if (_selectedCity == 'All') return true;
            return b.city.toLowerCase() == _selectedCity.toLowerCase();
          }).toList();

          return RefreshIndicator(
            color: AppColors.primaryAccent,
            onRefresh: () => context
                .read<HomeCubit>()
                .loadHomeData(branchId: widget.initialBranchId),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // 1. Header Banner
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
                                color: AppColors.primaryAccent
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_city_rounded,
                                color: AppColors.primaryAccent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hospital & Clinic Branches',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.structuralNavy,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Pharmacy, lab sample collection & doctor clinics',
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

                        // City Filter Chips (Dynamic from branches API)
                        if (cities.length > 1) ...[
                          Row(
                            children: [
                              const Text(
                                'CITY:',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: cities.map((city) {
                                      final isSelected = _selectedCity == city;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() => _selectedCity = city);
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 7,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primaryAccent
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primaryAccent
                                                    : AppColors.structuralNavy
                                                        .withValues(alpha: 0.12),
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: AppColors
                                                            .primaryAccent
                                                            .withValues(
                                                          alpha: 0.25,
                                                        ),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 3),
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                            child: Text(
                                              city,
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
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),

                // 2. State & Branches List
                if (isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primaryAccent,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Loading clinic branches...',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isError)
                  SliverFillRemaining(
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
                            const Text(
                              'Unable to load branches',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.structuralNavy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Please check your connection and try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<HomeCubit>()
                                  .loadHomeData(
                                    branchId: widget.initialBranchId,
                                  ),
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
                  )
                else if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_off_rounded,
                              size: 44,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No branches found in "$_selectedCity"',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.structuralNavy,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => setState(() => _selectedCity = 'All'),
                              child: const Text('Show All Cities'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final branch = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildBranchCard(context, branch),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),

    );
  }

  Widget _buildBranchCard(BuildContext context, BranchModel branch) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Branch Map Visual Banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Subtle map grid graphic
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: CustomPaint(
                        painter: _GridPatternPainter(),
                      ),
                    ),
                  ),
                  // Center Map marker icon
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryAccent,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          branch.name,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Top right city badge
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        branch.city,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Branch Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branch Name
                Text(
                  branch.name,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.structuralNavy,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),

                // Physical Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.primaryAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        branch.address.isNotEmpty
                            ? branch.address
                            : 'Healthcare Facility, ${branch.city}',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: AppColors.secondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Phone numbers (Split on "/" and show as two tappable call buttons)
                if (branch.phoneList.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: branch.phoneList.map((ph) {
                      return GestureDetector(
                        onTap: () => _callBranch(context, ph),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.phone_in_talk_rounded,
                                size: 14,
                                color: Color(0xFF0D9488),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                ph,
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0D9488),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D9488),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Call',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                ],

                // Working Hours (Hide gracefully when empty)
                if (branch.hasWorkingHours) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          [
                            if (branch.workingHoursMonSat != null && branch.workingHoursMonSat!.trim().isNotEmpty)
                              branch.workingHoursMonSat!,
                            if (branch.workingHoursSun != null && branch.workingHoursSun!.trim().isNotEmpty)
                              branch.workingHoursSun!,
                          ].join(' • '),
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // Services Chips (if any)
                if (branch.services.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: branch.services.map((svc) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          svc,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.structuralNavy,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),

                // 3. Action Buttons: "Get Directions" and "Book Consultation"
                Row(
                  children: [
                    // Get Directions Button
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryAccent
                                  .withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _openDirections(context, branch),
                          icon: const Icon(
                            Icons.near_me_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Get Directions',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Copy / Share address button
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Branch: ${branch.name}, ${branch.address}',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.structuralNavy,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(42, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: AppColors.structuralNavy
                              .withValues(alpha: 0.15),
                        ),
                      ),

                      child: const Icon(
                        Icons.share_location_rounded,
                        size: 16,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
