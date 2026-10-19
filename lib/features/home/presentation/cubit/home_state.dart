import '../../data/models/appointment_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/lab_test_model.dart';
import '../../data/models/product_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<BranchModel> branches;
  final BranchModel? selectedBranch;
  final List<DoctorModel> doctors;
  final List<ProductModel> products;
  final List<LabTestModel> labTests;
  final AppointmentModel? activeAppointment;

  HomeLoaded({
    required this.branches,
    this.selectedBranch,
    required this.doctors,
    required this.products,
    required this.labTests,
    this.activeAppointment,
  });

  HomeLoaded copyWith({
    List<BranchModel>? branches,
    BranchModel? selectedBranch,
    List<DoctorModel>? doctors,
    List<ProductModel>? products,
    List<LabTestModel>? labTests,
    AppointmentModel? activeAppointment,
  }) {
    return HomeLoaded(
      branches: branches ?? this.branches,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      doctors: doctors ?? this.doctors,
      products: products ?? this.products,
      labTests: labTests ?? this.labTests,
      activeAppointment: activeAppointment ?? this.activeAppointment,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
