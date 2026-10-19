import '../../../home/data/models/lab_test_model.dart';

abstract class LabRepository {
  Future<List<LabTestModel>> getLabTests({String? branchId, String? search});
}
