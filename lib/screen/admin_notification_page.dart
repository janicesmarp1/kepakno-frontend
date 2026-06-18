import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart' as api;
import '../services/app_session.dart';

class AdminNotificationPage extends StatefulWidget {
  const AdminNotificationPage({super.key});

  static const Color _background = Color(0xFFFFF7EF);
  static const Color _green = Color(0xFF2E7D32);
  static const Color _yellow = Color(0xFFF5A623);
  static const Color _muted = Color(0xFF7B7067);
  static const Color _line = Color(0xFFE5E5E5);

  @override
  State<AdminNotificationPage> createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage> {
  late Future<List<_NotificationData>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<_NotificationData>> _fetchNotifications() async {
    if (!AppSession.isLoggedIn) {
      throw Exception('Silakan login admin terlebih dahulu');
    }

    final url = Uri.parse('${api.ApiConfig.adminPesanan}?page=1&limit=30');

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

      throw Exception(message ?? 'Gagal memuat notifikasi');
    }

    final rawOrders = _extractList(decoded);

    final notifications = rawOrders
        .whereType<Map>()
        .map(
          (item) => _NotificationData.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    notifications.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return notifications;
  }

  void _refreshNotifications() {
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminNotificationPage._background,
      body: SafeArea(
        child: FutureBuilder<List<_NotificationData>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final notifications = snapshot.data ?? <_NotificationData>[];
            final unreadCount =
                notifications.where((item) => item.unread).length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 20, 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Notifikasi',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8C7),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          isLoading ? '...' : '$unreadCount Baru',
                          style: const TextStyle(
                            color: AdminNotificationPage._yellow,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return _ErrorState(
                          message: snapshot.error
                              .toString()
                              .replaceFirst('Exception: ', ''),
                          onRetry: _refreshNotifications,
                        );
                      }

                      if (notifications.isEmpty) {
                        return const _EmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          _refreshNotifications();
                          await _notificationsFuture;
                        },
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                          itemCount: notifications.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _NotificationCard(
                              data: notifications[index],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationData {
  final String customer;
  final String packageName;
  final String invoice;
  final String price;
  final String time;
  final bool unread;
  final DateTime? createdAt;

  const _NotificationData({
    required this.customer,
    required this.packageName,
    required this.invoice,
    required this.price,
    required this.time,
    required this.unread,
    required this.createdAt,
  });

  factory _NotificationData.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']) ??
        _asMap(json['customer']) ??
        _asMap(json['pelanggan']);

    final items = _extractList(
      json['items'] ??
          json['detail_pesanan'] ??
          json['detailPesanan'] ??
          json['menus'] ??
          json['menu'],
    );

    final firstItem = items.isNotEmpty ? _asMap(items.first) : null;

    final menu = firstItem == null
        ? null
        : _asMap(firstItem['menu']) ??
            _asMap(firstItem['menu_harian']) ??
            _asMap(firstItem['menuHarian']);

    final createdAt = _parseDate(
      _readString(
        json,
        const [
          'created_at',
          'createdAt',
          'tanggal_pesanan',
          'tanggal_pengiriman',
          'tanggal_mulai',
          'delivery_date',
        ],
        fallback: '',
      ),
    );

    final status = _readString(
      json,
      const [
        'status_pesanan',
        'status',
        'state',
      ],
      fallback: '',
    );

    final packageName = _readString(
      json,
      const [
        'nama_menu',
        'nama_paket',
        'packageName',
        'paket',
        'title',
      ],
      fallback: _readString(
        firstItem ?? {},
        const [
          'nama_menu',
          'nama_paket',
          'name',
          'title',
        ],
        fallback: _readString(
          menu ?? {},
          const [
            'nama_menu',
            'nama_paket',
            'name',
            'title',
          ],
          fallback: 'Pesanan Catering',
        ),
      ),
    );

    final invoice = _readString(
      json,
      const [
        'invoice',
        'kode_invoice',
        'kode_pesanan',
        'pesanan_id',
        'id',
      ],
      fallback: 'INV-${DateTime.now().millisecondsSinceEpoch}',
    );

    final total = _readNumber(
      json,
      const [
        'total_harga',
        'total_bayar',
        'total_pembayaran',
        'grand_total',
        'total',
        'amount',
        'jumlah',
      ],
    ).round();

    return _NotificationData(
      customer: _readString(
        user ?? json,
        const [
          'nama_lengkap',
          'name',
          'nama',
          'customer_name',
        ],
        fallback: 'Customer',
      ),
      packageName: packageName,
      invoice: invoice.toString().startsWith('INV')
          ? invoice
          : 'INV-$invoice',
      price: _formatRupiah(total),
      time: _relativeTime(createdAt),
      unread: _isUnreadStatus(status, createdAt),
      createdAt: createdAt,
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _NotificationData data;

  const _NotificationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: data.unread
              ? AdminNotificationPage._green
              : AdminNotificationPage._line,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: data.unread
                ? const Color(0xFFE5F6E8)
                : const Color(0xFFFFF1D9),
            child: Icon(
              Icons.receipt_long,
              color: data.unread
                  ? AdminNotificationPage._green
                  : AdminNotificationPage._yellow,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Orderan Masuk',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      data.time,
                      style: const TextStyle(
                        color: AdminNotificationPage._muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${data.customer} memesan ${data.packageName}',
                  style: const TextStyle(fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.invoice,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AdminNotificationPage._muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      data.price,
                      style: const TextStyle(
                        color: AdminNotificationPage._green,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              color: Colors.redAccent,
              size: 44,
            ),
            const SizedBox(height: 12),
            const Text(
              'Notifikasi belum bisa dimuat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminNotificationPage._green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Belum ada notifikasi',
        style: TextStyle(
          fontSize: 12,
          color: AdminNotificationPage._muted,
        ),
      ),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map(
      (key, value) => MapEntry(
        key.toString(),
        value,
      ),
    );
  }

  return null;
}

List<dynamic> _extractList(dynamic decoded) {
  if (decoded is List) return decoded;

  if (decoded is! Map<String, dynamic>) return const [];

  final data = decoded['data'];

  if (data is List) return data;

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

double _readNumber(
  Map<String, dynamic> json,
  List<String> keys,
) {
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
  if (value.isEmpty || value == '-') return null;

  return DateTime.tryParse(value);
}

bool _isUnreadStatus(String status, DateTime? createdAt) {
  final lower = status.toLowerCase();

  if (lower.contains('baru') ||
      lower.contains('pending') ||
      lower.contains('menunggu') ||
      lower.contains('diproses')) {
    return true;
  }

  if (createdAt == null) return false;

  final diff = DateTime.now().difference(createdAt);

  return diff.inHours < 1;
}

String _relativeTime(DateTime? date) {
  if (date == null) return '-';

  final diff = DateTime.now().difference(date);

  if (diff.inMinutes < 1) {
    return 'Baru saja';
  }

  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} menit lalu';
  }

  if (diff.inHours < 24) {
    return '${diff.inHours} jam lalu';
  }

  if (diff.inDays == 1) {
    return 'Kemarin';
  }

  return '${diff.inDays} hari lalu';
}

String _formatRupiah(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < raw.length; i++) {
    final reverseIndex = raw.length - i;
    buffer.write(raw[i]);

    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return 'Rp$buffer';
}