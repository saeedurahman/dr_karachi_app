import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/appointment_model.dart';
import '../models/branch_model.dart';
import '../models/doctor_model.dart';
import '../models/lab_test_model.dart';
import '../models/product_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BranchModel>> getBranches() => remoteDataSource.getBranches();

  @override
  Future<List<DoctorModel>> getDoctors({String? branchId}) =>
      remoteDataSource.getDoctors(branchId: branchId);

  @override
  Future<List<ProductModel>> getFeaturedProducts({String? branchId}) =>
      remoteDataSource.getFeaturedProducts(branchId: branchId);

  @override
  Future<List<LabTestModel>> getLabTests({String? branchId}) =>
      remoteDataSource.getLabTests(branchId: branchId);

  @override
  Future<AppointmentModel?> getActiveAppointment() =>
      remoteDataSource.getActiveAppointment();
}
