import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart' as api;
import '../services/app_session.dart';

class AdminNotificationPage extends StatefulWidget {
  const AdminNotificationPage({super.key});

  @override
  State<AdminNotificationPage> createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage> {
  static const Color _background = Color(0xFFFFF7EF);
  static const Color _green = Color(0xFF2E7D32);
  static const Color _yellow = Color(0xFFF5A623);
  static const Color _muted = Color(0xFF7B7067);
  static const Color _line = Color(0xFFE5E5E5);

  late Future<List<_NotificationData>> _notifFuture;

  @override
  void initState() {
    super.initState();
    _notifFuture = _fetchNotifications();
  }

  Future<List<_NotificationData>> _fetchNotifications() async {
    if (!AppSession.isLoggedIn) throw Exception('Silakan login admin');

    final url = Uri.parse(
      api.ApiConfig.notifikasi,
    ); // Pastikan ini ada di api_config.dart

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

    final rawData = _extractList(decoded);
    return rawData
        .whereType<Map>()
        .map(
          (item) => _NotificationData.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  void _refresh() {
    setState(() {
      _notifFuture = _fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
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
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<_NotificationData>>(
                future: _notifFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data ?? [];
                  if (data.isEmpty)
                    return const Center(child: Text('Tidak ada notifikasi'));

                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: data.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _NotificationCard(data: data[index]),
                    ),
                  );
                },
              ),
            ),
          ],
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

  const _NotificationData({
    required this.customer,
    required this.packageName,
    required this.invoice,
    required this.price,
    required this.time,
    this.unread = false,
  });

  factory _NotificationData.fromJson(Map<String, dynamic> json) {
    return _NotificationData(
      customer: json['customer_name'] ?? json['nama'] ?? 'Customer',
      packageName: json['package_name'] ?? json['paket'] ?? 'Pesanan',
      invoice: json['invoice'] ?? '-',
      price: json['price'] ?? 'Rp 0',
      time: json['created_at'] ?? 'Baru saja',
      unread: json['is_read'] == 0 || json['is_read'] == false,
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
              ? const Color(0xFF2E7D32)
              : const Color(0xFFE5E5E5),
        ),
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
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFF5A623),
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
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      data.time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7B7067),
                      ),
                    ),
                  ],
                ),
                Text('${data.customer} memesan ${data.packageName}'),
                Text(
                  data.invoice,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF7B7067),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Utility Helper
List<dynamic> _extractList(dynamic decoded) {
  if (decoded is List) return decoded;
  if (decoded is Map<String, dynamic>) {
    final data = decoded['data'];
    if (data is List) return data;
  }
  return const [];
}
