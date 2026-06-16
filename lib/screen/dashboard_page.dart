import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart' as api;
import '../services/app_session.dart';

import 'package_page.dart';
import 'profile_page.dart';
import 'user_home_page.dart';

class DashboardPage extends StatefulWidget {
  final String? name;
  final String? email;

  const DashboardPage({
    super.key,
    this.name,
    this.email,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<_OrderData>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<_OrderData>> _fetchOrders() async {
    if (!AppSession.isLoggedIn) {
      return <_OrderData>[];
    }

    final url = Uri.parse('${api.ApiConfig.pesanan}?page=1&limit=50');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': AppSession.authorizationHeader,
      },
    );

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;

      throw Exception(message ?? 'Gagal memuat riwayat pesanan');
    }

    final rawOrders = _extractList(decoded);

    return rawOrders
        .whereType<Map>()
        .map((item) => _OrderData.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _fetchOrders();
    });
  }

  String get _displayName {
    return widget.name ??
        AppSession.user?['nama_lengkap']?.toString() ??
        AppSession.user?['name']?.toString() ??
        'User';
  }

  String get _displayEmail {
    return widget.email ??
        AppSession.user?['email']?.toString() ??
        'user@mail.com';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _displayName;
    final displayEmail = _displayEmail;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 54,
              color: const Color(0xFFFFB84D),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFFFFB84D),
                      size: 20,
                    ),
                  ),
                  Icon(Icons.notifications, color: Colors.black, size: 28),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<_OrderData>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  final orders = snapshot.data ?? <_OrderData>[];

                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshOrders();
                      await _ordersFuture;
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Riwayat Pemesanan",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (orders.isEmpty)
                            _buildEmptyHistory()
                          else
                            ...orders.map(
                              (order) => _buildOrderHistoryCard(order: order),
                            ),

                          const SizedBox(height: 22),
                          _buildMonthlySchedule(orders),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 65,
        color: const Color(0xFFFFB84D),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DashboardBottomMenu(
              icon: Icons.home,
              title: "Home",
              page: UserHomePage(name: displayName, email: displayEmail),
            ),
            DashboardBottomMenu(
              icon: Icons.restaurant,
              title: "Paket",
              page: PackagePage(
                name: displayName,
                email: displayEmail,
                scrollTo: "",
              ),
            ),
            const DashboardBottomMenu(
              icon: Icons.badge,
              title: "Dasbor",
              active: true,
            ),
            DashboardBottomMenu(
              icon: Icons.person,
              title: "Profile",
              page: ProfilePage(name: displayName, email: displayEmail),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.redAccent, size: 44),
            const SizedBox(height: 12),
            const Text(
              'Riwayat pesanan belum bisa dimuat',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              error.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _refreshOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB84D),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD98F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long, size: 42, color: Colors.black54),
          SizedBox(height: 10),
          Text(
            'Belum ada riwayat pesanan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Pesanan yang dibuat akan tampil di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryCard({
    required _OrderData order,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD98F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4B8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_dining,
              size: 28,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  order.subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  order.price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 44),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(order.status),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _statusText(order.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySchedule(List<_OrderData> orders) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final orderDays = orders
        .where((order) =>
            order.date != null &&
            order.date!.year == now.year &&
            order.date!.month == now.month)
        .map((order) => order.date!.day)
        .toSet();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Jadwal Bulan Ini",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final day = index + 1;
              final isToday = day == now.day;
              final hasOrder = orderDays.contains(day);
              final date = DateTime(now.year, now.month, day);

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: hasOrder
                      ? const Color(0xFFFFD98F)
                      : const Color(0xFFFFF7EF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dayName(date.weekday),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFFE08A1E)
                            : hasOrder
                                ? const Color(0xFF89C66B)
                                : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        "$day",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _dayName(int weekday) {
    const days = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];

    return days[weekday - 1];
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'completed':
      case 'complete':
      case 'terkirim':
      case 'dikirim':
        return const Color(0xFF2E7D32);
      case 'pending':
      case 'baru':
      case 'menunggu':
        return const Color(0xFFF5A623);
      case 'diproses':
      case 'dikonfirmasi':
      case 'processing':
        return const Color(0xFF2E8BE6);
      case 'dibatalkan':
      case 'cancelled':
      case 'batal':
        return Colors.redAccent;
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'completed':
      case 'complete':
        return 'Selesai';
      case 'terkirim':
      case 'dikirim':
        return 'Terkirim';
      case 'pending':
      case 'baru':
      case 'menunggu':
        return 'Menunggu';
      case 'diproses':
      case 'dikonfirmasi':
      case 'processing':
        return 'Diproses';
      case 'dibatalkan':
      case 'cancelled':
      case 'batal':
        return 'Batal';
      default:
        return status.isEmpty ? 'Status' : status;
    }
  }
}

