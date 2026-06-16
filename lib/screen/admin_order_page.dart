import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart' as api;
import '../services/app_session.dart';

import 'admin_notification_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_menu_page.dart';
import 'admin_schedule_page.dart';


class AdminOrderPage extends StatefulWidget {
  const AdminOrderPage({super.key});

  static const Color _background = Color(0xFFFFF7EF);
  static const Color _activeGreen = Color(0xFF2E7D32);
  static const Color _priceGreen = Color(0xFF178A2F);
  static const Color _buttonGreen = Color(0xFF168A16);
  static const Color _text = Color(0xFF241F1A);
  static const Color _muted = Color(0xFF7B7067);
  static const Color _line = Color(0xFFE5E5E5);

  @override
  State<AdminOrderPage> createState() => _AdminOrderPageState();
}

class _AdminOrderPageState extends State<AdminOrderPage> {
  String _activeFilter = 'Semua';
  late Future<List<_OrderData>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<_OrderData>> _fetchOrders() async {
      final url = Uri.parse('http://localhost:3001/api/pesanan/admin/all?page=1&limit=10');

      final response = await http.get(
    Uri.parse('${api.ApiConfig.adminPesanan}?page=1&limit=10'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': AppSession.authorizationHeader,
    },
  );

    final decoded = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(message ?? 'Gagal memuat data pesanan');
    }

