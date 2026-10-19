import '../../../home/data/models/lab_test_model.dart';
import '../../domain/repositories/lab_repository.dart';
import '../datasources/lab_remote_data_source.dart';

class LabRepositoryImpl implements LabRepository {
  final LabRemoteDataSource remoteDataSource;

  LabRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<LabTestModel>> getLabTests({String? branchId, String? search}) =>
      remoteDataSource.getLabTests(branchId: branchId, search: search);
}
