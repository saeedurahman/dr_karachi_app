import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/data/models/lab_test_model.dart';

abstract class LabRemoteDataSource {
  Future<List<LabTestModel>> getLabTests({String? branchId, String? search});
}

class LabRemoteDataSourceImpl implements LabRemoteDataSource {
  final ApiClient apiClient;

  LabRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<LabTestModel>> getLabTests({String? branchId, String? search}) async {
    try {
      final query = <String, dynamic>{};
      if (branchId != null && branchId.isNotEmpty) {
        query['branch_id'] = branchId;
      }
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }

      final res = await apiClient.dio.get(
        ApiConstants.labTests,
        queryParameters: query.isEmpty ? null : query,
      );

      final List<LabTestModel> tests = [];
      if (res.data is Map && res.data['items'] != null) {
        final list = res.data['items'] as List<dynamic>;
        tests.addAll(
          list.map((e) => LabTestModel.fromJson(e as Map<String, dynamic>)),
        );
      } else if (res.data is List) {
        final list = res.data as List<dynamic>;
        tests.addAll(
          list.map((e) => LabTestModel.fromJson(e as Map<String, dynamic>)),
        );
      }

      // If search query is provided and backend didn't filter, filter locally
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim().toLowerCase();
        return tests
            .where((t) =>
                t.name.toLowerCase().contains(q) ||
                t.code.toLowerCase().contains(q) ||
                (t.description?.toLowerCase().contains(q) ?? false))
            .toList();
      }

      return tests;
    } catch (_) {
      return [];
    }
  }
}