    return _readOrders(decoded);
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _fetchOrders();
    });
  }

  List<_OrderData> _visibleOrders(List<_OrderData> orders) {
    if (_activeFilter == 'Semua') {
      return orders;
    }

    return orders.where((order) => order.status == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminOrderPage._background,
      body: SafeArea(
        child: FutureBuilder<List<_OrderData>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _OrderErrorState(
                message: snapshot.error.toString(),
                onRetry: _refreshOrders,
              );
            }

            final orders = snapshot.data ?? <_OrderData>[];
            final visibleOrders = _visibleOrders(orders);

            return RefreshIndicator(
              onRefresh: () async {
                _refreshOrders();
                await _ordersFuture;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Header(),
                    const _WelcomeCard(),
                    const SizedBox(height: 10),
                    _FilterTabs(
                      activeFilter: _activeFilter,
                      onSelected: (filter) {
                        setState(() {
                          _activeFilter = filter;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    const _SearchBar(),
                    const SizedBox(height: 12),
                    if (visibleOrders.isEmpty)
                      const _EmptyOrderState()
                    else
                      ...visibleOrders.expand(
                        (order) => [
                          _OrderCard(
                            invoice: order.invoice,
                            customer: order.customer,
                            packageName: order.packageName,
                            startDate: order.startDate,
                            duration: order.duration,
                            people: order.people,
                            price: order.price,
                            status: order.status,
                            actionLabel: _actionLabel(order.status),
                            statusColor: _statusColor(order.status),
                            statusBackground: _statusBackground(order.status),
                            onDetail: () => _showOrderDetail(order),
                            onAction: () => _handleOrderAction(order),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const _AdminBottomNavigation(),
    );
  }

  String _actionLabel(String status) {
    return status == 'Baru' ? 'Konfirmasi' : 'Proses';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Baru':
        return const Color(0xFFF5A623);
      case 'Diproses':
        return const Color(0xFF2E8BE6);
      case 'Dikirim':
        return const Color(0xFFC9A400);
      case 'Selesai':
        return const Color(0xFF2E7D32);
      default:
        return AdminOrderPage._muted;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Baru':
        return const Color(0xFFFFE8C7);
      case 'Diproses':
        return const Color(0xFFE3F1FF);
      case 'Dikirim':
        return const Color(0xFFFFF3BF);
      case 'Selesai':
        return const Color(0xFFE5F6E8);
      default:
        return const Color(0xFFF2F2F2);
    }
  }

  Future<void> _handleOrderAction(_OrderData order) async {
    if (order.status != 'Baru') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan ${order.invoice} sedang diproses')),
      );
      return;
    }

    final previousStatus = order.status;

    setState(() {
      order.status = 'Diproses';
      _activeFilter = 'Diproses';
    });

    try {
      await _updateOrderStatus(order, 'Diproses');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan ${order.invoice} dikonfirmasi')),
      );
      _refreshOrders();
    } catch (e) {
      setState(() {
        order.status = previousStatus;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _updateOrderStatus(_OrderData order, String status) async {
    final url = Uri.parse(
      'http://localhost:3000/api/pesanan/admin/${order.id}/status',
    );
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status_pesanan': 'dikonfirmasi'}),
    );

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(message ?? 'Gagal mengubah status pesanan');
    }
  }

  void _showOrderDetail(_OrderData order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => _OrderDetailSheet(order: order),
    );
  }
}

class _OrderData {
  final String id;
  final String invoice;
  final String customer;
  final String packageName;
  final String startDate;
  final String duration;
  final String people;
  final String price;
  final String phoneNumber;
  final String address;
  final List<_OrderItemData> items;
  String status;

  _OrderData({
    required this.id,
    required this.invoice,
    required this.customer,
    required this.packageName,
    required this.startDate,
    required this.duration,
    required this.people,
    required this.price,
    required this.phoneNumber,
    required this.address,
    required this.items,
    required this.status,
  });

  factory _OrderData.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']) ??
        _asMap(json['customer']) ??
        _asMap(json['customerData']);
    final items = _readOrderItems(json);
    final firstItem = items.isNotEmpty ? items.first.name : '-';

    return _OrderData(
      id: _readString(json, const ['id', '_id', 'orderId', 'uuid']),
      invoice: _readString(json, const [
        'invoice',
        'invoiceNumber',
        'orderNumber',
        'code',
        'nomorPesanan',
      ]),
      customer: _readString(json, const [
        'customerName',
        'name',
        'nama',
      ], fallbackMap: user),
      packageName: _readString(json, const [
        'packageName',
        'paket',
        'menuName',
        'productName',
      ], fallback: firstItem),
      startDate: _formatStartDate(
        _readString(json, const ['startDate', 'tanggalMulai', 'deliveryDate']),
      ),
      duration: _readDuration(json),
      people: _readPeople(json),
      price: _formatRupiah(_readNumber(json, const [
        'price',
        'total',
        'totalPrice',
        'totalPayment',
        'amount',
        'subtotal',
      ])),
      status: _normalizeStatus(_readString(json, const ['status', 'state'])),
      phoneNumber: _readString(json, const [
        'phoneNumber',
        'phone',
        'noHp',
        'whatsapp',
      ], fallbackMap: user),
      address: _readString(json, const [
        'address',
        'alamat',
        'deliveryAddress',
      ], fallbackMap: user),
      items: items,
    );
  }
}

class _OrderItemData {
  final String name;
  final int quantity;

  const _OrderItemData({required this.name, required this.quantity});
}

class _OrderErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OrderErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cleanMessage = message.replaceFirst('Exception: ', '');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 42, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Data pesanan belum bisa dimuat',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              cleanMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
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
}

List<_OrderData> _readOrders(dynamic decoded) {
  final data = _asMap(decoded)?['data'] ?? decoded;
  final rawOrders = _asList(
    _asMap(data)?['orders'] ??
        _asMap(data)?['pesanan'] ??
        _asMap(data)?['items'] ??
        data,
  );

  return rawOrders
      .map(_asMap)
      .whereType<Map<String, dynamic>>()
      .map(_OrderData.fromJson)
      .toList();
}

List<_OrderItemData> _readOrderItems(Map<String, dynamic> json) {
  final rawItems = _asList(
    json['items'] ?? json['orderItems'] ?? json['menus'] ?? json['products'],
  );

  final items = rawItems
      .map(_asMap)
      .whereType<Map<String, dynamic>>()
      .map(
        (item) => _OrderItemData(
          name: _readString(item, const [
            'name',
            'menuName',
            'packageName',
            'productName',
            'title',
          ]),
          quantity: _readInt(item, const ['quantity', 'qty', 'jumlah']),
        ),
      )
      .where((item) => item.name != '-')
      .toList();

  if (items.isNotEmpty) {
    return items;
  }

  final packageName = _readString(json, const [
    'packageName',
    'paket',
    'menuName',
    'productName',
  ]);

  return packageName == '-'
      ? const <_OrderItemData>[]
      : [_OrderItemData(name: packageName, quantity: 1)];
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

List<dynamic> _asList(dynamic value) {
  if (value is List) {
    return value;
  }
  return const [];
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  Map<String, dynamic>? fallbackMap,
  String fallback = '-',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }

  if (fallbackMap != null) {
    for (final key in keys) {
      final value = fallbackMap[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
  }

  return fallback;
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      final parsed = int.tryParse(value.replaceAll(RegExp(r'[^0-9-]'), ''));
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return 1;
}

double _readNumber(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), ''));
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return 0;
}

String _readDuration(Map<String, dynamic> json) {
  final duration = _readString(json, const [
    'duration',
    'durasi',
    'subscriptionDuration',
  ]);
  if (duration != '-') {
    return duration.toLowerCase().contains('hari') ? duration : '$duration Hari';
  }

  final days = _readInt(json, const ['days', 'totalDays', 'jumlahHari']);
  return '$days Hari';
}

String _readPeople(Map<String, dynamic> json) {
  final people = _readString(json, const ['people', 'person', 'pax', 'jumlahOrang']);
  if (people != '-') {
    return people.toLowerCase().contains('orang') ? people : '$people Orang';
  }

  final totalPeople = _readInt(json, const ['persons', 'totalPeople']);
  return '$totalPeople Orang';
}

String _formatStartDate(String value) {
  if (value == '-') {
    return 'Mulai -';
  }

  if (value.toLowerCase().startsWith('mulai')) {
    return value;
  }

  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return 'Mulai $value';
  }

  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  return 'Mulai ${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
}

String _normalizeStatus(String value) {
  switch (value.toLowerCase()) {
    case 'baru':
    case 'new':
    case 'pending':
    case 'menunggu':
    case 'waiting':
      return 'Baru';
    case 'diproses':
    case 'processing':
    case 'process':
    case 'confirmed':
    case 'konfirmasi':
      return 'Diproses';
    case 'dikirim':
    case 'shipping':
    case 'delivered':
    case 'on_delivery':
      return 'Dikirim';
    case 'selesai':
    case 'done':
    case 'completed':
    case 'complete':
      return 'Selesai';
    default:
      return value == '-' ? 'Baru' : value;
  }
}

String _formatRupiah(double value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();

  for (int i = 0; i < rounded.length; i++) {
    final reverseIndex = rounded.length - i;
    buffer.write(rounded[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return 'Rp$buffer';
}

class _EmptyOrderState extends StatelessWidget {
  const _EmptyOrderState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: _cardDecoration(radius: 8),
      child: const Center(
        child: Text(
          'Belum ada pesanan pada status ini',
          style: TextStyle(color: AdminOrderPage._muted, fontSize: 12),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Pesanan',
            style: TextStyle(
              color: AdminOrderPage._text,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminNotificationPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications,
              color: Colors.black,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 327),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 327 / 74,
            child: Image.asset(
              'assets/images/section_atas.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onSelected;

  const _FilterTabs({required this.activeFilter, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const filters = ['Semua', 'Diproses', 'Dikirim', 'Selesai'];

    return Row(
      children: filters
          .map(
            (filter) => _FilterTab(
              label: filter,
              active: activeFilter == filter,
              onTap: () => onSelected(filter),
            ),
          )
          .toList(),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? AdminOrderPage._activeGreen : Colors.black54,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                  color: active
                      ? AdminOrderPage._activeGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminOrderPage._line),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, size: 18, color: AdminOrderPage._muted),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Cari nama / nomor pesanan...',
              style: TextStyle(color: AdminOrderPage._muted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String invoice;
  final String customer;
  final String packageName;
  final String startDate;
  final String duration;
  final String people;
  final String price;
  final String status;
  final String actionLabel;
  final Color statusColor;
  final Color statusBackground;
  final VoidCallback onDetail;
  final VoidCallback onAction;

  const _OrderCard({
    required this.invoice,
    required this.customer,
    required this.packageName,
    required this.startDate,
    required this.duration,
    required this.people,
    required this.price,
    required this.status,
    required this.actionLabel,
    required this.statusColor,
    required this.statusBackground,
    required this.onDetail,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(radius: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#$invoice',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminOrderPage._text,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _StatusBadge(
                label: status,
                color: statusColor,
                background: statusBackground,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            customer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            packageName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AdminOrderPage._muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _OrderMeta(icon: Icons.event, text: startDate),
              ),
              const SizedBox(width: 6),
              _OrderMeta(icon: Icons.timelapse, text: duration, width: 44),
              const SizedBox(width: 6),
              _OrderMeta(icon: Icons.person, text: people, width: 50),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminOrderPage._priceGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 62,
                height: 28,
                child: OutlinedButton(
                  onPressed: onDetail,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: AdminOrderPage._line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Detail',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 78,
                height: 28,
                child: actionLabel == 'Konfirmasi'
                    ? ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AdminOrderPage._buttonGreen,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          actionLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: onAction,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: AdminOrderPage._line),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          actionLabel,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderMeta extends StatelessWidget {
  final IconData icon;
  final String text;
  final double? width;

  const _OrderMeta({required this.icon, required this.text, this.width});

  @override
  Widget build(BuildContext context) {
    final child = Row(
      children: [
        Icon(icon, size: 12, color: AdminOrderPage._muted),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AdminOrderPage._muted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );

    if (width == null) {
      return child;
    }

    return SizedBox(width: width, child: child);
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final _OrderData order;

  const _OrderDetailSheet({required this.order});

  void _openCall(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _OrderCustomerCallPage(order: order)),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _OrderCustomerChatPage(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AdminOrderPage._line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Detail Pesanan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _StatusBadge(
                    label: order.status,
                    color: order.status == 'Baru'
                        ? const Color(0xFFF5A623)
                        : const Color(0xFF2E8BE6),
                    background: order.status == 'Baru'
                        ? const Color(0xFFFFE8C7)
                        : const Color(0xFFE3F1FF),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '#${order.invoice}',
                style: const TextStyle(
                  color: AdminOrderPage._muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _DetailSection(
                title: 'Profil Customer',
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFFFE8C7),
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customer,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            order.phoneNumber,
                            style: const TextStyle(
                              color: AdminOrderPage._muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ProfileActionButton(
                      icon: Icons.phone_outlined,
                      onTap: () => _openCall(context),
                    ),
                    const SizedBox(width: 4),
                    _ProfileActionButton(
                      icon: Icons.message_outlined,
                      onTap: () => _openChat(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _DetailSection(
                title: 'Pesanan',
                child: Column(
                  children: [
                    for (final item in order.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Text(
                              '${item.quantity}x',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          order.price,
                          style: const TextStyle(
                            color: AdminOrderPage._priceGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _DetailSection(
                title: 'Pengiriman',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(icon: Icons.event, text: order.startDate),
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.timelapse, text: order.duration),
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.groups, text: order.people),
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.location_on, text: order.address),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminOrderPage._line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AdminOrderPage._muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ProfileActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AdminOrderPage._activeGreen,
      ),
      icon: Icon(icon, size: 19),
    );
  }
}

class _OrderCustomerCallPage extends StatelessWidget {
  final _OrderData order;

  const _OrderCustomerCallPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB84D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                ),
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 54,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 56, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Text(
                order.customer,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Panggilan Kepakno',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Menggunakan koneksi internet',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _SimpleCallButton(icon: Icons.mic, label: 'Mute'),
                  _SimpleCallButton(icon: Icons.volume_up, label: 'Speaker'),
                  _SimpleCallButton(icon: Icons.message_outlined, label: 'Chat'),
                ],
              ),
              const SizedBox(height: 34),
              IconButton(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  fixedSize: const Size(68, 68),
                ),
                icon: const Icon(Icons.call_end, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleCallButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SimpleCallButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.24),
            foregroundColor: Colors.white,
            fixedSize: const Size(58, 58),
          ),
          icon: Icon(icon, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _OrderCustomerChatPage extends StatefulWidget {
  final _OrderData order;

  const _OrderCustomerChatPage({required this.order});

  @override
  State<_OrderCustomerChatPage> createState() => _OrderCustomerChatPageState();
}

class _OrderCustomerChatPageState extends State<_OrderCustomerChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = ['Halo kak, pesanan sudah kami terima ya.'];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(text);
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminOrderPage._background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB84D),
        foregroundColor: Colors.black,
        title: Text(widget.order.customer),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => _OrderCustomerCallPage(
                    order: widget.order,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.phone_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: _messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AdminOrderPage._activeGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _messages[index],
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        filled: true,
                        fillColor: const Color(0xFFFFF7EF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: AdminOrderPage._activeGreen,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBottomNavigation extends StatelessWidget {
  const _AdminBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AdminBottomMenu(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              Navigator.pushReplacement(
                context,
                _noAnimationRoute(const DashboardPage()),
              );
            },
          ),
          const _AdminBottomMenu(
            icon: Icons.receipt_long,
            title: 'Pesanan',
            active: true,
          ),
          _AdminBottomMenu(
            icon: Icons.restaurant_menu,
            title: 'Menu',
            onTap: () {
              Navigator.pushReplacement(
                context,
                _noAnimationRoute(const AdminMenuPage()),
              );
            },
          ),
          _AdminBottomMenu(
            icon: Icons.calendar_month,
            title: 'Jadwal',
            onTap: () {
              Navigator.pushReplacement(
                context,
                _noAnimationRoute(const AdminSchedulePage()),
              );
            },
          ),
        ],
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

class _AdminBottomMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final VoidCallback? onTap;

  const _AdminBottomMenu({
    required this.icon,
    required this.title,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 62,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFB84D) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            Text(title, style: const TextStyle(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration({double radius = 8}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 5, offset: Offset(0, 2)),
    ],
  );
}
