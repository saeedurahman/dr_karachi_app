import '../../../home/data/models/doctor_model.dart';
import '../../data/models/doctor_review_model.dart';
import '../../data/models/doctor_slot_model.dart';

abstract class DoctorsRepository {
  Future<List<DoctorModel>> getDoctors({String? branchId, String? search});
  Future<List<DoctorSlotModel>> getSlots({
    required String doctorId,
    required String branchId,
    required String date,
  });
  Future<Map<String, dynamic>> bookAppointment({
    required String doctorId,
    required String branchId,
    required String slotDatetime,
    String? notes,
    bool marketingOptIn = false,
  });
  Future<DoctorReviewSummaryModel> getDoctorReviewSummary(String doctorId);
  Future<List<DoctorReviewItemModel>> getDoctorReviews(
    String doctorId, {
    int page = 1,
    int limit = 20,
  });
  Future<DoctorReviewEligibilityModel?> checkReviewEligibility(String doctorId);
  Future<Map<String, dynamic>> submitDoctorReview({
    required String doctorId,
    required int rating,
    String? comment,
  });
}

