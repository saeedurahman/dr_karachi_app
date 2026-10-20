import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/lab_tests_page_response.dart';

abstract class LabRemoteDataSource {
  Future<LabTestsPageResponse> getLabTests({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? branchId,
  });

  Future<List<String>> getCategories();
}

class LabRemoteDataSourceImpl implements LabRemoteDataSource {
  final ApiClient apiClient;

  LabRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<LabTestsPageResponse> getLabTests({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? branchId,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      if (category != null && category.trim().isNotEmpty && category != 'All') {
        query['category'] = category.trim();
      }
      if (branchId != null && branchId.trim().isNotEmpty) {
        query['branch_id'] = branchId.trim();
      }

      final res = await apiClient.dio.get(
        ApiConstants.labTests,
        queryParameters: query,
      );

      if (res.data is Map<String, dynamic>) {
        return LabTestsPageResponse.fromJson(res.data as Map<String, dynamic>);
      } else if (res.data is Map) {
        return LabTestsPageResponse.fromJson(
          Map<String, dynamic>.from(res.data as Map),
        );
      }

      return LabTestsPageResponse(
        items: [],
        total: 0,
        page: page,
        limit: limit,
        pages: 1,
        categories: [],
      );
    } catch (e, stack) {
      debugPrint('[LabRemoteDataSource] Error fetching lab tests: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final res = await apiClient.dio.get(ApiConstants.labCategories);
      if (res.data is List) {
        return (res.data as List<dynamic>).map((e) => e.toString()).toList();
      } else if (res.data is Map && res.data['items'] != null) {
        return (res.data['items'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else if (res.data is Map && res.data['value'] != null) {
        return (res.data['value'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[LabRemoteDataSource] Error fetching categories: $e');
      return [];
    }
  }
}
