import '../../../home/data/models/doctor_model.dart';
import '../../domain/repositories/doctors_repository.dart';
import '../datasources/doctors_remote_data_source.dart';
import '../models/doctor_review_model.dart';
import '../models/doctor_slot_model.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  final DoctorsRemoteDataSource remoteDataSource;

  DoctorsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DoctorModel>> getDoctors({String? branchId, String? search}) =>
      remoteDataSource.getDoctors(branchId: branchId, search: search);

  @override
  Future<List<DoctorSlotModel>> getSlots({
    required String doctorId,
    required String branchId,
    required String date,
  }) =>
      remoteDataSource.getSlots(
        doctorId: doctorId,
        branchId: branchId,
        date: date,
      );

  @override
  Future<Map<String, dynamic>> bookAppointment({
    required String doctorId,
    required String branchId,
    required String slotDatetime,
    String? notes,
    bool marketingOptIn = false,
  }) =>
      remoteDataSource.bookAppointment(
        doctorId: doctorId,
        branchId: branchId,
        slotDatetime: slotDatetime,
        notes: notes,
        marketingOptIn: marketingOptIn,
      );

  @override
  Future<DoctorReviewSummaryModel> getDoctorReviewSummary(String doctorId) =>
      remoteDataSource.getDoctorReviewSummary(doctorId);

  @override
  Future<List<DoctorReviewItemModel>> getDoctorReviews(
    String doctorId, {
    int page = 1,
    int limit = 20,
  }) =>
      remoteDataSource.getDoctorReviews(doctorId, page: page, limit: limit);

  @override
  Future<DoctorReviewEligibilityModel?> checkReviewEligibility(String doctorId) =>
      remoteDataSource.checkReviewEligibility(doctorId);

  @override
  Future<Map<String, dynamic>> submitDoctorReview({
    required String doctorId,
    required int rating,
    String? comment,
  }) =>
      remoteDataSource.submitDoctorReview(
        doctorId: doctorId,
        rating: rating,
        comment: comment,
      );
}

