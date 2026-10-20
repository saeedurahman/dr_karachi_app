import '../../domain/repositories/lab_repository.dart';
import '../datasources/lab_remote_data_source.dart';
import '../models/lab_tests_page_response.dart';

class LabRepositoryImpl implements LabRepository {
  final LabRemoteDataSource remoteDataSource;

  LabRepositoryImpl({required this.remoteDataSource});

  @override
  Future<LabTestsPageResponse> getLabTests({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? branchId,
  }) =>
      remoteDataSource.getLabTests(
        page: page,
        limit: limit,
        search: search,
        category: category,
        branchId: branchId,
      );

  @override
  Future<List<String>> getCategories() => remoteDataSource.getCategories();
}
