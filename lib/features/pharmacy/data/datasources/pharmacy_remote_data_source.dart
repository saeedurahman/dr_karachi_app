import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/data/models/branch_model.dart';
import '../../../home/data/models/product_model.dart';
import '../models/branch_switch_warning_model.dart';
import '../models/cart_model.dart';
import '../models/category_model.dart';
import '../models/checkout_models.dart';

abstract class PharmacyRemoteDataSource {
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

class PharmacyRemoteDataSourceImpl implements PharmacyRemoteDataSource {
  final ApiClient apiClient;

  PharmacyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await apiClient.dio.get(ApiConstants.pharmacyCategories);
      if (res.data is List) {
        return (res.data as List)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (res.data is Map && res.data['items'] != null) {
        return (res.data['items'] as List)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (res.data is Map && res.data['value'] != null) {
        return (res.data['value'] as List)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<BranchModel>> getBranches() async {
    try {
      final res = await apiClient.dio.get(ApiConstants.branches);
      final List list = res.data is List
          ? res.data as List
          : (res.data is Map && res.data['items'] is List)
              ? res.data['items'] as List
              : [];
      return list
          .map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
    String? branchId,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        query['category_id'] = categoryId;
      }
      if (branchId != null && branchId.isNotEmpty) {
        query['branch_id'] = branchId;
      }

      final res = await apiClient.dio.get(
        ApiConstants.products,
        queryParameters: query,
      );

      final List<ProductModel> products = [];
      int total = 0;
      int totalPages = 1;

      if (res.data is Map) {
        final items = res.data['items'];
        if (items is List) {
          products.addAll(
            items.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)),
          );
        }
        total = (res.data['total'] as num?)?.toInt() ?? products.length;
        totalPages = (res.data['pages'] as num?)?.toInt() ?? 1;
      } else if (res.data is List) {
        products.addAll(
          (res.data as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)),
        );
        total = products.length;
      }

      return {
        'products': products,
        'total': total,
        'pages': totalPages,
        'page': page,
      };
    } catch (e) {
      return {
        'products': <ProductModel>[],
        'total': 0,
        'pages': 1,
        'page': page,
      };
    }
  }

  @override
  Future<CartModel> getCart() async {
    try {
      final res = await apiClient.dio.get(ApiConstants.cart);
      if (res.data is Map<String, dynamic>) {
        return CartModel.fromJson(res.data as Map<String, dynamic>);
      }
      return CartModel.empty();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 403 ||
          e.response?.statusCode == 404) {
        return CartModel.empty();
      }
      rethrow;
    }
  }

  @override
  Future<CartModel> addToCart({
    required String productId,
    required String branchId,
    int quantity = 1,
  }) async {
    final payload = {
      'product_id': productId,
      'branch_id': branchId,
      'quantity': quantity,
    };
    debugPrint('[PharmacyRemoteDataSource] POST ${ApiConstants.cartItems} with payload: $payload');
    try {
      final res = await apiClient.dio.post(
        ApiConstants.cartItems,
        data: payload,
      );
      debugPrint('[PharmacyRemoteDataSource] Response status: ${res.statusCode}');
      debugPrint('[PharmacyRemoteDataSource] Response data: ${res.data}');
      return CartModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[PharmacyRemoteDataSource] DioException caught:');
      debugPrint('  Status code: ${e.response?.statusCode}');
      debugPrint('  Response data: ${e.response?.data}');
      debugPrint('  Message: ${e.message}');
      debugPrint('  Type: ${e.type}');
      if (e.response?.statusCode == 409) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final detail = data['detail'];
          if (detail is Map<String, dynamic>) {
            throw BranchConflictException(
              BranchSwitchWarningModel.fromJson(detail),
            );
          } else {
            throw BranchConflictException(
              BranchSwitchWarningModel.fromJson(data),
            );
          }
        }
      }
      debugPrint('[PharmacyRemoteDataSource] Rethrowing DioException: $e');
      rethrow;
    } catch (e, stack) {
      debugPrint('[PharmacyRemoteDataSource] Non-Dio exception: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<CartModel> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    final res = await apiClient.dio.put(
      '${ApiConstants.cartItems}/$itemId',
      data: {'quantity': quantity},
    );
    return CartModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<CartModel> removeCartItem(String itemId) async {
    final res = await apiClient.dio.delete(
      '${ApiConstants.cartItems}/$itemId',
    );
    return CartModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> clearCart() async {
    await apiClient.dio.delete(ApiConstants.cart);
  }

  @override
  Future<OrderResponseModel> checkout(CheckoutRequestModel request) async {
    final res = await apiClient.dio.post(
      ApiConstants.orders,
      data: request.toJson(),
    );
    return OrderResponseModel.fromJson(res.data as Map<String, dynamic>);
  }
}