class _OrderData {
  final String id;
  final String title;
  final String status;
  final String price;
  final DateTime? date;

  const _OrderData({
    required this.id,
    required this.title,
    required this.status,
    required this.price,
    required this.date,
  });

  String get subtitle {
    final formattedDate = _formatDate(date);
    return '${_statusTextStatic(status)}, $formattedDate';
  }

  factory _OrderData.fromJson(Map<String, dynamic> json) {
    final items = _extractList(
      json['items'] ??
          json['detail_pesanan'] ??
          json['detailPesanan'] ??
          json['menus'] ??
          json['menu'],
    );

    final firstItem = items.isNotEmpty ? _asMap(items.first) : null;
    final menuFromItem = firstItem == null
        ? null
        : _asMap(firstItem['menu']) ??
            _asMap(firstItem['menu_harian']) ??
            _asMap(firstItem['menuHarian']);

    final title = _readString(
      json,
      [
        'nama_menu',
        'nama_paket',
        'packageName',
        'paket',
        'title',
      ],
      fallback: _readString(
        firstItem ?? {},
        ['nama_menu', 'nama_paket', 'name', 'title'],
        fallback: _readString(
          menuFromItem ?? {},
          ['nama_menu', 'nama_paket', 'name', 'title'],
          fallback: 'Pesanan Catering',
        ),
      ),
    );

    final total = _readNumber(
      json,
      [
        'total_harga',
        'total_bayar',
        'total_pembayaran',
        'grand_total',
        'total',
        'amount',
      ],
    );

    final rawDate = _readString(
      json,
      [
        'tanggal_pesanan',
        'tanggal_pengiriman',
        'tanggal_mulai',
        'delivery_date',
        'created_at',
        'createdAt',
      ],
      fallback: '',
    );

    return _OrderData(
      id: _readString(
        json,
        ['pesanan_id', 'order_id', 'id', 'kode_pesanan'],
        fallback: '-',
      ),
      title: title,
      status: _readString(
        json,
        ['status_pesanan', 'status', 'state'],
        fallback: 'pending',
      ),
      price: _formatRupiah(total.round()),
      date: _parseDate(rawDate),
    );
  }
}

class DashboardBottomMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final Widget? page;

  const DashboardBottomMenu({
    super.key,
    required this.icon,
    required this.title,
    this.active = false,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: page == null
          ? null
          : () {
              Navigator.pushReplacement(context, _noAnimationRoute(page!));
            },
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE08A1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: Colors.black),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

Route<T> _noAnimationRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  return null;
}

List<dynamic> _extractList(dynamic decoded) {
  if (decoded is List) {
    return decoded;
  }

  if (decoded is! Map<String, dynamic>) {
    return const [];
  }

  final data = decoded['data'];

  if (data is List) {
    return data;
  }

  if (data is Map<String, dynamic>) {
    if (data['pesanan'] is List) return data['pesanan'];
    if (data['orders'] is List) return data['orders'];
    if (data['items'] is List) return data['items'];
    if (data['data'] is List) return data['data'];
    if (data['rows'] is List) return data['rows'];
  }

  if (decoded['pesanan'] is List) return decoded['pesanan'];
  if (decoded['orders'] is List) return decoded['orders'];
  if (decoded['items'] is List) return decoded['items'];
  if (decoded['rows'] is List) return decoded['rows'];

  return const [];
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '-',
}) {
  for (final key in keys) {
    final value = json[key];

    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }

  return fallback;
}

double _readNumber(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];

    if (value is num) return value.toDouble();

    if (value is String) {
      final parsed = double.tryParse(
        value.replaceAll(RegExp(r'[^0-9.-]'), ''),
      );

      if (parsed != null) return parsed;
    }
  }

  return 0;
}

DateTime? _parseDate(String value) {
  if (value.isEmpty || value == '-') {
    return null;
  }

  return DateTime.tryParse(value);
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return '-';
  }

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '${date.day} ${months[date.month - 1]}, $hour:$minute';
}

String _statusTextStatic(String status) {
  switch (status.toLowerCase()) {
    case 'selesai':
    case 'completed':
    case 'complete':
      return 'Selesai';
    case 'terkirim':
    case 'dikirim':
      return 'Terkirim';
    case 'pending':
    case 'baru':
    case 'menunggu':
      return 'Menunggu';
    case 'diproses':
    case 'dikonfirmasi':
    case 'processing':
      return 'Diproses';
    case 'dibatalkan':
    case 'cancelled':
    case 'batal':
      return 'Batal';
    default:
      return status.isEmpty ? 'Status' : status;
  }
}

String _formatRupiah(int value) {
  final text = value.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    final reverseIndex = text.length - i;
    buffer.write(text[i]);

    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return 'Rp$buffer';
}