import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/models/patient_appointment_model.dart';
import '../../data/models/patient_lab_report_model.dart';
import '../../data/models/patient_order_model.dart';
import '../widgets/cancel_appointment_dialog.dart';
import '../widgets/edit_profile_modal.dart';
import '../../../../core/widgets/stat_count_up_text.dart';
import '../../../lab/presentation/widgets/lab_accreditations_sheet.dart';

class MyHealthScreen extends StatefulWidget {
  const MyHealthScreen({super.key});

  @override
  State<MyHealthScreen> createState() => _MyHealthScreenState();
}

class _MyHealthScreenState extends State<MyHealthScreen> {
  int _activeTabIndex = 0; // 0: Appointments, 1: Labs, 2: Orders, 3: Settings

  List<PatientAppointmentModel> _appointments = [];
  bool _isLoadingAppointments = true;

  List<PatientLabReportModel> _labReports = [];
  bool _isLoadingLabs = true;

  List<PatientOrderModel> _orders = [];
  bool _isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    _fetchAppointments();
    _fetchLabReports();
    _fetchOrders();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoadingAppointments = true);
    try {
      final dataSource = sl<ProfileRemoteDataSource>();
      final list = await dataSource.getAppointments();
      if (mounted) {
        setState(() {
          _appointments = list;
          _isLoadingAppointments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAppointments = false);
    }
  }

  Future<void> _fetchLabReports() async {
    setState(() => _isLoadingLabs = true);
    try {
      final dataSource = sl<ProfileRemoteDataSource>();
      final list = await dataSource.getLabReports();
      if (mounted) {
        setState(() {
          _labReports = list;
          _isLoadingLabs = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLabs = false);
    }
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoadingOrders = true);
    try {
      final dataSource = sl<ProfileRemoteDataSource>();
      final list = await dataSource.getOrders();
      if (mounted) {
        setState(() {
          _orders = list;
          _isLoadingOrders = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingOrders = false);
    }
  }

  Future<void> _handleDownloadLabReport(PatientLabReportModel report) async {
    try {
      final dataSource = sl<ProfileRemoteDataSource>();
      final url = await dataSource.getLabReportDownloadUrl(report.id);
      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        bool launched = false;
        try {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {}
        if (!launched) {
          try {
            launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
          } catch (_) {}
        }
        if (launched) return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open report download URL.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open report download URL.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
          builder: (context, state) {
            final user = state is Authenticated ? state.user : null;

            return RefreshIndicator(
              color: const Color(0xFF0284C7),
              onRefresh: _loadAllData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Patient Profile Header Card
                    _buildProfileHeader(context, user),
                    const SizedBox(height: 16),

                    // 2. Tab Navigation Bar
                    _buildNavigationTabs(),
                    const SizedBox(height: 16),

                    // 3. Tab Body
                    _buildActiveTabContent(user),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel? user) {
    final fullName = user?.fullName ?? 'Patient';
    final firstName = fullName.split(' ').first;
    final phone = user?.phone ?? '—';
    final email = user?.email;
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'P';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with verified badge
              Stack(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0D9488)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0F172A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Patient Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Welcome back \n $firstName',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          // child: const Row(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     Icon(
                          //       Icons.verified_rounded,
                          //       size: 9,
                          //       color: Color(0xFF34D399),
                          //     ),
                          //     SizedBox(width: 2),
                          //     Text(
                          //       'Active',
                          //       style: TextStyle(
                          //         fontFamily: 'DM Sans',
                          //         fontSize: 8.5,
                          //         fontWeight: FontWeight.w700,
                          //         color: Color(0xFF34D399),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 11,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          phone,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                      ],
                    ),
                    if (email != null && email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.mail_rounded,
                            size: 11,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Edit Profile Button
              if (user != null)
                InkWell(
                  onTap: () => EditProfileModal.show(context, user: user),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFF334155)),
          const SizedBox(height: 10),

          // Portal Highlights Ribbon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRibbonItem(
                label: 'Appointments',
                count: '${_appointments.length}',
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFF2DD4BF),
              ),
              Container(width: 1, height: 24, color: const Color(0xFF334155)),
              _buildRibbonItem(
                label: 'Lab Reports',
                count: '${_labReports.length}',
                icon: Icons.biotech_rounded,
                color: const Color(0xFF38BDF8),
              ),
              Container(width: 1, height: 24, color: const Color(0xFF334155)),
              _buildRibbonItem(
                label: 'Pharmacy Orders',
                count: '${_orders.length}',
                icon: Icons.shopping_bag_outlined,
                color: const Color(0xFFF472B6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRibbonItem({
    required String label,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 9.5,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.structuralNavy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton(0, 'Appointments', Icons.calendar_today_rounded),
          _buildTabButton(1, 'Lab Reports', Icons.biotech_rounded),
          _buildTabButton(2, 'Orders', Icons.receipt_long_rounded),
          _buildTabButton(3, 'Support', Icons.headset_mic_rounded),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _activeTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0284C7) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.secondary,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(UserModel? user) {
    switch (_activeTabIndex) {
      case 0:
        return _buildAppointmentsSection();
      case 1:
        return _buildLabReportsSection();
      case 2:
        return _buildOrdersSection();
      case 3:
      default:
        return _buildSettingsSection(user);
    }
  }

  // ================= 1. APPOINTMENTS TAB =================
  Widget _buildAppointmentsSection() {
    if (_isLoadingAppointments) {
      return _buildLoadingState('Loading your appointments...');
    }

    if (_appointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today_rounded,
        iconColor: const Color(0xFF0D9488),
        title: 'No Appointments Scheduled',
        subtitle: 'You do not have any pending or past doctor consultations. Book an appointment with verified consultants in-clinic or online.',
        actionLabel: 'Find a Specialist',
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please select Doctors tab from the bottom navigation.',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF0D9488),
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Consultations (${_appointments.length})',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.structuralNavy,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              color: AppColors.secondary,
              onPressed: _fetchAppointments,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._appointments.map((appt) => _buildAppointmentCard(appt)),
      ],
    );
  }

  Widget _buildAppointmentCard(PatientAppointmentModel appt) {
    final isUpcoming = appt.status == 'confirmed' || appt.status == 'pending';

    // Status colors
    Color statusBg;
    Color statusText;
    String statusTitle;

    switch (appt.status.toLowerCase()) {
      case 'confirmed':
        statusBg = const Color(0xFFD1FAE5);
        statusText = const Color(0xFF065F46);
        statusTitle = 'Confirmed';
        break;
      case 'completed':
        statusBg = const Color(0xFFE0F2FE);
        statusText = const Color(0xFF0369A1);
        statusTitle = 'Completed';
        break;
      case 'cancelled':
        statusBg = const Color(0xFFFEE2E2);
        statusText = const Color(0xFF991B1B);
        statusTitle = 'Cancelled';
        break;
      case 'no_show':
        statusBg = const Color(0xFFFEF3C7);
        statusText = const Color(0xFF92400E);
        statusTitle = 'No Show';
        break;
      case 'pending':
      default:
        statusBg = const Color(0xFFF1F5F9);
        statusText = const Color(0xFF475569);
        statusTitle = 'Pending Review';
        break;
    }

    final dateStr =
        '${appt.slotDatetime.day}/${appt.slotDatetime.month}/${appt.slotDatetime.year}';
    final hour = appt.slotDatetime.hour > 12
        ? appt.slotDatetime.hour - 12
        : (appt.slotDatetime.hour == 0 ? 12 : appt.slotDatetime.hour);
    final ampm = appt.slotDatetime.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = appt.slotDatetime.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minuteStr $ampm';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUpcoming
              ? const Color(0xFF0D9488).withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor & Status row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
                child: Text(
                  appt.doctorName.isNotEmpty ? appt.doctorName[0] : 'D',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF0D9488),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt.doctorName,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    Text(
                      appt.doctorSpecialization,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11.5,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusTitle,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Date, Time & Branch
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: Color(0xFF0D9488),
              ),
              const SizedBox(width: 5),
              Text(
                '$dateStr • $timeStr',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.structuralNavy,
                ),
              ),
              const Spacer(),
              if (appt.doctorFee > 0)
                Text(
                  'Fee: Rs. ${appt.doctorFee.toInt()}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${appt.branchName}, ${appt.branchCity}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),

          if (appt.canCancel) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final cancelled = await CancelAppointmentDialog.show(
                    context,
                    appointment: appt,
                  );
                  if (cancelled == true) {
                    _fetchAppointments();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment has been cancelled.'),
                        backgroundColor: Color(0xFFDC2626),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.close_rounded, size: 14),
                label: const Text(
                  'Cancel Slot',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================= 2. LAB REPORTS TAB =================
  Widget _buildLabReportsSection() {
    if (_isLoadingLabs) {
      return _buildLoadingState('Fetching certified lab reports...');
    }

    if (_labReports.isEmpty) {
      return _buildEmptyState(
        icon: Icons.biotech_rounded,
        iconColor: const Color(0xFF0284C7),
        title: 'No Diagnostic Reports Found',
        subtitle: 'Diagnostic test reports verified by our CAP and ISO 15189 accredited pathology lab will appear here automatically with secure 1-click download.',
        actionLabel: 'Book Diagnostic Test',
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please select Lab Tests tab from the bottom navigation.',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF0284C7),
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pathology Reports (${_labReports.length})',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.structuralNavy,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              color: AppColors.secondary,
              onPressed: _fetchLabReports,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._labReports.map((report) => _buildLabReportCard(report)),
      ],
    );
  }

  Widget _buildLabReportCard(PatientLabReportModel report) {
    final dateStr =
        '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFF0284C7),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.testName,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            report.testCode,
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Dated: $dateStr',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 10,
                      color: Color(0xFF059669),
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Signed',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ISO 15189 • CAP Certified',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF059669),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _handleDownloadLabReport(report),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.download_rounded, size: 14),
                label: const Text(
                  'Download PDF',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= 3. PHARMACY ORDERS TAB =================
  Widget _buildOrdersSection() {
    if (_isLoadingOrders) {
      return _buildLoadingState('Loading prescription & pharmacy orders...');
    }

    if (_orders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.medication_rounded,
        iconColor: AppColors.primaryAccent,
        title: 'No Pharmacy Orders Yet',
        subtitle: 'Order genuine temperature-controlled medicines and prescription drugs with certified pharmacist dispatch and doorstep tracking.',
        actionLabel: 'Order Medicines',
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please select Pharmacy tab from the bottom navigation.',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primaryAccent,
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Orders (${_orders.length})',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.structuralNavy,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              color: AppColors.secondary,
              onPressed: _fetchOrders,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._orders.map((ord) => _buildOrderCard(ord)),
      ],
    );
  }

  Widget _buildOrderCard(PatientOrderModel order) {
    Color statusBg;
    Color statusText;
    String statusTitle;

    switch (order.status.toLowerCase()) {
      case 'delivered':
        statusBg = const Color(0xFFD1FAE5);
        statusText = const Color(0xFF065F46);
        statusTitle = 'Delivered';
        break;
      case 'out_for_delivery':
        statusBg = const Color(0xFFFEF3C7);
        statusText = const Color(0xFF92400E);
        statusTitle = 'Out for Delivery';
        break;
      case 'processing':
      case 'confirmed':
        statusBg = const Color(0xFFE0F2FE);
        statusText = const Color(0xFF0369A1);
        statusTitle = 'Processing';
        break;
      case 'cancelled':
        statusBg = const Color(0xFFFEE2E2);
        statusText = const Color(0xFF991B1B);
        statusTitle = 'Cancelled';
        break;
      case 'pending':
      default:
        statusBg = const Color(0xFFF1F5F9);
        statusText = const Color(0xFF475569);
        statusTitle = 'Pending';
        break;
    }

    final dateStr =
        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';
    final shortId = order.id.length > 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.structuralNavy.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    size: 16,
                    color: Color(0xFF0284C7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Order #$shortId',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.structuralNavy,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusTitle,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Placed on $dateStr • ${order.paymentMethod.toUpperCase()}',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Items summary
          if (order.items.isNotEmpty) ...[
            ...order.items.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.productName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: AppColors.structuralNavy,
                        ),
                      ),
                    ),
                    Text(
                      'Rs. ${item.lineTotal.toInt()}',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.structuralNavy,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (order.items.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+ ${order.items.length - 3} more items',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            const SizedBox(height: 10),
          ],

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount Paid',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Rs. ${order.grandTotal.toInt()}',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0284C7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= 4. SUPPORT & SETTINGS TAB =================
  Widget _buildSettingsSection(UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clinical Helpline & Care Support',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.structuralNavy,
          ),
        ),
        const SizedBox(height: 10),

        // 24/7 Helpline Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF4F46E5),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '24/7 Patient Care Hotline',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.structuralNavy,
                          ),
                        ),
                        Text(
                          '0319-1353930 / 0310-8665561',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => launchUrl(Uri.parse('tel:03191353930')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Call Now',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Color(0xFF16A34A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WhatsApp Clinical Desk',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.structuralNavy,
                          ),
                        ),
                        Text(
                          'Quick prescription & report help',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => launchUrl(
                      Uri.parse('https://wa.me/923108665561'),
                      mode: LaunchMode.externalApplication,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF16A34A),
                      side: const BorderSide(color: Color(0xFF16A34A)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'WhatsApp',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Standards & Privacy
        const Text(
          'Security, Medical Privacy & Accreditations',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.structuralNavy,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingItem(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF0D9488),
                title: 'Data Privacy & Clinical Compliance',
                subtitle: 'Your medical health records are encrypted at rest & transit',
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildSettingItem(
                icon: Icons.verified_outlined,
                iconColor: const Color(0xFF0284C7),
                title: 'Healthcare Network',
                subtitle: '5 centres across Balochistan • 60+ years legacy',
              ),
              const SizedBox(height: 12),
              const Text(
                'ACCREDITATIONS & CERTIFICATIONS',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: LabAccreditation.certificationNames.map((name) {
                  return CertificationBadge(name: name, compact: true);
                }).toList(),
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              // Count-Up Stat Highlight (100,000+ monthly tests)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC92A2A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.science_rounded,
                        size: 18,
                        color: Color(0xFFC92A2A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatCountUpText(
                            target: 100000,
                            suffix: '+',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFC92A2A),
                            ),
                          ),
                          const Text(
                            'Lab tests processed monthly',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildSettingItem(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.secondary,
                title: 'App Version',
                subtitle: 'Karachi Lab Pharmacy Healthcare v1.0.0',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Logout Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              backgroundColor: const Color(0xFFFEF2F2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text(
              'Sign Out of Patient Account',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            color: AppColors.structuralNavy,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out of your healthcare portal?',
          style: TextStyle(fontFamily: 'DM Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'DM Sans'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMMON HELPERS =================
  Widget _buildLoadingState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.structuralNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: AppColors.secondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
