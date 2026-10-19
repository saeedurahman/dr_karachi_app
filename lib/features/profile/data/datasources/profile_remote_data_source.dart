import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/patient_appointment_model.dart';
import '../models/patient_lab_report_model.dart';
import '../models/patient_order_model.dart';

abstract class ProfileRemoteDataSource {
  Future<List<PatientAppointmentModel>> getAppointments();
  Future<void> cancelAppointment({
    required String appointmentId,
    String? cancellationReason,
  });
  Future<List<PatientLabReportModel>> getLabReports();
  Future<String?> getLabReportDownloadUrl(String reportId);
  Future<List<PatientOrderModel>> getOrders();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PatientAppointmentModel>> getAppointments() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.appointments);
      if (response.data is Map && response.data['items'] != null) {
        final list = response.data['items'] as List<dynamic>;
        return list
            .map((e) => PatientAppointmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cancelAppointment({
    required String appointmentId,
    String? cancellationReason,
  }) async {
    try {
      await apiClient.dio.patch(
        '${ApiConstants.appointments}/$appointmentId/status',
        data: {
          'status': 'cancelled',
          if (cancellationReason != null && cancellationReason.trim().isNotEmpty)
            'cancellation_reason': cancellationReason.trim(),
        },
      );
    } on DioException catch (e) {
      String message = 'Failed to cancel appointment';
      if (e.response?.data is Map && e.response?.data['detail'] != null) {
        message = e.response!.data['detail'].toString();
      }
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<PatientLabReportModel>> getLabReports() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.labReports);
      if (response.data is Map && response.data['items'] != null) {
        final list = response.data['items'] as List<dynamic>;
        return list
            .map((e) => PatientLabReportModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<String?> getLabReportDownloadUrl(String reportId) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiConstants.labReports}/$reportId/download',
      );
      if (response.data is Map && response.data['download_url'] != null) {
        return response.data['download_url'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PatientOrderModel>> getOrders() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.orders);
      if (response.data is Map && response.data['items'] != null) {
        final list = response.data['items'] as List<dynamic>;
        return list
            .map((e) => PatientOrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.data is List) {
        final list = response.data as List<dynamic>;
        return list
            .map((e) => PatientOrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
