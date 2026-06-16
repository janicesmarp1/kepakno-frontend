import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart' as api;
import 'checkout_page.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';
import 'user_home_page.dart';

class MenuData {
  final int id;
  final String title;
  final int price;
  final String description;
  final String imageUrl;
  final String category;

  const MenuData({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  String get formattedPrice => _formatRupiah(price);

  factory MenuData.fromJson(Map<String, dynamic> json) {
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
        : _readString(
            kategori,
            ['nama_kategori', 'nama'],
            fallback: '',
          );

    final categoryFromPaket = paket == null
        ? ''
        : _readString(
            paket,
            ['jenis_paket', 'nama_paket'],
            fallback: '',
          );

    final categoryFromJson = _readString(
      json,
      [
        'nama_kategori',
        'jenis_paket',
        'category',
        'kategori_menu',
      ],
      fallback: '',
    );

    final category = categoryFromKategori.isNotEmpty
        ? categoryFromKategori
        : categoryFromPaket.isNotEmpty
            ? categoryFromPaket
            : categoryFromJson.isNotEmpty
                ? categoryFromJson
                : 'lainnya';

    return MenuData(
      id: _readInt(json, ['menu_id', 'id', 'paket_id']),
      title: _readString(
        json,
        [
          'nama_menu',
          'nama_paket',
          'name',
          'title',
        ],
        fallback: 'Menu',
      ),
      price: _readNumber(
        json,
        [
          'harga_menu',
          'harga',
          'price',
          'total',
        ],
      ).round(),
      description: _readString(
        json,
        [
          'deskripsi',
          'description',
          'keterangan',
        ],
        fallback: 'Tidak ada deskripsi menu.',
      ),
      imageUrl: _resolveImageUrl(rawImage),
      category: category.toLowerCase(),
    );
  }
}

class PackagePage extends StatefulWidget {
  final String name;
  final String email;
  final String scrollTo;

  const PackagePage({
    super.key,
    this.name = "User",
    this.email = "user@mail.com",
    this.scrollTo = "",
  });

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  final promoKey = GlobalKey();
  final sarapanKey = GlobalKey();
  final makanSiangKey = GlobalKey();
  final makanMalamKey = GlobalKey();
  final snackKey = GlobalKey();
  final lainnyaKey = GlobalKey();

  late Future<List<MenuData>> _menusFuture;
  bool _hasAutoScrolled = false;

  @override
  void initState() {
    super.initState();
    _menusFuture = _fetchMenus();
  }

  Future<List<MenuData>> _fetchMenus() async {
    final url = Uri.parse('${api.ApiConfig.menu}?page=1&limit=50');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;

      throw Exception(message ?? 'Gagal memuat data menu');
    }

    final rawMenus = _extractList(decoded);

    return rawMenus
        .whereType<Map>()
        .map((item) => MenuData.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  void _refreshMenus() {
    setState(() {
      _hasAutoScrolled = false;
      _menusFuture = _fetchMenus();
    });
  }

  void _autoScrollAfterDataLoaded() {
    if (_hasAutoScrolled || widget.scrollTo.isEmpty) return;

    _hasAutoScrolled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSection(widget.scrollTo);
    });
  }

  void scrollToSection(String section) {
    GlobalKey? targetKey;

    if (section == "promo") {
      targetKey = promoKey;
    } else if (section == "sarapan") {
      targetKey = sarapanKey;
    } else if (section == "makan_siang") {
      targetKey = makanSiangKey;
    } else if (section == "makan_malam") {
      targetKey = makanMalamKey;
    } else if (section == "snack") {
      targetKey = snackKey;
    }

    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _isSarapan(MenuData menu) {
    final text = '${menu.title} ${menu.category}'.toLowerCase();
    return text.contains('sarapan') || text.contains('pagi');
  }

  bool _isMakanSiang(MenuData menu) {
    final text = '${menu.title} ${menu.category}'.toLowerCase();
    return text.contains('siang') || text.contains('lunch');
  }

  bool _isMakanMalam(MenuData menu) {
    final text = '${menu.title} ${menu.category}'.toLowerCase();
    return text.contains('malam') || text.contains('dinner');
  }

  bool _isSnack(MenuData menu) {
    final text = '${menu.title} ${menu.category}'.toLowerCase();
    return text.contains('snack') ||
        text.contains('ringan') ||
        text.contains('cemilan') ||
        text.contains('camilan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              child: FutureBuilder<List<MenuData>>(
                future: _menusFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  final menus = snapshot.data ?? <MenuData>[];

                  final sarapan = menus.where(_isSarapan).toList();
                  final makanSiang = menus.where(_isMakanSiang).toList();
                  final makanMalam = menus.where(_isMakanMalam).toList();
                  final snack = menus.where(_isSnack).toList();

                  final categorizedMenus = <MenuData>[
                    ...sarapan,
                    ...makanSiang,
                    ...makanMalam,
                    ...snack,
                  ];

                  final lainnya = menus
                      .where((menu) => !categorizedMenus.contains(menu))
                      .toList();

                  _autoScrollAfterDataLoaded();

                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshMenus();
                      await _menusFuture;
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sectionTitle("Paket Promo", promoKey),
                          const SizedBox(height: 12),
                          _buildPromoBanner(
                            menus.isNotEmpty ? menus.first : null,
                          ),

                          const SizedBox(height: 25),
                          sectionTitle("Paket Sarapan", sarapanKey),
                          const SizedBox(height: 12),
                          _buildMenuSection(
                            menus: sarapan,
                            emptyMessage: 'Belum ada menu sarapan',
                          ),

                          const SizedBox(height: 25),
                          sectionTitle("Paket Makan Siang", makanSiangKey),
                          const SizedBox(height: 12),
                          _buildMenuSection(
                            menus: makanSiang,
                            emptyMessage: 'Belum ada menu makan siang',
                          ),

                          const SizedBox(height: 25),
                          sectionTitle("Paket Makan Malam", makanMalamKey),
                          const SizedBox(height: 12),
                          _buildMenuSection(
                            menus: makanMalam,
                            emptyMessage: 'Belum ada menu makan malam',
                          ),

                          const SizedBox(height: 25),
                          sectionTitle("Snack", snackKey),
                          const SizedBox(height: 12),
                          _buildMenuSection(
                            menus: snack,
                            emptyMessage: 'Belum ada menu snack',
                          ),

                          if (lainnya.isNotEmpty) ...[
                            const SizedBox(height: 25),
                            sectionTitle("Menu Lainnya", lainnyaKey),
                            const SizedBox(height: 12),
                            _buildMenuSection(
                              menus: lainnya,
                              emptyMessage: 'Belum ada menu lainnya',
                            ),
                          ],

                          const SizedBox(height: 20),
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
            PackageBottomMenu(
              icon: Icons.home,
              title: "Home",
              page: UserHomePage(name: widget.name, email: widget.email),
            ),
            const PackageBottomMenu(
              icon: Icons.restaurant,
              title: "Paket",
              active: true,
            ),
            const PackageBottomMenu(
              icon: Icons.badge,
              title: "Dasbor",
              page: DashboardPage(),
            ),
            PackageBottomMenu(
              icon: Icons.person,
              title: "Profile",
              page: ProfilePage(name: widget.name, email: widget.email),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title, GlobalKey key) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildMenuSection({
    required List<MenuData> menus,
    required String emptyMessage,
  }) {
    if (menus.isEmpty) {
      return _emptySection(emptyMessage);
    }

    return Column(
      children: menus
          .map(
            (menu) => _buildPackageItem(
              context,
              menu: menu,
            ),
          )
          .toList(),
    );
  }

  Widget _buildPromoBanner(MenuData? menu) {
    final title = menu?.title ?? 'Belum ada promo';
    final description = menu?.description ?? 'Data promo belum tersedia.';
    final imageUrl = menu?.imageUrl ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl.isEmpty
                    ? _buildImagePlaceholder()
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PROMO PILIHAN",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: menu == null
                        ? null
                        : () {
                            _openCheckout(menu);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFBF5E),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      "Pesan Sekarang",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageItem(
    BuildContext context, {
    required MenuData menu,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: menu.imageUrl.isEmpty
                ? _buildImagePlaceholder()
                : Image.network(
                    menu.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImagePlaceholder(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        menu.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      menu.formattedPrice,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    menu.category.isEmpty
                        ? "MENU"
                        : menu.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  menu.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _openCheckout(menu);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFFBF5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      "Pesan Sekarang",
                      style: TextStyle(
                        fontFamily: "Georgia",
                        color: Colors.black,
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

  void _openCheckout(MenuData menu) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          name: widget.name,
          email: widget.email,
          menuId: menu.id,
          packageName: menu.title,
          price: menu.price,
          description: menu.description,
          imageUrl: menu.imageUrl,
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
            const Icon(Icons.cloud_off, size: 44, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Menu belum bisa dimuat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              error.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _refreshMenus,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFBF5E),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptySection(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 50),
    );
  }
}

class PackageBottomMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final Widget? page;

  const PackageBottomMenu({
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => page!),
              );
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
    if (data['items'] is List) return data['items'];
    if (data['data'] is List) return data['data'];
    if (data['rows'] is List) return data['rows'];
    if (data['records'] is List) return data['records'];
  }

  if (decoded['menu'] is List) return decoded['menu'];
  if (decoded['menus'] is List) return decoded['menus'];
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