import '../../data/models/appointment_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/lab_test_model.dart';
import '../../data/models/product_model.dart';

abstract class HomeRepository {
  Future<List<BranchModel>> getBranches();
  Future<List<DoctorModel>> getDoctors({String? branchId});
  Future<List<ProductModel>> getFeaturedProducts({String? branchId});
  Future<List<LabTestModel>> getLabTests({String? branchId});
  Future<AppointmentModel?> getActiveAppointment();
}
