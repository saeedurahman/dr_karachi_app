import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/marketing_opt_in_checkbox.dart';
import '../../../home/data/models/branch_model.dart';
import '../../../home/data/models/doctor_model.dart';
import '../cubit/doctors_cubit.dart';
import '../../data/models/doctor_slot_model.dart';
import '../widgets/doctor_avatar.dart';


class BookAppointmentScreen extends StatelessWidget {
  final DoctorModel doctor;
  final BranchModel? initialBranch;

  const BookAppointmentScreen({
    super.key,
    required this.doctor,
    this.initialBranch,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DoctorsCubit>(),
      child: _BookAppointmentScreenContent(
        doctor: doctor,
        initialBranch: initialBranch,
      ),
    );
  }
}

class _BookAppointmentScreenContent extends StatefulWidget {
  final DoctorModel doctor;
  final BranchModel? initialBranch;

  const _BookAppointmentScreenContent({
    required this.doctor,
    this.initialBranch,
  });

  @override
  State<_BookAppointmentScreenContent> createState() =>
      _BookAppointmentScreenContentState();
}

class _BookAppointmentScreenContentState
    extends State<_BookAppointmentScreenContent> {
  late final List<DateTime> _next14Days;
  late DateTime _selectedDate;
  String? _selectedBranchId;
  String? _selectedTimeSlot;
  DateTime? _selectedSlotDateTime;
  final TextEditingController _notesController = TextEditingController();

  bool _isLoadingSlots = false;
  bool _isSubmitting = false;
  bool _slotTakenError = false;
  bool _marketingOptIn = false;
  List<DoctorSlotModel> _apiSlots = [];

  // Booking success data
  bool _isBookedSuccess = false;
  String? _successBranchName;
  String? _successDateTimeString;

  @override
  void initState() {
    super.initState();
    _next14Days = _generateNextNDays(14);
    _selectedDate = _next14Days.first;

    // Pick branch: from initialBranch, or doctor's first branch
    if (widget.initialBranch != null &&
        widget.doctor.branches.any((b) => b.id == widget.initialBranch!.id)) {
      _selectedBranchId = widget.initialBranch!.id;
    } else if (widget.doctor.branches.isNotEmpty) {
      _selectedBranchId = widget.doctor.branches.first.id;
    }

    _fetchSlots();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<DateTime> _generateNextNDays(int count) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(count, (index) => today.add(Duration(days: index)));
  }

  String _formatYMD(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _weekdayShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _monthShort(int month) {
    const months = [
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
    return months[month - 1];
  }

  Future<void> _fetchSlots() async {
    if (_selectedBranchId == null) return;
    setState(() {
      _isLoadingSlots = true;
      _selectedTimeSlot = null;
      _selectedSlotDateTime = null;
    });

    final cubit = context.read<DoctorsCubit>();
    final slots = await cubit.getDoctorSlots(
      doctorId: widget.doctor.id,
      branchId: _selectedBranchId!,
      date: _formatYMD(_selectedDate),
    );

    if (mounted) {
      setState(() {
        _isLoadingSlots = false;
        _apiSlots = slots;
      });
    }
  }

  Future<void> _handleConfirmBooking() async {
    if (_selectedSlotDateTime == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available time slot'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a clinic branch'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _slotTakenError = false;
    });

    final cubit = context.read<DoctorsCubit>();
    final slotIso = _selectedSlotDateTime!.toUtc().toIso8601String();

    final branchName = widget.doctor.branches
        .firstWhere(
          (b) => b.id == _selectedBranchId,
          orElse: () => widget.initialBranch ?? widget.doctor.branches.first,
        )
        .name;

    final result = await cubit.bookAppointment(
      doctorId: widget.doctor.id,
      branchId: _selectedBranchId!,
      slotDatetime: slotIso,
      notes: _notesController.text.trim(),
      marketingOptIn: _marketingOptIn,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.isSuccess) {
      setState(() {
        _isBookedSuccess = true;
        _successBranchName = branchName;
        _successDateTimeString =
            '${_weekdayShort(_selectedDate.weekday)}, ${_selectedDate.day} ${_monthShort(_selectedDate.month)} at $_selectedTimeSlot';
      });
    } else {
      if (result.isSlotTaken) {
        setState(() {
          _slotTakenError = true;
          _selectedTimeSlot = null;
          _selectedSlotDateTime = null;
        });
        _fetchSlots();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'Unable to complete appointment booking.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      appBar: AppBar(
        title: Text(
          _isBookedSuccess ? 'Booking Status' : 'Book Appointment',
          style: const TextStyle(
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isBookedSuccess
              ? _buildSuccessView()
              : _buildBookingFormView(),
        ),
      ),
    );
  }

  Widget _buildBookingFormView() {
    final feeFormatted =
        formatPkrAmount(widget.doctor.consultationFee.toInt());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Doctor Summary Card (matching website GlassCard)
          _buildDoctorSummaryCard(feeFormatted),
          const SizedBox(height: 16),

          // 2. Branch Selector Chips
          if (widget.doctor.branches.isNotEmpty) ...[
            _buildSectionTitle('Select Branch'),
            const SizedBox(height: 8),
            _buildBranchChips(),
            const SizedBox(height: 18),
          ],

          // 3. 14-Day Date Picker (Horizontal Chip Bar matching website)
          _buildSectionTitle('Select Date'),
          const SizedBox(height: 8),
          _buildDateChipBar(),
          const SizedBox(height: 20),

          // 4. Available Time Slots Grid
          _buildSectionTitle(
            'Available Slots • ${_weekdayShort(_selectedDate.weekday)}, ${_selectedDate.day} ${_monthShort(_selectedDate.month)}',
          ),
          const SizedBox(height: 10),
          _buildSlotsGrid(),
          const SizedBox(height: 20),

          // 5. Reason for Visit (Optional Notes)
          _buildSectionTitle('Reason for Visit (Optional)'),
          const SizedBox(height: 8),
          _buildNotesField(),
          const SizedBox(height: 18),

          // WhatsApp Marketing Opt-In Checkbox
          MarketingOptInCheckbox(
            value: _marketingOptIn,
            onChanged: (val) {
              setState(() {
                _marketingOptIn = val;
              });
            },
          ),
          const SizedBox(height: 24),

          // 6. Confirm Appointment Button
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildDoctorSummaryCard(String feeFormatted) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Doctor Avatar
          DoctorAvatar(
            doctor: widget.doctor,
            size: 54,
            borderRadius: 14,
            showOnlineIndicator: widget.doctor.isActive,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.fullName,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.structuralNavy,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.doctor.specialization,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.doctor.qualification,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.secondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Fee',
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
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.structuralNavy,
        letterSpacing: -0.01,
      ),
    );
  }

  Widget _buildBranchChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.doctor.branches.map((b) {
        final isSelected = _selectedBranchId == b.id;
        return GestureDetector(
          onTap: () {
            if (_selectedBranchId != b.id) {
              setState(() => _selectedBranchId = b.id);
              _fetchSlots();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryAccent : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryAccent
                    : AppColors.structuralNavy.withValues(alpha: 0.12),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryAccent.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: isSelected ? Colors.white : AppColors.primaryAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  b.name,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.structuralNavy,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

    Widget _buildDateChipBar() {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _next14Days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = _next14Days[index];
          final isSelected = _formatYMD(day) == _formatYMD(_selectedDate);
          final isToday = index == 0;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = day);
              _fetchSlots();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryAccent
                    : isToday
                        ? const Color(0xFFFFF1F2)
                        : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryAccent
                      : isToday
                          ? const Color(0xFFFECDD3)
                          : AppColors.structuralNavy.withValues(alpha: 0.1),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryAccent.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _weekdayShort(day.weekday).toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.9)
                          : isToday
                              ? const Color(0xFFBE123C)
                              : AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? const Color(0xFFBE123C)
                              : AppColors.structuralNavy,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _monthShort(day.month).toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotsGrid() {
    if (_isLoadingSlots) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.structuralNavy.withValues(alpha: 0.08),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_slotTakenError) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Color(0xFFD97706),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This slot was just taken — please choose another time. The list has been refreshed.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_apiSlots.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.structuralNavy.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 36,
                  color: AppColors.primaryAccent.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.doctor.fullName} has no availability on this day.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.structuralNavy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Please try selecting another date or clinic branch.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _apiSlots.map((slot) {
              final isAvailable = slot.isAvailable;
              final isSelected = _selectedSlotDateTime == slot.slotDatetime;
              final timeLabel = slot.formattedTime;

              return GestureDetector(
                onTap: isAvailable
                    ? () {
                        setState(() {
                          _selectedTimeSlot = timeLabel;
                          _selectedSlotDateTime = slot.slotDatetime;
                          _slotTakenError = false;
                        });
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: !isAvailable
                        ? const Color(0xFFF1F5F9)
                        : isSelected
                            ? AppColors.primaryAccent
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: !isAvailable
                          ? const Color(0xFFE2E8F0)
                          : isSelected
                              ? AppColors.primaryAccent
                              : AppColors.structuralNavy
                                  .withValues(alpha: 0.12),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryAccent
                                  .withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        !isAvailable
                            ? Icons.block_rounded
                            : Icons.schedule_rounded,
                        size: 13,
                        color: !isAvailable
                            ? const Color(0xFF94A3B8)
                            : isSelected
                                ? Colors.white
                                : AppColors.secondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: !isAvailable
                              ? const Color(0xFF94A3B8)
                              : isSelected
                                  ? Colors.white
                                  : AppColors.structuralNavy,
                          decoration:
                              !isAvailable ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (!isAvailable) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '(Booked)',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          color: AppColors.structuralNavy,
        ),
        decoration: InputDecoration(
          hintText: 'e.g. Follow-up consultation, chest discomfort, fever...',
          hintStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            color: AppColors.secondary.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleConfirmBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Confirm Appointment',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ???? Success Confirmation View (matching website SuccessScreen) ????
  Widget _buildSuccessView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Ringed Checkmark
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFECDD3),
                width: 8,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                size: 44,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Headline
          const Text(
            'Appointment Requested',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.structuralNavy,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your booking has been submitted successfully to the clinic.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 24),

          // Appointment Summary Card
          Container(
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
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow(
                  icon: Icons.medical_services_rounded,
                  title: widget.doctor.fullName,
                  subtitle: widget.doctor.specialization,
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  icon: Icons.location_on_rounded,
                  title: _successBranchName ?? 'Hospital Branch',
                  subtitle: 'In-person clinic consultation',
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  icon: Icons.schedule_rounded,
                  title: _successDateTimeString ?? 'Slot Time',
                  subtitle: 'Reporting time 10 mins prior',
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 13, color: Color(0xFF0D9488)),
                      SizedBox(width: 4),
                      Text(
                        'Pending Confirmation',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Callout note banner matching website
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Color(0xFFBE123C),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'What happens next: A hospital staff member will verify your slot and confirm within 30 minutes.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: Color(0xFF881337),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Primary action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.structuralNavy,
                      side: BorderSide(
                        color: AppColors.structuralNavy.withValues(alpha: 0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Browse Doctors',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.structuralNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: AppColors.primaryAccent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
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
      ],
    );
  }
}

String formatPkrAmount(int amount) {
  final str = amount.toString();
  final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
  return str.replaceAllMapped(reg, (match) => ',');
}

