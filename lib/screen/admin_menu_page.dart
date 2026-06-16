import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/api_config.dart' as api;
import '../services/app_session.dart';
import 'admin_dashboard_page.dart';
import 'admin_notification_page.dart';
import 'admin_order_page.dart';
import 'admin_schedule_page.dart';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({super.key});

  static const Color _background = Color(0xFFFFF7EF);
  static const Color _green = Color(0xFF2E7D32);
  static const Color _yellow = Color(0xFFF5A623);
  static const Color _muted = Color(0xFF7B7067);
  static const Color _line = Color(0xFFE5E5E5);
  static const Color _priceGreen = Color(0xFF178A2F);

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  late Future<List<_MenuData>> _menusFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _menusFuture = _fetchMenus();
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (AppSession.isLoggedIn) {
      headers['Authorization'] = AppSession.authorizationHeader;
    }

    return headers;
  }

  Future<List<_MenuData>> _fetchMenus() async {
    final url = Uri.parse('${api.ApiConfig.menu}?page=1&limit=100');

    final response = await http.get(url, headers: _headers);
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
        .map((item) => _MenuData.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  void _refreshMenus() {
    setState(() {
      _menusFuture = _fetchMenus();
    });
  }

  List<_MenuData> _filterMenus(List<_MenuData> menus) {
    final keyword = _query.trim().toLowerCase();
    if (keyword.isEmpty) return menus;

    return menus.where((menu) {
      return menu.name.toLowerCase().contains(keyword) ||
          menu.category.toLowerCase().contains(keyword) ||
          menu.status.toLowerCase().contains(keyword);
    }).toList();
  }

  Future<void> _saveMenu(_MenuPayload payload, {_MenuData? oldMenu}) async {
    if (!AppSession.isLoggedIn) {
      throw Exception('Silakan login admin terlebih dahulu');
    }

    final isEdit = oldMenu != null;
    final url = isEdit
        ? Uri.parse('${api.ApiConfig.menu}/${oldMenu.id}')
        : Uri.parse(api.ApiConfig.menu);

    final request = http.MultipartRequest(
      isEdit ? 'PUT' : 'POST',
      url,
    );

    request.headers['Authorization'] = AppSession.authorizationHeader;

    request.fields['paket_id'] = payload.paketId.toString();
    request.fields['kategori_id'] = payload.kategoriId.toString();
    request.fields['tanggal_menu'] = payload.tanggalMenu;
    request.fields['nama_menu'] = payload.name;
    request.fields['deskripsi'] = payload.description;
    request.fields['harga_menu'] = payload.price.toString();
    request.fields['stok'] = payload.stock.toString();

    if (payload.photoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'foto_menu',
          payload.photoBytes!,
          filename: payload.photoFileName ?? 'menu.jpg',
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(message ?? 'Gagal menyimpan menu');
    }

    _refreshMenus();
  }

  Future<void> _deleteMenu(_MenuData menu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus menu?'),
        content: Text('Menu "${menu.name}" akan dihapus dari backend.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!AppSession.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login admin terlebih dahulu'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final url = Uri.parse('${api.ApiConfig.menu}/${menu.id}');

      final response = await http.delete(url, headers: _headers);
      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic>
            ? decoded['message']?.toString()
            : null;
        throw Exception(message ?? 'Gagal menghapus menu');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${menu.name} berhasil dihapus')),
      );

      _refreshMenus();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _openForm({_MenuData? menu}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _MenuFormSheet(
          menu: menu,
          onSave: (payload) async {
            await _saveMenu(payload, oldMenu: menu);
          },
        );
      },
    );
  }

  void _showDetail(_MenuData menu) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => _MenuDetailSheet(
        menu: menu,
        onEdit: () {
          Navigator.pop(context);
          _openForm(menu: menu);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminMenuPage._background,
      body: SafeArea(
        child: FutureBuilder<List<_MenuData>>(
          future: _menusFuture,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState == ConnectionState.waiting;

            if (snapshot.hasError) {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: _Header(),
                  ),
                  Expanded(
                    child: _ErrorState(
                      message: snapshot.error
                          .toString()
                          .replaceFirst('Exception: ', ''),
                      onRetry: _refreshMenus,
                    ),
                  ),
                ],
              );
            }

            final allMenus = snapshot.data ?? <_MenuData>[];
            final menus = _filterMenus(allMenus);
            final activeTotal =
                allMenus.where((menu) => menu.status == 'Aktif').length;

            return RefreshIndicator(
              onRefresh: () async {
                _refreshMenus();
                await _menusFuture;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Header(),
                    const _WelcomeCard(),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.restaurant_menu,
                            value: loading ? '...' : '${allMenus.length}',
                            title: 'Total Menu',
                            color: const Color(0xFFE5F6E8),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.check_circle_outline,
                            value: loading ? '...' : '$activeTotal',
                            title: 'Menu Aktif',
                            color: const Color(0xFFFFF1D9),
                            iconColor: AdminMenuPage._yellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SearchAndAddBar(
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                      onAdd: () => _openForm(),
                    ),
                    const SizedBox(height: 14),
                    if (loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (menus.isEmpty)
                      const _EmptyMenuState()
                    else
                      ...menus.expand(
                        (menu) => [
                          _MenuCard(
                            menu: menu,
                            onDetail: () => _showDetail(menu),
                            onEdit: () => _openForm(menu: menu),
                            onDelete: () => _deleteMenu(menu),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    const SizedBox(height: 70),
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
}

class _MenuData {
  final int id;
  final int paketId;
  final int kategoriId;
  final String name;
  final String category;
  final int price;
  final int stock;
  final String status;
  final String tanggalMenu;
  final String description;
  final String imageUrl;

  const _MenuData({
    required this.id,
    required this.paketId,
    required this.kategoriId,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.status,
    required this.tanggalMenu,
    required this.description,
    required this.imageUrl,
  });

  factory _MenuData.fromJson(Map<String, dynamic> json) {
    final kategori = _asMap(json['kategori']);
    final paket = _asMap(json['paket']);

    final category = _readString(
      kategori ?? json,
      ['nama_kategori', 'category', 'kategori_menu'],
      fallback: _readString(
        paket ?? json,
        ['jenis_paket', 'nama_paket'],
        fallback: 'Kategori belum tersedia',
      ),
    );

    final stock = _readInt(json, ['stok', 'stock']);

    return _MenuData(
      id: _readInt(json, ['menu_id', 'id']),
      paketId: _readInt(json, ['paket_id']),
      kategoriId: _readInt(json, ['kategori_id']),
      name: _readString(
        json,
        ['nama_menu', 'nama_paket', 'name', 'title'],
        fallback: 'Menu',
      ),
      category: category,
      price: _readNumber(json, ['harga_menu', 'harga', 'price']).round(),
      stock: stock,
      status: stock > 0 ? 'Aktif' : 'Habis',
      tanggalMenu: _readString(
        json,
        ['tanggal_menu', 'tanggal', 'date'],
        fallback: _todayDate(),
      ),
      description: _readString(
        json,
        ['deskripsi', 'description', 'keterangan'],
        fallback: 'Tidak ada deskripsi menu.',
      ),
      imageUrl: _resolveImageUrl(
        _readString(
          json,
          ['foto_menu', 'gambar', 'gambar_menu', 'foto', 'image', 'image_url'],
          fallback: '',
        ),
      ),
    );
  }
}

class _MenuPayload {
  final int paketId;
  final int kategoriId;
  final String tanggalMenu;
  final String name;
  final String description;
  final int price;
  final int stock;
  final Uint8List? photoBytes;
  final String? photoFileName;

  const _MenuPayload({
    required this.paketId,
    required this.kategoriId,
    required this.tanggalMenu,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.photoBytes,
    this.photoFileName,
  });
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
            'Kelola Menu',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
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
            icon: const Icon(Icons.notifications, size: 30),
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

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final Color color;
  final Color iconColor;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.title,
    required this.color,
    this.iconColor = AdminMenuPage._green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndAddBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;

  const _SearchAndAddBar({
    required this.onChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Cari menu...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          onPressed: onAdd,
          tooltip: 'Tambah menu',
          style: IconButton.styleFrom(
            backgroundColor: AdminMenuPage._green,
            foregroundColor: Colors.white,
            fixedSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final _MenuData menu;
  final VoidCallback onDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuCard({
    required this.menu,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MenuPhoto(imageUrl: menu.imageUrl, size: 72),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        menu.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _StatusBadge(status: menu.status),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  menu.category,
                  style: const TextStyle(
                    color: AdminMenuPage._muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatRupiah(menu.price),
                        style: const TextStyle(
                          color: AdminMenuPage._priceGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      'Stok ${menu.stock}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _SmallActionButton(
                      icon: Icons.visibility_outlined,
                      label: 'Detail',
                      onTap: onDetail,
                    ),
                    const SizedBox(width: 6),
                    _SmallActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onTap: onEdit,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onDelete,
                      tooltip: 'Hapus menu',
                      visualDensity: VisualDensity.compact,
                      constraints:
                          const BoxConstraints.tightFor(width: 32, height: 32),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 19,
                        color: Colors.redAccent,
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

class _MenuPhoto extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _MenuPhoto({
    required this.imageUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFFFFF1D9),
        child: imageUrl.isEmpty
            ? const Icon(
                Icons.add_photo_alternate_outlined,
                color: AdminMenuPage._muted,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AdminMenuPage._muted,
                ),
              ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final active = status == 'Aktif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE5F6E8) : const Color(0xFFFFE8C7),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: active ? AdminMenuPage._green : AdminMenuPage._yellow,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AdminMenuPage._green,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _MenuFormSheet extends StatefulWidget {
  final _MenuData? menu;
  final Future<void> Function(_MenuPayload payload) onSave;

  const _MenuFormSheet({
    this.menu,
    required this.onSave,
  });

  @override
  State<_MenuFormSheet> createState() => _MenuFormSheetState();
}

class _MenuFormSheetState extends State<_MenuFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _paketIdController;
  late final TextEditingController _kategoriIdController;
  late final TextEditingController _dateController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;

  bool _isSaving = false;

  Uint8List? _photoBytes;
  String? _photoFileName;

  @override
  void initState() {
    super.initState();

    final menu = widget.menu;

    _nameController = TextEditingController(text: menu?.name ?? '');
    _categoryController = TextEditingController(text: menu?.category ?? '');
    _paketIdController = TextEditingController(
      text: menu == null || menu.paketId == 0 ? '1' : menu.paketId.toString(),
    );
    _kategoriIdController = TextEditingController(
      text: menu == null || menu.kategoriId == 0
          ? '1'
          : menu.kategoriId.toString(),
    );
    _dateController = TextEditingController(
      text: menu?.tanggalMenu ?? _todayDate(),
    );
    _priceController = TextEditingController(
      text: menu == null ? '' : menu.price.toString(),
    );
    _stockController = TextEditingController(
      text: menu == null ? '' : menu.stock.toString(),
    );
    _descriptionController = TextEditingController(
      text: menu?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _paketIdController.dispose();
    _kategoriIdController.dispose();
    _dateController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    if (!mounted) return;

    setState(() {
      _photoBytes = bytes;
      _photoFileName = image.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = _MenuPayload(
      paketId: int.tryParse(_onlyDigits(_paketIdController.text)) ?? 1,
      kategoriId: int.tryParse(_onlyDigits(_kategoriIdController.text)) ?? 1,
      tanggalMenu: _dateController.text.trim(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: int.tryParse(_onlyDigits(_priceController.text)) ?? 0,
      stock: int.tryParse(_onlyDigits(_stockController.text)) ?? 0,
      photoBytes: _photoBytes,
      photoFileName: _photoFileName,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDate: DateTime.tryParse(_dateController.text) ?? now,
    );

    if (selected == null) return;

    _dateController.text =
        '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.58,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AdminMenuPage._line,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.menu == null ? 'Tambah Menu' : 'Edit Menu',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 120,
                      height: 120,
                      color: const Color(0xFFFFF1D9),
                      child: _photoBytes != null
                          ? Image.memory(
                              _photoBytes!,
                              fit: BoxFit.cover,
                            )
                          : widget.menu != null &&
                                  widget.menu!.imageUrl.isNotEmpty
                              ? Image.network(
                                  widget.menu!.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 42,
                                    color: AdminMenuPage._muted,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 42,
                                  color: AdminMenuPage._muted,
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      _photoBytes == null
                          ? 'Pilih Foto dari Gallery'
                          : 'Ganti Foto',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminMenuPage._green,
                      side: const BorderSide(color: AdminMenuPage._green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _TextInput(
                  controller: _nameController,
                  label: 'Nama Menu',
                  hint: 'Contoh: Soto Ayam',
                  icon: Icons.restaurant_menu,
                ),
                const SizedBox(height: 12),
                _TextInput(
                  controller: _categoryController,
                  label: 'Kategori Tampilan',
                  hint: 'Sarapan, Makan Siang, Makan Malam',
                  icon: Icons.category_outlined,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TextInput(
                        controller: _paketIdController,
                        label: 'Paket ID',
                        hint: '1',
                        icon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TextInput(
                        controller: _kategoriIdController,
                        label: 'Kategori ID',
                        hint: '1',
                        icon: Icons.category,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tanggal menu wajib diisi';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Tanggal Menu',
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: const Icon(Icons.date_range),
                    filled: true,
                    fillColor: const Color(0xFFFFF7EF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TextInput(
                        controller: _priceController,
                        label: 'Harga',
                        hint: '12000',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TextInput(
                        controller: _stockController,
                        label: 'Stok',
                        hint: '50',
                        icon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TextInput(
                  controller: _descriptionController,
                  label: 'Detail Menu',
                  hint: 'Isi menu, bahan utama, catatan alergi, dll.',
                  icon: Icons.notes_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminMenuPage._green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _TextInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFFFF7EF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _MenuDetailSheet extends StatelessWidget {
  final _MenuData menu;
  final VoidCallback onEdit;

  const _MenuDetailSheet({
    required this.menu,
    required this.onEdit,
  });

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
                    color: AdminMenuPage._line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _MenuPhoto(imageUrl: menu.imageUrl, size: 400),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      menu.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _StatusBadge(status: menu.status),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                menu.category,
                style: const TextStyle(
                  color: AdminMenuPage._muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _DetailSection(
                title: 'Informasi Menu',
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.payments_outlined,
                      text: _formatRupiah(menu.price),
                    ),
                    const SizedBox(height: 9),
                    _DetailRow(
                      icon: Icons.date_range,
                      text: menu.tanggalMenu,
                    ),
                    const SizedBox(height: 9),
                    _DetailRow(
                      icon: Icons.inventory_2_outlined,
                      text: 'Stok ${menu.stock}',
                    ),
                    const SizedBox(height: 9),
                    _DetailRow(
                      icon: Icons.numbers,
                      text:
                          'Paket ID ${menu.paketId} • Kategori ID ${menu.kategoriId}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _DetailSection(
                title: 'Detail Menu',
                child: Text(
                  menu.description,
                  style: const TextStyle(fontSize: 12, height: 1.45),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Menu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminMenuPage._green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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

  const _DetailSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminMenuPage._line),
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

  const _DetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AdminMenuPage._muted),
        const SizedBox(width: 9),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}

class _EmptyMenuState extends StatelessWidget {
  const _EmptyMenuState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: _cardDecoration(),
      child: const Center(
        child: Text(
          'Menu tidak ditemukan',
          style: TextStyle(color: AdminMenuPage._muted, fontSize: 12),
        ),
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
            const Icon(Icons.cloud_off, color: Colors.redAccent, size: 44),
            const SizedBox(height: 12),
            const Text(
              'Data menu belum bisa dimuat',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminMenuPage._green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
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
          _AdminBottomMenu(
            icon: Icons.receipt_long,
            title: 'Pesanan',
            onTap: () {
              Navigator.pushReplacement(
                context,
                _noAnimationRoute(const AdminOrderPage()),
              );
            },
          ),
          const _AdminBottomMenu(
            icon: Icons.restaurant_menu,
            title: 'Menu',
            active: true,
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
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFB84D) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21),
            Text(title, style: const TextStyle(fontSize: 9)),
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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 5, offset: Offset(0, 2)),
    ],
  );
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;

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
    if (data['menu'] is List) return data['menu'];
    if (data['menus'] is List) return data['menus'];
    if (data['items'] is List) return data['items'];
    if (data['data'] is List) return data['data'];
    if (data['rows'] is List) return data['rows'];
  }

  if (decoded['menu'] is List) return decoded['menu'];
  if (decoded['menus'] is List) return decoded['menus'];
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

String _onlyDigits(String value) {
  return value.replaceAll(RegExp(r'[^0-9]'), '');
}

String _todayDate() {
  final now = DateTime.now();

  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String _resolveImageUrl(String value) {
  if (value.isEmpty || value == '-') return '';

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }

  if (value.startsWith('/')) {
    return '${api.ApiConfig.baseUrl}$value';
  }

  return '${api.ApiConfig.baseUrl}/$value';
}