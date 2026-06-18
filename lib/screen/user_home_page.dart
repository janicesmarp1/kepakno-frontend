import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart' as api;
import '../services/app_session.dart';
import 'dashboard_page.dart';
import 'package_page.dart';
import 'profile_page.dart';
import 'saldo_page.dart';

class UserHomePage extends StatefulWidget {
  final String name;
  final String email;

  const UserHomePage({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int selectedDay = 0;
  late Future<_HomeData> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeData();
  }

  Future<_HomeData> _loadHomeData() async {
    final menus = await _fetchMenus();
    final orders = await _fetchOrders();

    return _HomeData(
      menus: menus,
      orders: orders,
    );
  }

  Future<List<_MenuData>> _fetchMenus() async {
    try {
      final response = await http.get(
        Uri.parse('${api.ApiConfig.menu}?page=1&limit=50'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return <_MenuData>[];
      }

      final rawMenus = _extractList(decoded);

      return rawMenus
          .whereType<Map>()
          .map((item) => _MenuData.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return <_MenuData>[];
    }
  }

  Future<List<_OrderData>> _fetchOrders() async {
    if (!AppSession.isLoggedIn) {
      return <_OrderData>[];
    }

    try {
      final response = await http.get(
        Uri.parse('${api.ApiConfig.pesanan}?page=1&limit=50'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AppSession.authorizationHeader,
        },
      );

      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return <_OrderData>[];
      }

      final rawOrders = _extractList(decoded);

      return rawOrders
          .whereType<Map>()
          .map((item) => _OrderData.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return <_OrderData>[];
    }
  }

  void _refreshHome() {
    setState(() {
      _homeFuture = _loadHomeData();
    });
  }

  String get displayName {
    return AppSession.user?['nama_lengkap']?.toString() ??
        AppSession.user?['name']?.toString() ??
        widget.name;
  }

  String get displayEmail {
    return AppSession.user?['email']?.toString() ?? widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 54,
              color: const Color(0xFFFFB84D),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFFFFB84D),
                      size: 20,
                    ),
                  ),
                  Text(
                    "Hi, $displayName",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Icon(
                    Icons.notifications,
                    color: Colors.black,
                    size: 28,
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<_HomeData>(
                future: _homeFuture,
                builder: (context, snapshot) {
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting;

                  final data = snapshot.data ??
                      const _HomeData(
                        menus: [],
                        orders: [],
                      );

                  final promoMenu =
                      data.menus.isNotEmpty ? data.menus.first : null;

                  final cheapestMenus = [...data.menus]
                    ..sort((a, b) => a.price.compareTo(b.price));

                  final cheapestMenu =
                      cheapestMenus.isNotEmpty ? cheapestMenus.first : null;

                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshHome();
                      await _homeFuture;
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _infoBox(
                                icon: Icons.account_balance_wallet,
                                title: "Saldo",
                                subtitle: "Rp. ${formatRupiah(globalSaldo)}",
                                color: const Color(0xFFFFD98F),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SaldoPage(
                                        name: displayName,
                                        email: displayEmail,
                                      ),
                                    ),
                                  ).then((_) => setState(() {}));
                                },
                              ),
                              const SizedBox(width: 14),
                              _infoBox(
                                icon: Icons.history,
                                title: "Riwayat",
                                subtitle: isLoading
                                    ? "Memuat..."
                                    : "${data.orders.length} Pesanan",
                                color: const Color(0xFFC9F5CF),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DashboardPage(
                                        name: displayName,
                                        email: displayEmail,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _buildPromoBanner(promoMenu),
                          const SizedBox(height: 14),
                          const Text(
                            "Kategori",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.85,
                            children: [
                              CategoryCard(
                                icon: Icons.wb_twilight,
                                title: "Sarapan",
                                page: PackagePage(
                                  name: displayName,
                                  email: displayEmail,
                                  scrollTo: "sarapan",
                                ),
                              ),
                              CategoryCard(
                                icon: Icons.wb_sunny,
                                title: "Makan Siang",
                                page: PackagePage(
                                  name: displayName,
                                  email: displayEmail,
                                  scrollTo: "makan_siang",
                                ),
                              ),
                              CategoryCard(
                                icon: Icons.nightlight_round,
                                title: "Makan Malam",
                                page: PackagePage(
                                  name: displayName,
                                  email: displayEmail,
                                  scrollTo: "makan_malam",
                                ),
                              ),
                              CategoryCard(
                                icon: Icons.cookie,
                                title: "Snack",
                                page: PackagePage(
                                  name: displayName,
                                  email: displayEmail,
                                  scrollTo: "snack",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: SizedBox(
                              width: 230,
                              child: PackageSmallCard(
                                title: cheapestMenu?.title ?? "Mode Hemat",
                                subtitle: cheapestMenu == null
                                    ? "Menu belum tersedia"
                                    : "Mulai ${_formatRupiah(cheapestMenu.price)}",
                                page: PackagePage(
                                  name: displayName,
                                  email: displayEmail,
                                  scrollTo: "promo",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Jadwal Minggu Ini",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DashboardPage(
                                        name: displayName,
                                        email: displayEmail,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Lihat Semua",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildWeeklySchedule(data.orders),
                          const SizedBox(height: 80),
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
            const BottomMenu(
              icon: Icons.home,
              title: "Home",
              active: true,
            ),
            BottomMenu(
              icon: Icons.restaurant,
              title: "Paket",
              page: PackagePage(
                name: displayName,
                email: displayEmail,
                scrollTo: "",
              ),
            ),
            BottomMenu(
              icon: Icons.badge,
              title: "Dasbor",
              page: DashboardPage(
                name: displayName,
                email: displayEmail,
              ),
            ),
            BottomMenu(
              icon: Icons.person,
              title: "Profile",
              page: ProfilePage(
                name: displayName,
                email: displayEmail,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner(_MenuData? menu) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4B8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 135,
            height: 105,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: menu == null || menu.imageUrl.isEmpty
                ? const Icon(
                    Icons.restaurant_menu,
                    size: 70,
                    color: Colors.orange,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      menu.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                        Icons.restaurant_menu,
                        size: 70,
                        color: Colors.orange,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "PROMO PILIHAN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  menu?.title ?? "Menu belum tersedia",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  menu?.description ?? "Data menu dari backend belum tersedia.",
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 34,
                  width: 110,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PackagePage(
                            name: displayName,
                            email: displayEmail,
                            scrollTo: "promo",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB84D),
                    ),
                    child: const Text(
                      "Lihat Paket",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule(List<_OrderData> orders) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final weekDates = List.generate(
      6,
      (index) => DateTime(monday.year, monday.month, monday.day + index),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(weekDates.length, (index) {
        final date = weekDates[index];

        final hasOrder = orders.any((order) {
          final orderDate = order.date;

          if (orderDate == null) return false;

          return orderDate.year == date.year &&
              orderDate.month == date.month &&
              orderDate.day == date.day;
        });

        final active = selectedDay == index;

        return DayCard(
          day: _dayName(date.weekday),
          date: "${date.day}",
          active: active,
          muted: !hasOrder,
          onTap: () => setState(() => selectedDay = index),
        );
      }),
    );
  }

  String _dayName(int weekday) {
    const days = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];

    return days[weekday - 1];
  }

  static Widget _infoBox({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeData {
  final List<_MenuData> menus;
  final List<_OrderData> orders;

  const _HomeData({
    required this.menus,
    required this.orders,
  });
}

class _MenuData {
  final int id;
  final String title;
  final int price;
  final String description;
  final String imageUrl;
  final String category;

  const _MenuData({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  factory _MenuData.fromJson(Map<String, dynamic> json) {
    final kategori = _asMap(json['kategori']);
    final paket = _asMap(json['paket']);

    final rawImage = _readString(
      json,
      [
        'gambar',
        'gambar_menu',
        'foto',
        'foto_menu',
        'image',
        'image_url',
        'url_gambar',
      ],
      fallback: '',
    );

    final categoryFromKategori = kategori == null
        ? ''
        : _readString(kategori, ['nama_kategori', 'nama'], fallback: '');

    final categoryFromPaket = paket == null
        ? ''
        : _readString(paket, ['jenis_paket', 'nama_paket'], fallback: '');

    final categoryFromJson = _readString(
      json,
      ['nama_kategori', 'jenis_paket', 'category', 'kategori_menu'],
      fallback: '',
    );

    final category = categoryFromKategori.isNotEmpty
        ? categoryFromKategori
        : categoryFromPaket.isNotEmpty
            ? categoryFromPaket
            : categoryFromJson.isNotEmpty
                ? categoryFromJson
                : 'lainnya';

    return _MenuData(
      id: _readInt(json, ['menu_id', 'id', 'paket_id']),
      title: _readString(
        json,
        ['nama_menu', 'nama_paket', 'name', 'title'],
        fallback: 'Menu',
      ),
      price: _readNumber(
        json,
        ['harga_menu', 'harga', 'price', 'total'],
      ).round(),
      description: _readString(
        json,
        ['deskripsi', 'description', 'keterangan'],
        fallback: 'Tidak ada deskripsi menu.',
      ),
      imageUrl: _resolveImageUrl(rawImage),
      category: category.toLowerCase(),
    );
  }
}

class _OrderData {
  final String id;
  final DateTime? date;

  const _OrderData({
    required this.id,
    required this.date,
  });

  factory _OrderData.fromJson(Map<String, dynamic> json) {
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
      date: DateTime.tryParse(rawDate),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? page;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: page == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page!),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4B8),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class DayCard extends StatelessWidget {
  final String day;
  final String date;
  final bool active;
  final bool muted;
  final VoidCallback onTap;

  const DayCard({
    super.key,
    required this.day,
    required this.date,
    required this.onTap,
    this.active = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFD98F) : const Color(0xFFFFF1D9),
          border: Border.all(color: active ? Colors.orange : Colors.black26),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(
              day,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              width: 23,
              height: 23,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
              ),
              child: muted
                  ? const Icon(Icons.volume_off, size: 14, color: Colors.black)
                  : Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackageSmallCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? page;

  const PackageSmallCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: page == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page!),
              );
            },
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4B8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.orange, width: 1.6),
              ),
              child: const Icon(Icons.bolt, color: Colors.black, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final Widget? page;

  const BottomMenu({
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
    if (data['menu'] is List) return data['menu'];
    if (data['menus'] is List) return data['menus'];
    if (data['pesanan'] is List) return data['pesanan'];
    if (data['orders'] is List) return data['orders'];
    if (data['items'] is List) return data['items'];
    if (data['data'] is List) return data['data'];
    if (data['rows'] is List) return data['rows'];
  }

  if (decoded['menu'] is List) return decoded['menu'];
  if (decoded['menus'] is List) return decoded['menus'];
  if (decoded['pesanan'] is List) return decoded['pesanan'];
  if (decoded['orders'] is List) return decoded['orders'];
  if (decoded['items'] is List) return decoded['items'];

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

String _resolveImageUrl(String value) {
  if (value.isEmpty || value == '-') {
    return '';
  }

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }

  if (value.startsWith('/')) {
    return '${api.ApiConfig.baseUrl}$value';
  }

  return '${api.ApiConfig.baseUrl}/$value';
}
