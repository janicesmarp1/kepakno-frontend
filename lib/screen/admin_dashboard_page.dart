import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart' as api;
import '../services/app_session.dart';

import 'welcome_page.dart';
import 'admin_menu_page.dart';
import 'admin_order_page.dart';
import 'admin_schedule_page.dart';
import 'admin_notification_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _fetchDashboardData();
  }

  Future<_DashboardData> _fetchDashboardData() async {
    if (!AppSession.isLoggedIn) {
      throw Exception('Silakan login admin terlebih dahulu');
    }

    final url = Uri.parse('${api.ApiConfig.adminPesanan}?page=1&limit=100');

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

      throw Exception(message ?? 'Gagal memuat dashboard');
    }

    final orders = _extractList(decoded)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    return _DashboardData.fromOrders(orders);
  }

  void _refreshDashboard() {
    setState(() {
      _dashboardFuture = _fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 36,
                      height: 36,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminNotificationPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications, size: 30),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<_DashboardData>(
                future: _dashboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _DashboardErrorState(
                      message: snapshot.error.toString(),
                      onRetry: _refreshDashboard,
                    );
                  }

                  return _DashboardContent(
                    data: snapshot.data ?? _DashboardData.empty(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 65,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const AdminBottomMenu(
              icon: Icons.dashboard,
              title: "Dashboard",
              active: true,
            ),
            AdminBottomMenu(
              icon: Icons.receipt_long,
              title: "Pesanan",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  _noAnimationRoute(const AdminOrderPage()),
                );
              },
            ),
            AdminBottomMenu(
              icon: Icons.restaurant_menu,
              title: "Menu",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  _noAnimationRoute(const AdminMenuPage()),
                );
              },
            ),
            AdminBottomMenu(
              icon: Icons.calendar_month,
              title: "Jadwal",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  _noAnimationRoute(const AdminSchedulePage()),
                );
              },
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

