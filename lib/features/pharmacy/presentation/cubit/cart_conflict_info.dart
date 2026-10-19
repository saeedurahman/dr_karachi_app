import '../../../home/data/models/product_model.dart';
import '../../data/models/branch_switch_warning_model.dart';

class CartConflictInfo {
  final BranchSwitchWarningModel warning;
  final ProductModel pendingProduct;
  final int pendingQuantity;
  final String currentBranchName;
  final String requestedBranchName;

  CartConflictInfo({
    required this.warning,
    required this.pendingProduct,
    required this.pendingQuantity,
    required this.currentBranchName,
    required this.requestedBranchName,
  });
}
