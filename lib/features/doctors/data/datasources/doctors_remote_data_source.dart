import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/data/models/doctor_model.dart';
import '../models/doctor_review_model.dart';
import '../models/doctor_slot_model.dart';

abstract class DoctorsRemoteDataSource {
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

class DoctorsRemoteDataSourceImpl implements DoctorsRemoteDataSource {
  final ApiClient apiClient;

  DoctorsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DoctorModel>> getDoctors({String? branchId, String? search}) async {
    try {
      final query = <String, dynamic>{};
      if (branchId != null && branchId.isNotEmpty) {
        query['branch_id'] = branchId;
      }
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }

      final res = await apiClient.dio.get(
        ApiConstants.doctors,
        queryParameters: query.isEmpty ? null : query,
      );

      final List<DoctorModel> doctors = [];
      if (res.data is Map && res.data['value'] != null) {
        final list = res.data['value'] as List<dynamic>;
        doctors.addAll(
          list.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>)),
        );
      } else if (res.data is Map && res.data['items'] != null) {
        final list = res.data['items'] as List<dynamic>;
        doctors.addAll(
          list.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>)),
        );
      } else if (res.data is List) {
        final list = res.data as List<dynamic>;
        doctors.addAll(
          list.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>)),
        );
      }

      // Filter active doctors
      final active = doctors.where((d) => d.isActive).toList();

      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim().toLowerCase();
        return active
            .where((d) =>
                d.fullName.toLowerCase().contains(q) ||
                d.specialization.toLowerCase().contains(q) ||
                d.qualification.toLowerCase().contains(q))
            .toList();
      }

      return active;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<DoctorSlotModel>> getSlots({
    required String doctorId,
    required String branchId,
    required String date,
  }) async {
    try {
      final res = await apiClient.dio.get(
        '${ApiConstants.appointments}/slots',
        queryParameters: {
          'doctor_id': doctorId,
          'branch_id': branchId,
          'slot_date': date,
        },
      );

      if (res.data is List) {
        return (res.data as List)
            .map((e) => DoctorSlotModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> bookAppointment({
    required String doctorId,
    required String branchId,
    required String slotDatetime,
    String? notes,
    bool marketingOptIn = false,
  }) async {
    try {
      final payload = {
        'doctor_id': doctorId,
        'branch_id': branchId,
        'slot_datetime': slotDatetime,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        'marketing_opt_in': marketingOptIn,
      };

      final res = await apiClient.dio.post(
        ApiConstants.appointments,
        data: payload,
      );

      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      return {'status': 'success'};
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DoctorReviewSummaryModel> getDoctorReviewSummary(String doctorId) async {
    try {
      final res = await apiClient.dio.get(
        '${ApiConstants.reviews}/summary',
        queryParameters: {
          'target_type': 'doctor',
          'target_id': doctorId,
        },
      );
      if (res.data is Map<String, dynamic>) {
        return DoctorReviewSummaryModel.fromJson(res.data as Map<String, dynamic>);
      }
      return DoctorReviewSummaryModel.empty();
    } catch (_) {
      return DoctorReviewSummaryModel.empty();
    }
  }

  @override
  Future<List<DoctorReviewItemModel>> getDoctorReviews(
    String doctorId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await apiClient.dio.get(
        ApiConstants.reviews,
        queryParameters: {
          'target_type': 'doctor',
          'target_id': doctorId,
          'page': page,
          'limit': limit,
        },
      );
      if (res.data is Map && res.data['items'] != null) {
        final list = res.data['items'] as List<dynamic>;
        return list
            .map((e) => DoctorReviewItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<DoctorReviewEligibilityModel?> checkReviewEligibility(String doctorId) async {
    try {
      final res = await apiClient.dio.get(
        '${ApiConstants.reviews}/eligibility',
        queryParameters: {
          'target_type': 'doctor',
          'target_id': doctorId,
        },
      );
      if (res.data is Map<String, dynamic>) {
        return DoctorReviewEligibilityModel.fromJson(res.data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> submitDoctorReview({
    required String doctorId,
    required int rating,
    String? comment,
  }) async {
    try {
      final payload = {
        'target_type': 'doctor',
        'target_id': doctorId,
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      };
      final res = await apiClient.dio.post(
        ApiConstants.reviews,
        data: payload,
      );
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      return {'status': 'success'};
    } catch (e) {
      rethrow;
    }
  }
}

