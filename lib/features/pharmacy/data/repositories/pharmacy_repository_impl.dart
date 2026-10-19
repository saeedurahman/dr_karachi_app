import '../../../home/data/models/branch_model.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../datasources/pharmacy_remote_data_source.dart';
import '../models/cart_model.dart';
import '../models/category_model.dart';
import '../models/checkout_models.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  final PharmacyRemoteDataSource remoteDataSource;

  PharmacyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CategoryModel>> getCategories() =>
      remoteDataSource.getCategories();

  @override
  Future<List<BranchModel>> getBranches() =>
      remoteDataSource.getBranches();

  @override
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
    String? branchId,
  }) =>
      remoteDataSource.getProducts(
        page: page,
        pageSize: pageSize,
        search: search,
        categoryId: categoryId,
        branchId: branchId,
      );

  @override
  Future<CartModel> getCart() => remoteDataSource.getCart();

  @override
  Future<CartModel> addToCart({
    required String productId,
    required String branchId,
    int quantity = 1,
  }) =>
      remoteDataSource.addToCart(
        productId: productId,
        branchId: branchId,
        quantity: quantity,
      );

  @override
  Future<CartModel> updateCartItem({
    required String itemId,
    required int quantity,
  }) =>
      remoteDataSource.updateCartItem(
        itemId: itemId,
        quantity: quantity,
      );

  @override
  Future<CartModel> removeCartItem(String itemId) =>
      remoteDataSource.removeCartItem(itemId);

  @override
  Future<void> clearCart() => remoteDataSource.clearCart();

  @override
  Future<OrderResponseModel> checkout(CheckoutRequestModel request) =>
      remoteDataSource.checkout(request);
}
