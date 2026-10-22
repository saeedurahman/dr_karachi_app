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
      final trimmedReason = cancellationReason?.trim();
      final reason = (trimmedReason != null && trimmedReason.isNotEmpty)
          ? (trimmedReason.length > 500 ? trimmedReason.substring(0, 500) : trimmedReason)
          : null;

      final payload = <String, dynamic>{
        'status': 'cancelled',
      };
      if (reason != null) {
        payload['cancellation_reason'] = reason;
      }

      await apiClient.dio.put(
        '${ApiConstants.appointments}/$appointmentId/status',
        data: payload,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      String? backendDetail;
      if (e.response?.data is Map) {
        final d = e.response!.data['detail'];
        if (d is String && d.trim().isNotEmpty) {
          backendDetail = d.trim();
        } else if (d is List && d.isNotEmpty) {
          final first = d.first;
          if (first is Map && first['msg'] != null) {
            backendDetail = first['msg'].toString();
          }
        }
      }

      String message;
      switch (statusCode) {
        case 400:
          if (backendDetail != null &&
              !backendDetail.toLowerCase().contains('not allowed')) {
            message = backendDetail;
          } else {
            message = 'This appointment can no longer be cancelled.';
          }
          break;
        case 403:
          message = 'You are not authorized to cancel this appointment.';
          break;
        case 404:
          message = 'Appointment not found or already removed.';
          break;
        case 405:
          message = 'Cancellation method not allowed by server.';
          break;
        case 409:
          message = 'This appointment can no longer be cancelled.';
          break;
        case 422:
          message = backendDetail != null
              ? 'Invalid request: $backendDetail'
              : 'Invalid cancellation request. Please check and try again.';
          break;
        default:
          if (backendDetail != null &&
              !backendDetail.toLowerCase().contains('not allowed')) {
            message = backendDetail;
          } else {
            message = 'Failed to cancel appointment. Please try again.';
          }
          break;
      }
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
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
