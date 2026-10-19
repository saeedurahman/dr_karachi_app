class ApiConstants {
  static const String baseUrl = 'https://drkarachibackend-production.up.railway.app/api/v1';
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Home & Services Endpoints
  static const String branches = '/branches/';
  static const String doctors = '/doctors/';
  static const String products = '/pharmacy/products/';
  static const String pharmacyCategories = '/pharmacy/categories/';
  static const String labTests = '/lab-tests';
  static const String labReports = '/lab-reports';
  static const String appointments = '/appointments';
  static const String reviews = '/reviews';

  // Pharmacy Cart & Orders Endpoints
  static const String cart = '/pharmacy/cart';
  static const String cartItems = '/pharmacy/cart/items';
  static const String orders = '/pharmacy/orders';
}
