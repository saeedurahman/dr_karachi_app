import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/marketing_opt_in_checkbox.dart';
import '../../../home/data/models/doctor_model.dart';
import '../cubit/doctors_cubit.dart';
import 'doctor_avatar.dart';

class BookAppointmentModal extends StatefulWidget {
  final DoctorModel doctor;
  final DoctorsCubit cubit;

  const BookAppointmentModal({
    super.key,
    required this.doctor,
    required this.cubit,
  });

  static Future<void> show(
    BuildContext context, {
    required DoctorModel doctor,
    required DoctorsCubit cubit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookAppointmentModal(doctor: doctor, cubit: cubit),
    );
  }

  @override
  State<BookAppointmentModal> createState() => _BookAppointmentModalState();
}

class _BookAppointmentModalState extends State<BookAppointmentModal> {
  String? _selectedBranchId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = '10:00 AM';
  final TextEditingController _reasonController = TextEditingController();
  bool _isBooking = false;
  bool _marketingOptIn = false;

  final List<String> _timeSlots = [
    '10:00 AM',
    '11:30 AM',
    '02:30 PM',
    '04:00 PM',
    '06:30 PM',
    '08:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.doctor.branches.isNotEmpty) {
      _selectedBranchId = widget.doctor.branches.first.id;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a branch location'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final slotIso = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      10,
      0,
    ).toUtc().toIso8601String();

    final result = await widget.cubit.bookAppointment(
      doctorId: widget.doctor.id,
      branchId: _selectedBranchId!,
      slotDatetime: slotIso,
      notes: _reasonController.text.trim(),
      marketingOptIn: _marketingOptIn,
    );

    if (!mounted) return;
    setState(() => _isBooking = false);

    Navigator.of(context).pop();

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appointment booked with ${widget.doctor.fullName} for $dateStr at $_selectedTimeSlot!',
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'Failed to book appointment',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: 80, bottom: bottomInset),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.structuralNavy,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Doctor Info Card Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.canvasBase,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.structuralNavy.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  DoctorAvatar(
                    doctor: widget.doctor,
                    size: 46,
                    borderRadius: 12,
                    showOnlineIndicator: widget.doctor.isActive,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor.fullName,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.structuralNavy,
                          ),
                        ),
                        Text(
                          '${widget.doctor.specialization} • Rs. ${widget.doctor.consultationFee.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 1. Select Clinic Branch
            if (widget.doctor.branches.isNotEmpty) ...[
              const Text(
                'Select Clinic Branch',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.structuralNavy,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.doctor.branches.map((b) {
                  final isSelected = _selectedBranchId == b.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBranchId = b.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.structuralNavy : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.structuralNavy
                              : AppColors.structuralNavy.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        b.name,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.structuralNavy,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // 2. Select Date
            const Text(
              'Select Date',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.canvasBase,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.structuralNavy.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                  label: const Text('Change'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.structuralNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Select Time Slot
            const Text(
              'Available Time Slots',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTimeSlot = slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryAccent : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryAccent
                            : AppColors.structuralNavy.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.structuralNavy,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 4. Reason (Optional)
            const Text(
              'Reason for Visit (Optional)',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.structuralNavy,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'e.g. Regular checkup, chest discomfort, skin rash...',
                hintStyle: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  color: AppColors.secondary.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: AppColors.canvasBase,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.structuralNavy.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.structuralNavy.withValues(alpha: 0.1),
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),

            // WhatsApp Marketing Consent
            MarketingOptInCheckbox(
              value: _marketingOptIn,
              onChanged: (val) {
                setState(() {
                  _marketingOptIn = val;
                });
              },
            ),
            const SizedBox(height: 20),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isBooking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm Appointment',
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
}
