import '../../../home/data/models/branch_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/checkout_models.dart';

abstract class PharmacyRepository {
  Future<List<CategoryModel>> getCategories();
  Future<List<BranchModel>> getBranches();
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
    String? branchId,
  });
  Future<CartModel> getCart();
  Future<CartModel> addToCart({
    required String productId,
    required String branchId,
    int quantity = 1,
  });
  Future<CartModel> updateCartItem({
    required String itemId,
    required int quantity,
  });
  Future<CartModel> removeCartItem(String itemId);
  Future<void> clearCart();
  Future<OrderResponseModel> checkout(CheckoutRequestModel request);
}
