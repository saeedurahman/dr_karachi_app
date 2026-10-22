import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/assets/app_icons.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../pharmacy/presentation/cubit/cart_cubit.dart';
import '../../../pharmacy/presentation/pages/pharmacy_screen.dart';
import '../../../lab/presentation/pages/lab_screen.dart';
import '../../../doctors/presentation/pages/doctors_screen.dart';
import '../../../profile/presentation/pages/my_health_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PharmacyScreen(),
    const DoctorsScreen(),
    const LabScreen(),
    const MyHealthScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CartCubit>().loadCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Required for glassmorphism to show background under nav
      body: Stack(
        children: [
          // Background subtle gradient/color for premium feel
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.canvasBase, AppColors.surfaceVariant],
              ),
            ),
          ),
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  Widget _buildGlassBottomNav() {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomInset > 0 ? bottomInset + 6 : 20,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72), // Tier 2 Glassmorphic Float
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.structuralNavy.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(child: _buildNavItem(0, AppIcons.home, 'Home')),
                Expanded(child: _buildNavItem(1, AppIcons.pharmacy, 'Pharmacy')),
                Expanded(child: _buildNavItem(2, AppIcons.doctor, 'Doctors')),
                Expanded(child: _buildNavItem(3, AppIcons.lab, 'Lab Tests')),
                Expanded(child: _buildNavItem(4, AppIcons.health, 'My Health')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String svgData, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primaryAccent : AppColors.secondary;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.string(
                svgData,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            )
          ],
        ),
      ),
    );
  }
}
