import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/data/models/doctor_model.dart';
import '../../data/models/doctor_slot_model.dart';
import '../../domain/repositories/doctors_repository.dart';
import 'doctors_state.dart';

class AppointmentBookingResult {
  final bool isSuccess;
  final String? errorMessage;
  final bool isSlotTaken;
  final Map<String, dynamic>? data;

  const AppointmentBookingResult({
    required this.isSuccess,
    this.errorMessage,
    this.isSlotTaken = false,
    this.data,
  });
}

class DoctorsCubit extends Cubit<DoctorsState> {
  final DoctorsRepository repository;

  DoctorsCubit({required this.repository}) : super(DoctorsInitial());

  String? _currentBranchId;
  String? _currentSpecialization;

  Future<void> loadDoctors({
    String? branchId,
    String? initialSpecialization,
  }) async {
    if (branchId != null) _currentBranchId = branchId;
    if (initialSpecialization != null) {
      _currentSpecialization = initialSpecialization;
    }
    emit(DoctorsLoading());

    try {
      final doctors = await repository.getDoctors(branchId: _currentBranchId);
      if (isClosed) return;

      // Extract unique specializations
      final specsSet = <String>{'All'};
      for (final doc in doctors) {
        if (doc.specialization.isNotEmpty) {
          specsSet.add(doc.specialization);
        }
      }

      final specsList = specsSet.toList();
      String selectedSpec = 'All';
      if (_currentSpecialization != null &&
          _currentSpecialization!.isNotEmpty &&
          _currentSpecialization != 'All') {
        final target = _currentSpecialization!.toLowerCase();
        final matched = specsList.firstWhere(
          (s) {
            final specLower = s.toLowerCase();
            return specLower == target ||
                specLower.contains(target) ||
                target.contains(specLower);
          },
          orElse: () => 'All',
        );
        selectedSpec = matched;
      }

      final filtered = _applyFilters(doctors, selectedSpec, '');

      emit(DoctorsLoaded(
        allDoctors: doctors,
        filteredDoctors: filtered,
        specializations: specsList,
        selectedSpecialization: selectedSpec,
        searchQuery: '',
      ));
    } catch (_) {
      if (isClosed) return;
      emit(DoctorsError('Failed to load doctors list. Please try again.'));
    }
  }

  void selectSpecialization(String specialization) {
    _currentSpecialization = specialization;
    final currentState = state;
    if (currentState is! DoctorsLoaded) return;

    final filtered = _applyFilters(
      currentState.allDoctors,
      specialization,
      currentState.searchQuery,
    );

    emit(currentState.copyWith(
      selectedSpecialization: specialization,
      filteredDoctors: filtered,
    ));
  }

  void search(String query) {
    final currentState = state;
    if (currentState is! DoctorsLoaded) return;

    final filtered = _applyFilters(
      currentState.allDoctors,
      currentState.selectedSpecialization,
      query,
    );

    emit(currentState.copyWith(
      searchQuery: query,
      filteredDoctors: filtered,
    ));
  }

  List<DoctorModel> _applyFilters(
    List<DoctorModel> doctors,
    String specialization,
    String query,
  ) {
    return doctors.where((doc) {
      final matchesSearch = query.trim().isEmpty ||
          doc.fullName.toLowerCase().contains(query.trim().toLowerCase()) ||
          doc.specialization.toLowerCase().contains(query.trim().toLowerCase()) ||
          doc.qualification.toLowerCase().contains(query.trim().toLowerCase());

      if (!matchesSearch) return false;

      if (specialization != 'All' &&
          doc.specialization.toLowerCase() != specialization.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<List<DoctorSlotModel>> getDoctorSlots({
    required String doctorId,
    required String branchId,
    required String date,
  }) async {
    try {
      return await repository.getSlots(
        doctorId: doctorId,
        branchId: branchId,
        date: date,
      );
    } catch (_) {
      return [];
    }
  }

  Future<AppointmentBookingResult> bookAppointment({
    required String doctorId,
    required String branchId,
    required String slotDatetime,
    String? notes,
    bool marketingOptIn = false,
  }) async {
    try {
      final res = await repository.bookAppointment(
        doctorId: doctorId,
        branchId: branchId,
        slotDatetime: slotDatetime,
        notes: notes,
        marketingOptIn: marketingOptIn,
      );
      return AppointmentBookingResult(
        isSuccess: true,
        data: res,
      );
    } catch (e) {
      String message = 'Unable to book appointment. Please try again.';
      bool isSlotTaken = false;

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (statusCode == 409) {
          isSlotTaken = true;
          message = 'This slot was just taken — please choose another time.';
        } else if (statusCode == 401) {
          message = 'Please sign in to book an appointment.';
        } else if (data is Map && data['detail'] != null) {
          final detail = data['detail'];
          if (detail is String) {
            message = detail;
          } else if (detail is List && detail.isNotEmpty) {
            message = detail.first['msg']?.toString() ?? message;
          }
        }
      }

      return AppointmentBookingResult(
        isSuccess: false,
        errorMessage: message,
        isSlotTaken: isSlotTaken,
      );
    }
  }


  Future<void> refresh() async {
    await loadDoctors(
      branchId: _currentBranchId,
      initialSpecialization: _currentSpecialization,
    );
  }
}
