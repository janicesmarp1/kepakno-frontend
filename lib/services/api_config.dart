class ApiConfig {
  static const String baseUrl = 'http://localhost:3001';

  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String me = '$baseUrl/api/auth/me';

  static const String profile = '$baseUrl/api/users/profile';
  static const String addresses = '$baseUrl/api/users/alamat';

  static const String paket = '$baseUrl/api/paket';
  static const String menu = '$baseUrl/api/menu';

  static const String pesanan = '$baseUrl/api/pesanan';
  static const String adminPesanan = '$baseUrl/api/pesanan/admin/all';

  static String pesananDetail(dynamic id) => '$baseUrl/api/pesanan/$id';

  static String cancelPesanan(dynamic id) => '$baseUrl/api/pesanan/$id/cancel';

  static String adminUpdatePesananStatus(dynamic id) {
    return '$baseUrl/api/pesanan/admin/$id/status';
  }
}