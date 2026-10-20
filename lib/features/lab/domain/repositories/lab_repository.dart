import '../../data/models/lab_tests_page_response.dart';

abstract class LabRepository {
  Future<LabTestsPageResponse> getLabTests({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? branchId,
  });

  Future<List<String>> getCategories();
}
