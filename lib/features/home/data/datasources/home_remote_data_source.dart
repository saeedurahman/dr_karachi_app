import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/appointment_model.dart';
import '../models/branch_model.dart';
import '../models/doctor_model.dart';
import '../models/lab_test_model.dart';
import '../models/product_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<BranchModel>> getBranches();
  Future<List<DoctorModel>> getDoctors({String? branchId});
  Future<List<ProductModel>> getFeaturedProducts({String? branchId});
  Future<List<LabTestModel>> getLabTests({String? branchId});
  Future<AppointmentModel?> getActiveAppointment();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<BranchModel>> getBranches() async {
    if (kDebugMode) {
      debugPrint('[HomeRemoteDataSource] Fetching branches from: ${ApiConstants.branches}');
    }
    try {
      final res = await apiClient.dio.get(ApiConstants.branches);
      if (kDebugMode) {
        debugPrint('[HomeRemoteDataSource] Branches response status: ${res.statusCode}');
      }

      List<dynamic> list = [];
      if (res.data is Map && res.data['items'] != null) {
        list = res.data['items'] as List<dynamic>;
      } else if (res.data is List) {
        list = res.data as List<dynamic>;
      }

      if (kDebugMode) {
        debugPrint('[HomeRemoteDataSource] Found ${list.length} raw branch items in response');
      }
      final branches = <BranchModel>[];
      for (var i = 0; i < list.length; i++) {
        try {
          final b = BranchModel.fromJson(list[i] as Map<String, dynamic>);
          branches.add(b);
          if (kDebugMode) {
            debugPrint('[HomeRemoteDataSource] -> Parsed branch: ${b.name} (${b.city})');
          }
        } catch (err, stack) {
          if (kDebugMode) {
            debugPrint('[HomeRemoteDataSource] -> Error parsing branch at index $i: $err\n$stack');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('[HomeRemoteDataSource] Successfully loaded ${branches.length} branches');
      }
      return branches;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[HomeRemoteDataSource] Failed to fetch branches: $e\n$stack');
      }
      return [];
    }
  }


  @override
  Future<List<DoctorModel>> getDoctors({String? branchId}) async {
    try {
      final res = await apiClient.dio.get(
        ApiConstants.doctors,
        queryParameters: branchId != null ? {'branch_id': branchId} : null,
      );
      if (res.data is List) {
        return (res.data as List<dynamic>)
            .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (res.data is Map && res.data['items'] != null) {
        final list = res.data['items'] as List<dynamic>;
        return list.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({String? branchId}) async {
    try {
      final res = await apiClient.dio.get(
        ApiConstants.products,
        queryParameters: {
          'page': 1,
          'page_size': 8,
          'branch_id': ?branchId,
        },
      );
      if (res.data is Map && res.data['items'] != null) {
        final list = res.data['items'] as List<dynamic>;
        return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<LabTestModel>> getLabTests({String? branchId}) async {
    try {
      final res = await apiClient.dio.get(
        ApiConstants.labTests,
        queryParameters: {
          'page': 1,
          'limit': 10,
          'branch_id': ?branchId,
        },
      );
      if (res.data is Map && res.data['items'] != null) {
        final list = res.data['items'] as List<dynamic>;
        return list.map((e) => LabTestModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<AppointmentModel?> getActiveAppointment() async {
    try {
      final res = await apiClient.dio.get(
        ApiConstants.appointments,
        queryParameters: {'limit': 1},
      );
      if (res.data is Map && res.data['items'] != null) {
        final list = res.data['items'] as List<dynamic>;
        if (list.isNotEmpty) {
          return AppointmentModel.fromJson(list.first as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