class _DashboardContent extends StatelessWidget {
  final _DashboardData data;

  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final state = context.findAncestorStateOfType<_DashboardPageState>();
        state?._refreshDashboard();
        await state?._dashboardFuture;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 327),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 327 / 74,
                    child: Image.asset(
                      "assets/images/section_atas.png",
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.shopping_cart,
                    value: data.ordersToday.toString(),
                    title: "Pesanan Hari Ini",
                    color: const Color(0xFFE6D9FF),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.shopping_cart,
                    value: data.ordersThisMonth.toString(),
                    title: "Pesanan Bulan Ini",
                    color: const Color(0xFFD9F4FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.wallet,
                    value: _formatRupiah(data.revenueToday),
                    title: "Pendapatan Hari Ini",
                    color: const Color(0xFFDFF5DF),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: DashboardStatCard(
                    icon: Icons.wallet,
                    value: _formatRupiah(data.revenueThisMonth),
                    title: "Pendapatan Bulan Ini",
                    color: const Color(0xFFFFE4C7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _RevenueChartCard(points: data.revenueChart),
            const SizedBox(height: 22),
            _BestMenuCard(items: data.bestMenus),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () {
                  AppSession.clear();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomePage(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  "Keluar Akun",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorState({
    required this.message,
    required this.onRetry,
  });

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
              'Dashboard belum bisa dimuat',
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

class _RevenueChartCard extends StatelessWidget {
  final List<_RevenuePoint> points;

  const _RevenueChartCard({required this.points});

  @override
  Widget build(BuildContext context) {
    final maxRevenue = points.fold<double>(
      0,
      (max, point) => math.max(max, point.revenue),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Grafik Pendapatan (30 Hari Terakhir)",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text("30 Hari", style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 178,
            child: points.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data pendapatan',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ChartValueLabels(maxValue: maxRevenue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomPaint(
                                painter: _RevenueChartPainter(
                                  points: points,
                                  maxValue: maxRevenue,
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 38),
                        child: _ChartDateLabels(points: points),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _BestMenuCard extends StatelessWidget {
  final List<_BestMenu> items;

  const _BestMenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Menu Terlaris",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              Text("30 Hari", style: TextStyle(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Text(
              'Belum ada data menu terlaris',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            )
          else
            ...items.asMap().entries.map(
                  (entry) => BestMenuItem(
                    number: "${entry.key + 1}.",
                    name: entry.value.name,
                    portion: "${entry.value.portions} Porsi",
                  ),
                ),
        ],
      ),
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final Color color;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: color,
            child: Icon(icon, color: Colors.black, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BestMenuItem extends StatelessWidget {
  final String number;
  final String name;
  final String portion;

  const BestMenuItem({
    super.key,
    required this.number,
    required this.name,
    required this.portion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Text(number, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 12))),
          Text(
            portion,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartValueLabels extends StatelessWidget {
  final double maxValue;

  const _ChartValueLabels({required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final topValue = maxValue <= 0 ? 1.0 : maxValue;
    final labels = [
      _formatShortRupiah(topValue),
      _formatShortRupiah(topValue * 2 / 3),
      _formatShortRupiah(topValue / 3),
      "0",
    ];

    return SizedBox(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: labels
            .map(
              (label) => Text(
                label,
                style: const TextStyle(fontSize: 9, color: Colors.black54),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ChartDateLabels extends StatelessWidget {
  final List<_RevenuePoint> points;

  const _ChartDateLabels({required this.points});

  @override
  Widget build(BuildContext context) {
    final dates = _pickChartLabels(points);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: dates
          .map(
            (date) => Text(
              date,
              style: const TextStyle(fontSize: 9, color: Colors.black54),
            ),
          )
          .toList(),
    );
  }
}

class AdminBottomMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final VoidCallback? onTap;

  const AdminBottomMenu({
    super.key,
    required this.icon,
    required this.title,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
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

class _RevenueChartPainter extends CustomPainter {
  final List<_RevenuePoint> points;
  final double maxValue;

  const _RevenueChartPainter({
    required this.points,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final topValue = maxValue <= 0 ? 1.0 : maxValue;
    final offsets = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? size.width / 2
          : size.width * i / (points.length - 1);
      final normalized = (points[i].revenue / topValue).clamp(0.0, 1.0);
      final y = size.height - (size.height * normalized);
      offsets.add(Offset(x, y));
    }

    if (offsets.length > 1) {
      final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);

      for (final point in offsets.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(path, linePaint);
    }

    for (final point in offsets) {
      canvas.drawCircle(point, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.maxValue != maxValue;
  }
}

class _DashboardData {
  final int ordersToday;
  final int ordersThisMonth;
  final double revenueToday;
  final double revenueThisMonth;
  final List<_RevenuePoint> revenueChart;
  final List<_BestMenu> bestMenus;

  const _DashboardData({
    required this.ordersToday,
    required this.ordersThisMonth,
    required this.revenueToday,
    required this.revenueThisMonth,
    required this.revenueChart,
    required this.bestMenus,
  });

  factory _DashboardData.empty() {
    return const _DashboardData(
      ordersToday: 0,
      ordersThisMonth: 0,
      revenueToday: 0,
      revenueThisMonth: 0,
      revenueChart: [],
      bestMenus: [],
    );
  }

  factory _DashboardData.fromOrders(List<Map<String, dynamic>> orders) {
    final now = DateTime.now();

    bool isSameDay(DateTime? date, DateTime target) {
      if (date == null) return false;

      return date.year == target.year &&
          date.month == target.month &&
          date.day == target.day;
    }

    bool isSameMonth(DateTime? date, DateTime target) {
      if (date == null) return false;

      return date.year == target.year && date.month == target.month;
    }

    final ordersToday = orders.where((order) {
      return isSameDay(_readOrderDate(order), now);
    }).length;

    final ordersThisMonth = orders.where((order) {
      return isSameMonth(_readOrderDate(order), now);
    }).length;

    final revenueToday = orders.where((order) {
      return isSameDay(_readOrderDate(order), now);
    }).fold<double>(0, (total, order) {
      return total + _readOrderTotal(order);
    });

    final revenueThisMonth = orders.where((order) {
      return isSameMonth(_readOrderDate(order), now);
    }).fold<double>(0, (total, order) {
      return total + _readOrderTotal(order);
    });

    final startDate = DateTime(now.year, now.month, now.day).subtract(
      const Duration(days: 29),
    );

    final chart = List.generate(30, (index) {
      final date = startDate.add(Duration(days: index));

      final total = orders.where((order) {
        return isSameDay(_readOrderDate(order), date);
      }).fold<double>(0, (sum, order) {
        return sum + _readOrderTotal(order);
      });

      return _RevenuePoint(
        label: '${date.day}/${date.month}',
        revenue: total,
      );
    });

    final menuCounter = <String, int>{};

    for (final order in orders) {
      final items = _extractList(
        order['items'] ??
            order['detail_pesanan'] ??
            order['detailPesanan'] ??
            order['menus'] ??
            order['menu'],
      );

      if (items.isEmpty) {
        final name = _readOrderTitle(order);
        menuCounter[name] = (menuCounter[name] ?? 0) + 1;
      } else {
        for (final rawItem in items) {
          final item = _asMap(rawItem);
          if (item == null) continue;

          final name = _readItemMenuName(item);
          final qty = _readOrderQuantity(item);

          menuCounter[name] = (menuCounter[name] ?? 0) + qty;
        }
      }
    }

    final bestMenus = menuCounter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _DashboardData(
      ordersToday: ordersToday,
      ordersThisMonth: ordersThisMonth,
      revenueToday: revenueToday,
      revenueThisMonth: revenueThisMonth,
      revenueChart: chart,
      bestMenus: bestMenus
          .take(5)
          .map(
            (entry) => _BestMenu(
              name: entry.key,
              portions: entry.value,
            ),
          )
          .toList(),
    );
  }
}

class _RevenuePoint {
  final String label;
  final double revenue;

  const _RevenuePoint({
    required this.label,
    required this.revenue,
  });
}

class _BestMenu {
  final String name;
  final int portions;

  const _BestMenu({
    required this.name,
    required this.portions,
  });
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

DateTime? _readOrderDate(Map<String, dynamic> json) {
  final value = _readString(json, const [
    'tanggal_pesanan',
    'tanggal_pengiriman',
    'tanggal_mulai',
    'delivery_date',
    'created_at',
    'createdAt',
  ]);

  if (value == '-' || value.isEmpty) return null;

  return DateTime.tryParse(value);
}

double _readOrderTotal(Map<String, dynamic> json) {
  return _readDouble(json, const [
    'total_harga',
    'total_bayar',
    'total_pembayaran',
    'grand_total',
    'total',
    'amount',
    'jumlah',
  ]);
}

String _readOrderTitle(Map<String, dynamic> json) {
  final title = _readString(json, const [
    'nama_menu',
    'nama_paket',
    'packageName',
    'paket',
    'title',
  ]);

  return title == '-' ? 'Pesanan Catering' : title;
}

String _readItemMenuName(Map<String, dynamic> item) {
  final menu = _asMap(item['menu']) ??
      _asMap(item['menu_harian']) ??
      _asMap(item['menuHarian']);

  final directName = _readString(item, const [
    'nama_menu',
    'nama_paket',
    'name',
    'title',
  ]);

  if (directName != '-') return directName;

  if (menu != null) {
    final menuName = _readString(menu, const [
      'nama_menu',
      'nama_paket',
      'name',
      'title',
    ]);

    if (menuName != '-') return menuName;
  }

  return 'Menu Catering';
}

int _readOrderQuantity(Map<String, dynamic> item) {
  final qty = _readInt(item, const [
    'jumlah',
    'qty',
    'quantity',
    'porsi',
  ]);

  return qty <= 0 ? 1 : qty;
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];

    if (value is int) return value;
    if (value is num) return value.round();

    if (value is String) {
      final parsed = int.tryParse(value.replaceAll(RegExp(r'[^0-9-]'), ''));
      if (parsed != null) return parsed;
    }
  }

  return 0;
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
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

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];

    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }

  return '-';
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

String _formatShortRupiah(double value) {
  if (value >= 1000000) {
    final millions = value / 1000000;
    return '${_trimDecimal(millions)} jt';
  }

  if (value >= 1000) {
    final thousands = value / 1000;
    return '${_trimDecimal(thousands)} rb';
  }

  return value.round().toString();
}

String _trimDecimal(double value) {
  final fixed = value.toStringAsFixed(value >= 10 ? 0 : 1);

  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}

List<String> _pickChartLabels(List<_RevenuePoint> points) {
  if (points.isEmpty) {
    return const [];
  }

  if (points.length <= 5) {
    return points.map((point) => point.label).toList();
  }

  final labels = <String>[];
  const labelCount = 5;

  for (int i = 0; i < labelCount; i++) {
    final index = (i * (points.length - 1) / (labelCount - 1)).round();
    labels.add(points[index].label);
  }

  return labels;
}