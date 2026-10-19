import 'package:flutter/material.dart';
import '../../../home/data/models/doctor_model.dart';

/// A reusable, premium Doctor Avatar widget that mirrors the website's
/// visual styling with graceful fallbacks (Network -> Local Asset -> Gradient Initials),
/// subtle borders, elevation shadows, active/online indicator, and optional Hero animation.
class DoctorAvatar extends StatelessWidget {
  final DoctorModel doctor;
  final double size;
  final double? borderRadius;
  final bool isCircle;
  final bool showOnlineIndicator;
  final String? heroTag;
  final Color? borderColor;
  final double borderWidth;

  const DoctorAvatar({
    super.key,
    required this.doctor,
    this.size = 52.0,
    this.borderRadius,
    this.isCircle = false,
    this.showOnlineIndicator = false,
    this.heroTag,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  /// Maps doctor's name or attributes to bundled local assets
  static String? getLocalAssetForDoctor(DoctorModel doctor) {
    if (doctor.profileImageUrl != null &&
        doctor.profileImageUrl!.trim().isNotEmpty) {
      final img = doctor.profileImageUrl!.trim();
      if (img.startsWith('assets/')) {
        return img;
      }
      if (img.startsWith('/assets/')) {
        return img.substring(1);
      }
    }

    final nameLower = doctor.fullName.toLowerCase();
    if (nameLower.contains('ahmed') || nameLower.contains('siddiqui')) {
      return 'assets/images/doctors/doctor-ahmed-siddiqui.jpg';
    } else if (nameLower.contains('nadia') || nameLower.contains('hussain')) {
      return 'assets/images/doctors/doctor-nadia-hussain.jpg';
    } else if (nameLower.contains('imran') || nameLower.contains('chaudhry')) {
      return 'assets/images/doctors/doctor-imran-chaudhry.jpg';
    } else if (nameLower.contains('sara') || nameLower.contains('malik')) {
      return 'assets/images/doctors/doctor-sara-malik.jpg';
    }

    return null;
  }

  /// Determines if doctor has a remote network URL
  static String? getNetworkUrlForDoctor(DoctorModel doctor) {
    if (doctor.profileImageUrl == null) return null;
    final url = doctor.profileImageUrl!.trim();
    if (url.isEmpty) return null;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('/static/') ||
        url.startsWith('/media/') ||
        url.startsWith('/uploads/')) {
      return 'https://drkarachibackend-production.up.railway.app$url';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = isCircle
        ? size / 2
        : (borderRadius ?? (size * 0.28));
    final defaultBorder = const Color(0xFF0D9488).withValues(alpha: 0.18);

    Widget avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color: borderColor ?? defaultBorder,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          isCircle ? effectiveRadius : (effectiveRadius - borderWidth),
        ),
        child: _buildImageOrFallback(),
      ),
    );

    if (heroTag != null && heroTag!.isNotEmpty) {
      avatarContent = Hero(
        tag: heroTag!,
        child: avatarContent,
      );
    }

    if (!showOnlineIndicator) {
      return avatarContent;
    }

    final badgeSize = (size * 0.24).clamp(10.0, 18.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarContent,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: doctor.isActive
                  ? const Color(0xFF10B981) // Emerald online
                  : const Color(0xFF94A3B8), // Muted offline
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (doctor.isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8))
                      .withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageOrFallback() {
    final networkUrl = getNetworkUrlForDoctor(doctor);
    final localAsset = getLocalAssetForDoctor(doctor);

    if (networkUrl != null) {
      return Image.network(
        networkUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (localAsset != null) {
            return _buildAssetImage(localAsset);
          }
          return _buildInitialsFallback();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
      );
    }

    if (localAsset != null) {
      return _buildAssetImage(localAsset);
    }

    return _buildInitialsFallback();
  }

  Widget _buildAssetImage(String assetPath) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildInitialsFallback();
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.35,
          height: size * 0.35,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsFallback() {
    final initial = doctor.fullName.isNotEmpty
        ? doctor.fullName
            .replaceAll('Dr. ', '')
            .replaceAll('Dr.', '')
            .trim()
            .split(' ')
            .first[0]
            .toUpperCase()
        : 'D';

    final fontSize = (size * 0.40).clamp(12.0, 32.0);

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D9488), // Teal-600
            Color(0xFF0F766E), // Teal-700
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle medical cross pattern
          Positioned(
            right: -size * 0.15,
            bottom: -size * 0.15,
            child: Icon(
              Icons.medical_services_rounded,
              size: size * 0.65,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Center(
            child: Text(
              initial,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
