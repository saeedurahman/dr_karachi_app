import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';

/// Modal bottom sheet to pick, preview, and upload medical prescriptions
class PrescriptionUploadModal extends StatefulWidget {
  final String? branchId;
  final String? branchName;
  final VoidCallback? onCompleted;

  const PrescriptionUploadModal({
    super.key,
    this.branchId,
    this.branchName,
    this.onCompleted,
  });

  /// Static helper to easily show the modal from any screen or widget
  static Future<void> show(
    BuildContext context, {
    String? branchId,
    String? branchName,
    VoidCallback? onCompleted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PrescriptionUploadModal(
        branchId: branchId,
        branchName: branchName,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<PrescriptionUploadModal> createState() =>
      _PrescriptionUploadModalState();
}

enum _UploadStep { selectSource, previewImage, uploading, success }

class _PrescriptionUploadModalState extends State<PrescriptionUploadModal> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  _UploadStep _step = _UploadStep.selectSource;
  XFile? _selectedImage;
  String? _trackingId;
  String? _errorMessage;

  @override
  void dispose() {
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (picked != null) {
        setState(() {
          _selectedImage = picked;
          _step = _UploadStep.previewImage;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}. Please check permissions in phone settings.';
      });
    }
  }

  Future<void> _submitPrescription() async {
    if (_selectedImage == null) return;

    setState(() {
      _step = _UploadStep.uploading;
      _errorMessage = null;
    });

    // Simulate reliable upload process (e.g. multipart/network transmission)
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    final id =
        'RX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    setState(() {
      _trackingId = id;
      _step = _UploadStep.success;
    });

    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Step views
              switch (_step) {
                _UploadStep.selectSource => _buildSelectSourceStep(),
                _UploadStep.previewImage => _buildPreviewStep(),
                _UploadStep.uploading => _buildUploadingStep(),
                _UploadStep.success => _buildSuccessStep(),
              },
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. Select Source Step ---
  Widget _buildSelectSourceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                color: AppColors.primaryAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Prescription',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.structuralNavy,
                    ),
                  ),
                  Text(
                    widget.branchName != null
                        ? 'Fulfilling via ${widget.branchName}'
                        : 'Our licensed pharmacist will review & dispense',
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
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 18, color: Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),

        // Camera option
        _buildActionTile(
          icon: Icons.camera_alt_rounded,
          iconColor: AppColors.primaryAccent,
          iconBg: const Color(0xFFFFF1F2),
          title: 'Take a Photo',
          subtitle: 'Capture your doctor prescription clearly with phone camera',
          onTap: () => _pickImage(ImageSource.camera),
        ),
        const SizedBox(height: 10),

        // Gallery option
        _buildActionTile(
          icon: Icons.photo_library_rounded,
          iconColor: const Color(0xFF0284C7),
          iconBg: const Color(0xFFE0F2FE),
          title: 'Choose from Gallery',
          subtitle: 'Select JPG or PNG prescription image from phone gallery',
          onTap: () => _pickImage(ImageSource.gallery),
        ),
        const SizedBox(height: 16),

        // Safety info box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.verified_user_rounded,
                size: 18,
                color: Color(0xFF0D9488),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Valid PMDC / DRAP doctor prescription is required. All uploaded data is 100% confidential and reviewed only by licensed pharmacists.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.secondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. Preview & Details Step ---
  Widget _buildPreviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Review Prescription',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _step = _UploadStep.selectSource;
                  _selectedImage = null;
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text(
                'Retake',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryAccent,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Image Preview Canvas
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: _selectedImage != null
                ? (kIsWeb
                    ? Image.network(
                        _selectedImage!.path,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ))
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 14),

        // Optional Phone Number
        const Text(
          'Contact / WhatsApp Number',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.structuralNavy,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13),
          decoration: InputDecoration(
            hintText: 'e.g. 0300 1234567 (Pharmacist will call to confirm)',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            prefixIcon: const Icon(Icons.phone_outlined, size: 18),
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryAccent),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Optional Patient Instructions / Notes
        const Text(
          'Instructions for Pharmacist (Optional)',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.structuralNavy,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _notesController,
          maxLines: 2,
          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13),
          decoration: InputDecoration(
            hintText: 'e.g. Need 5 days course, generic alternative is ok...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryAccent),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Submit Button
        GestureDetector(
          onTap: _submitPrescription,
          child: Container(
            height: 46,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send_rounded, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Submit to Pharmacist',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.02,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. Uploading Progress Step ---
  Widget _buildUploadingStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation(AppColors.primaryAccent),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Transmitting Prescription...',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Encrypting document & routing to Karachi Labs dispensary',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. Success Confirmation Step ---
  Widget _buildSuccessStep() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF059669),
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Prescription Submitted!',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.structuralNavy,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        if (_trackingId != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Tracking ID: $_trackingId',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          'Our licensed pharmacist has received your prescription and will review it immediately. You will be contacted via WhatsApp / phone with medicine availability and delivery details.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12.5,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.structuralNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.structuralNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
