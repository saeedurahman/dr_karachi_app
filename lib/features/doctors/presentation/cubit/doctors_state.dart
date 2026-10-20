import '../../../home/data/models/doctor_model.dart';

abstract class DoctorsState {}

class DoctorsInitial extends DoctorsState {}

class DoctorsLoading extends DoctorsState {}

class DoctorsLoaded extends DoctorsState {
  final List<DoctorModel> allDoctors;
  final List<DoctorModel> filteredDoctors;
  final List<String> specializations;
  final String selectedSpecialization;
  final List<String> cities;
  final String selectedCity;
  final String searchQuery;

  DoctorsLoaded({
    required this.allDoctors,
    required this.filteredDoctors,
    required this.specializations,
    this.selectedSpecialization = 'All',
    this.cities = const ['All'],
    this.selectedCity = 'All',
    this.searchQuery = '',
  });

  DoctorsLoaded copyWith({
    List<DoctorModel>? allDoctors,
    List<DoctorModel>? filteredDoctors,
    List<String>? specializations,
    String? selectedSpecialization,
    List<String>? cities,
    String? selectedCity,
    String? searchQuery,
  }) {
    return DoctorsLoaded(
      allDoctors: allDoctors ?? this.allDoctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      specializations: specializations ?? this.specializations,
      selectedSpecialization:
          selectedSpecialization ?? this.selectedSpecialization,
      cities: cities ?? this.cities,
      selectedCity: selectedCity ?? this.selectedCity,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DoctorsError extends DoctorsState {
  final String message;
  DoctorsError(this.message);
}
