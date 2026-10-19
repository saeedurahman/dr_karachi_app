import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../home/data/models/lab_test_model.dart';
import 'lab_accreditations_sheet.dart';

enum LabCollectionMode { homeSample, walkInCenter }

class BookLabTestModal extends StatefulWidget {
  final LabTestModel test;
  final String? initialBranchId;

  const BookLabTestModal({
    super.key,
    required this.test,
    this.initialBranchId,
  });

  static Future<void> show(
    BuildContext context, {
    required LabTestModel test,
    String? initialBranchId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookLabTestModal(
        test: test,
        initialBranchId: initialBranchId,
      ),
    );
  }

  @override
  State<BookLabTestModal> createState() => _BookLabTestModalState();
}

class _BookLabTestModalState extends State<BookLabTestModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  late LabCollectionMode _collectionMode;
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = '07:00 AM - 09:30 AM (Fasting)';
  String _selectedBranch = 'Main Campus - Saddar';
  bool _isSubmitting = false;

  final List<String> _branches = const [
    'Main Campus - Saddar',
    'Clifton Diagnostic Wing',
    'Gulshan Medical Center',
    'Quetta Diagnostic Hub',
  ];

  final List<String> _timeSlots = const [
    '07:00 AM - 09:30 AM (Fasting)',
    '10:00 AM - 01:00 PM (Morning)',
    '03:00 PM - 06:30 PM (Evening)',
  ];

  @override
  void initState() {
    super.initState();
    _collectionMode = widget.test.homeSamplingAvailable
        ? LabCollectionMode.homeSample
        : LabCollectionMode.walkInCenter;

    // Prefill from Auth if authenticated
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      _nameController.text = authState.user.fullName;
      _phoneController.text = authState.user.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _requiresFasting {
    final lower = '${widget.test.name} ${widget.test.code} ${widget.test.description ?? ""}'
        .toLowerCase();
    return lower.contains('glucose') ||
        lower.contains('sugar') ||
        lower.contains('lipid') ||
        lower.contains('cholesterol') ||
        lower.contains('fbs') ||
        lower.contains('fasting') ||
        lower.contains('triglyceride');
  }

  double get _totalPrice {
    if (_collectionMode == LabCollectionMode.homeSample) {
      return widget.test.price + widget.test.homeSamplingFee;
    }
    return widget.test.price;
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]}';
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0284C7),
              onPrimary: Colors.white,
              onSurface: AppColors.structuralNavy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate clinical dispatch processing
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final referenceId =
        'LAB-2026-${(1000 + Random().nextInt(9000)).toString()}';

    final bookedName = _nameController.text.trim();
    final bookedDate = _formatDate(_selectedDate);
    final bookedSlot = _selectedTimeSlot;
    final bookedMode = _collectionMode == LabCollectionMode.homeSample
        ? 'Home Sample Collection'
        : 'Walk-in Center ($_selectedBranch)';
    final bookedTotal = _totalPrice;

    Navigator.of(context).pop(); // Close bottom sheet

    // Show Confirmation Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildBookingSuccessDialog(
        ctx,
        referenceId: referenceId,
        patientName: bookedName,
        date: bookedDate,
        timeSlot: bookedSlot,
        mode: bookedMode,
        totalPrice: bookedTotal,
      ),
    );
  }

  Widget _buildBookingSuccessDialog(
    BuildContext ctx, {
    required String referenceId,
    required String patientName,
    required String date,
    required String timeSlot,
    required String mode,
    required double totalPrice,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebratory Green Checkmark Aura
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFA7F3D0), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 38,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lab Test Booked!',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.structuralNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Booking Ref: $referenceId',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0284C7),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildSuccessRow('Test', widget.test.name),
                  const SizedBox(height: 8),
                  _buildSuccessRow('Patient', patientName),
                  const SizedBox(height: 8),
                  _buildSuccessRow('Date & Time', '$date • $timeSlot'),
                  const SizedBox(height: 8),
                  _buildSuccessRow('Collection', mode),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),
                  _buildSuccessRow(
                    'Total Payable',
                    'Rs. ${totalPrice.toStringAsFixed(0)}',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 15,
                  color: Color(0xFF0284C7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Certified phlebotomist will contact you before arrival. Reports will be uploaded digitally within ${widget.test.turnaroundHours ?? 24} hours.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: AppColors.secondary.withValues(alpha: 0.9),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
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

  Widget _buildSuccessRow(String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontFamily: isHighlight ? 'Plus Jakarta Sans' : 'DM Sans',
              fontSize: isHighlight ? 14 : 12,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight
                  ? const Color(0xFF0284C7)
                  : AppColors.structuralNavy,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.biotech_rounded,
                          color: Color(0xFF0284C7),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Book Diagnostic Test',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.structuralNavy,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Scrollable Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Test Summary Hero Card
                    _buildTestHeroCard(),
                    const SizedBox(height: 14),

                    // Fasting Advisory Notice (Smart detection)
                    if (_requiresFasting) ...[
                      _buildFastingAlert(),
                      const SizedBox(height: 14),
                    ],

                    // 2. Collection Mode Selector (Home Sample vs Walk-in)
                    const Text(
                      'Collection Method',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCollectionModeSelector(),
                    const SizedBox(height: 16),

                    // 3. Branch Selection
                    const Text(
                      'Diagnostic Center / Branch',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBranchDropdown(),
                    const SizedBox(height: 16),

                    // 4. Preferred Date
                    const Text(
                      'Preferred Date',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDateSelector(),
                    const SizedBox(height: 16),

                    // 5. Preferred Time Slot
                    const Text(
                      'Preferred Time Slot',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTimeSlotSelector(),
                    const SizedBox(height: 16),

                    // 6. Patient Information Form
                    const Text(
                      'Patient Details',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPatientForm(),
                    const SizedBox(height: 16),

                    // 7. Clinical Accreditations Strip
                    const Text(
                      'Certified Quality Standards',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildAccreditationsMiniRow(),
                    const SizedBox(height: 18),

                    // 8. Cost Breakdown & Confirm Button
                    _buildPriceAndConfirmSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestHeroCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.biotech_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.test.code.isNotEmpty
                            ? widget.test.code
                            : 'LAB TEST',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    if (widget.test.turnaroundHours != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.test.turnaroundHours}h Result',
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.test.name,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.structuralNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Standard Fee: Rs. ${widget.test.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastingAlert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD97706),
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Fasting Recommended: 8 to 12 hours overnight fasting before sample collection for accurate blood glucose & lipid markers.',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11.5,
                color: Color(0xFF92400E),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionModeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildModeCard(
            mode: LabCollectionMode.homeSample,
            title: 'Home Sampling',
            subtitle: widget.test.homeSamplingFee > 0
                ? '+Rs. ${widget.test.homeSamplingFee.toStringAsFixed(0)}'
                : 'FREE Collection',
            icon: Icons.home_work_rounded,
            enabled: widget.test.homeSamplingAvailable,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildModeCard(
            mode: LabCollectionMode.walkInCenter,
            title: 'Walk-in Center',
            subtitle: 'Visit Lab Branch',
            icon: Icons.local_hospital_rounded,
            enabled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required LabCollectionMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
  }) {
    final isSelected = _collectionMode == mode;

    return GestureDetector(
      onTap: enabled
          ? () {
              setState(() => _collectionMode = mode);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE0F2FE)
              : (enabled ? Colors.white : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0284C7)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? const Color(0xFF0284C7)
                      : (enabled
                          ? AppColors.structuralNavy
                          : AppColors.secondary),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF0284C7),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: enabled
                    ? AppColors.structuralNavy
                    : AppColors.secondary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0284C7)
                    : (enabled
                        ? const Color(0xFF059669)
                        : AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBranch,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.structuralNavy,
          ),
          items: _branches
              .map(
                (b) => DropdownMenuItem(
                  value: b,
                  child: Text(b),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedBranch = val);
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfter = today.add(const Duration(days: 2));

    final dates = [today, tomorrow, dayAfter];

    return Row(
      children: [
        ...dates.map((d) {
          final isSelected = _selectedDate.year == d.year &&
              _selectedDate.month == d.month &&
              _selectedDate.day == d.day;

          final label = d == today
              ? 'Today'
              : (d == tomorrow ? 'Tomorrow' : _formatDate(d).split(',')[0]);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedDate = d),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0284C7)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0284C7)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppColors.structuralNavy,
                        ),
                      ),
                      Text(
                        '${d.day}/${d.month}',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        IconButton.outlined(
          icon: const Icon(Icons.calendar_month_rounded, size: 20),
          color: const Color(0xFF0284C7),
          style: IconButton.styleFrom(
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _pickCustomDate,
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelector() {
    return Column(
      children: _timeSlots.map((slot) {
        final isSelected = _selectedTimeSlot == slot;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedTimeSlot = slot),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE0F2FE)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0284C7)
                      : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 18,
                    color: isSelected
                        ? const Color(0xFF0284C7)
                        : AppColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF0369A1)
                            : AppColors.structuralNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatientForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Patient Full Name *',
            hintText: 'e.g. Muhammad Ali',
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter patient name' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone / WhatsApp *',
            hintText: 'e.g. 0300 1234567',
            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Please enter contact number'
              : null,
        ),
        if (_collectionMode == LabCollectionMode.homeSample) ...[
          const SizedBox(height: 10),
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Home Sample Collection Address *',
              hintText: 'House/Flat #, Street, Area, Landmark...',
              prefixIcon: const Icon(Icons.home_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (v) {
              if (_collectionMode == LabCollectionMode.homeSample &&
                  (v == null || v.trim().isEmpty)) {
                return 'Please provide home address for sample collection';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 10),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Special Notes / Instructions (Optional)',
            hintText: 'e.g. Elderly patient, call before arriving',
            prefixIcon: const Icon(Icons.notes_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAccreditationsMiniRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: LabAccreditation.all
            .map(
              (acc) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: LabAccreditationButtonChip(
                  accreditation: acc,
                  compact: true,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPriceAndConfirmSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Test Price',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Rs. ${widget.test.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.structuralNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Home Phlebotomy Fee',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                _collectionMode == LabCollectionMode.homeSample
                    ? (widget.test.homeSamplingFee > 0
                        ? 'Rs. ${widget.test.homeSamplingFee.toStringAsFixed(0)}'
                        : 'FREE')
                    : 'N/A (Walk-in)',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payable',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.structuralNavy,
                ),
              ),
              Text(
                'Rs. ${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0284C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.bookmark_added_rounded, size: 20),
              label: Text(
                _isSubmitting ? 'Confirming...' : 'Confirm Test Booking',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
