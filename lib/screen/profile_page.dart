import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart' as api;
import '../services/app_session.dart';
import '../services/app_settings.dart';

import 'dashboard_page.dart';
import 'package_page.dart';
import 'user_home_page.dart';
import 'welcome_page.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final String email;

  const ProfilePage({
    super.key,
    this.name = 'User',
    this.email = 'user@mail.com',
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<_ProfileScreenData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileData();
  }

  Future<_ProfileScreenData> _loadProfileData() async {
    final profile = await _fetchProfile();
    final totalOrders = await _fetchTotalOrders();

    return _ProfileScreenData(
      profile: profile,
      totalOrders: totalOrders,
    );
  }

  Future<_ProfileData> _fetchProfile() async {
    if (!AppSession.isLoggedIn) {
      return _ProfileData(
        name: widget.name,
        email: widget.email,
      );
    }

    final response = await http.get(
      Uri.parse(api.ApiConfig.profile),
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
      throw Exception(message ?? 'Gagal memuat profil');
    }

    if (decoded is Map<String, dynamic>) {
      return _ProfileData.fromJson(decoded);
    }

    return _ProfileData(
      name: widget.name,
      email: widget.email,
    );
  }

  Future<int> _fetchTotalOrders() async {
    if (!AppSession.isLoggedIn) return 0;

    try {
      final response = await http.get(
        Uri.parse('${api.ApiConfig.pesanan}?page=1&limit=100'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AppSession.authorizationHeader,
        },
      );

      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return 0;
      }

      return _extractList(decoded).length;
    } catch (_) {
      return 0;
    }
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _loadProfileData();
    });
  }

  Future<void> _openEditProfile(_ProfileData profile) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(profile: profile),
      ),
    );

    if (updated == true) {
      _refreshProfile();
    }
  }

  void _logout() {
    AppSession.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomePage(),
      ),
      (route) => false,
    );
  }

  void _openThemeSettings() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _ThemeSettingsSheet(onChanged: () => setState(() {}));
      },
    );
  }

  void _openLanguageSettings() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _LanguageSettingsSheet(onChanged: () => setState(() {}));
      },
    );
  }

  void _openAddressSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _AddressSettingsSheet(onChanged: () => setState(() {}));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfileScreenData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  const CustomHeader(),
                  Expanded(
                    child: Center(
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
                              'Profil belum bisa dimuat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              snapshot.error
                                  .toString()
                                  .replaceFirst('Exception: ', ''),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: _refreshProfile,
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
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data ??
            _ProfileScreenData(
              profile: _ProfileData(
                name: widget.name,
                email: widget.email,
              ),
              totalOrders: 0,
            );

        final profile = data.profile;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                const CustomHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _refreshProfile();
                      await _profileFuture;
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ProfileInfoCard(
                            name: loading ? 'Memuat...' : profile.name,
                            email: loading ? 'Memuat...' : profile.email,
                            phone: profile.phone,
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: 120,
                              child: _OrderTotalCard(total: data.totalOrders),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SectionCard(
                            title: "Akun",
                            icon: Icons.person,
                            children: [
                              ProfileMenuItem(
                                icon: Icons.person_outline,
                                title: "Edit Profile",
                                onTap: () => _openEditProfile(profile),
                              ),
                              ProfileMenuItem(
                                icon: Icons.lock_outline,
                                title: "Ganti Password",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangePasswordPage(profile: profile),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SectionCard(
                                  title: "Pengaturan",
                                  icon: Icons.settings_outlined,
                                  children: [
                                    const ProfileMenuItem(
                                      icon: Icons.notifications_none,
                                      title: "Notifikasi",
                                      onTap: null,
                                    ),
                                    ProfileMenuItem(
                                      icon: Icons.language,
                                      title:
                                          "Bahasa (${_languageLabel(AppSettings.instance.language)})",
                                      onTap: _openLanguageSettings,
                                    ),
                                    ProfileMenuItem(
                                      icon: Icons.dark_mode,
                                      title:
                                          "Tema (${_themeLabel(AppSettings.instance.themeMode)})",
                                      onTap: _openThemeSettings,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SectionCard(
                                  title: "Layanan",
                                  icon: Icons.shopping_bag_outlined,
                                  children: [
                                    const ProfileMenuItem(
                                      icon: Icons.receipt_long,
                                      title: "Riwayat Pesanan",
                                      onTap: null,
                                    ),
                                    ProfileMenuItem(
                                      icon: Icons.location_on_outlined,
                                      title: "Alamat",
                                      subtitle: AppSettings.instance.address,
                                      onTap: _openAddressSettings,
                                    ),
                                    const ProfileMenuItem(
                                      icon: Icons.help_outline,
                                      title: "Pusat Bantuan",
                                      onTap: null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.redAccent,
                              ),
                              label: const Text(
                                "Keluar Akun",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.redAccent,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
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
                ProfileBottomMenu(
                  icon: Icons.home,
                  title: "Home",
                  page: UserHomePage(
                    name: profile.name,
                    email: profile.email,
                  ),
                ),
                ProfileBottomMenu(
                  icon: Icons.restaurant,
                  title: "Paket",
                  page: PackagePage(
                    name: profile.name,
                    email: profile.email,
                  ),
                ),
                const ProfileBottomMenu(
                  icon: Icons.badge,
                  title: "Dasbor",
                  page: DashboardPage(),
                ),
                const ProfileBottomMenu(
                  icon: Icons.person,
                  title: "Profile",
                  active: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileScreenData {
  final _ProfileData profile;
  final int totalOrders;

  const _ProfileScreenData({
    required this.profile,
    required this.totalOrders,
  });
}

class _ProfileData {
  final String name;
  final String email;
  final String phone;
  final String address;

  const _ProfileData({
    required this.name,
    required this.email,
    this.phone = '-',
    this.address = '-',
  });

  factory _ProfileData.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final userFromRoot = _asMap(json['user']);
    final userFromData = data == null ? null : _asMap(data['user']);

    final source = userFromData ?? userFromRoot ?? data ?? json;

    return _ProfileData(
      name: _readString(
        source,
        ['nama_lengkap', 'name', 'nama', 'username'],
        fallback: 'User',
      ),
      email: _readString(
        source,
        ['email'],
        fallback: 'user@mail.com',
      ),
      phone: _readString(
        source,
        ['nomor_hp', 'phone', 'phone_number', 'no_hp'],
        fallback: '-',
      ),
      address: _readString(
        source,
        ['alamat', 'address', 'alamat_lengkap'],
        fallback: '-',
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final _ProfileData profile;

  const EditProfilePage({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.profile.name);
    phoneController = TextEditingController(
      text: widget.profile.phone == '-' ? '' : widget.profile.phone,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!AppSession.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse(api.ApiConfig.profile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AppSession.authorizationHeader,
        },
        body: jsonEncode({
          'nama_lengkap': name,
          'nomor_hp': phone,
        }),
      );

      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final currentUser = AppSession.user ?? {};
        AppSession.user = {
          ...currentUser,
          'nama_lengkap': name,
          'nomor_hp': phone,
        };

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile berhasil diperbarui!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, true);
      } else {
        final message = decoded is Map<String, dynamic>
            ? decoded['message']?.toString()
            : null;

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message ?? 'Gagal memperbarui profil'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak bisa terhubung ke backend: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ProfileInfoCard(
                      name: widget.profile.name,
                      email: widget.profile.email,
                      phone: widget.profile.phone,
                    ),
                    const SizedBox(height: 30),
                    PillInputField(
                      label: "Nama lengkap",
                      controller: nameController,
                    ),
                    const SizedBox(height: 15),
                    PillInputField(
                      label: "Nomor HP",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 30),
                    SaveButton(
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _updateProfile,
                    ),
                    const SizedBox(height: 60),
                    const BackRedButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  final _ProfileData profile;

  const ChangePasswordPage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ProfileInfoCard(
                      name: profile.name,
                      email: profile.email,
                      phone: profile.phone,
                    ),
                    const SizedBox(height: 30),
                    PillInputField(
                      label: "Password lama",
                      controller: oldPasswordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 15),
                    PillInputField(
                      label: "Password baru",
                      controller: newPasswordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 15),
                    PillInputField(
                      label: "Ulangi password baru",
                      controller: confirmPasswordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),
                    SaveButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Endpoint ganti password belum disiapkan di frontend.",
                            ),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 60),
                    const BackRedButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSettingsSheet extends StatelessWidget {
  final VoidCallback onChanged;

  const _ThemeSettingsSheet({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = AppSettings.instance.themeMode;

    return _SettingsSheetFrame(
      title: 'Tema',
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: selected,
            onChanged: (value) {
              if (value == null) return;
              AppSettings.instance.setThemeMode(value);
              onChanged();
              Navigator.pop(context);
            },
            secondary: const Icon(Icons.light_mode_outlined),
            title: const Text('Light'),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: selected,
            onChanged: (value) {
              if (value == null) return;
              AppSettings.instance.setThemeMode(value);
              onChanged();
              Navigator.pop(context);
            },
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark'),
          ),
        ],
      ),
    );
  }
}

class _LanguageSettingsSheet extends StatelessWidget {
  final VoidCallback onChanged;

  const _LanguageSettingsSheet({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = AppSettings.instance.language;

    return _SettingsSheetFrame(
      title: 'Bahasa',
      child: Column(
        children: [
          RadioListTile<AppLanguage>(
            value: AppLanguage.indonesian,
            groupValue: selected,
            onChanged: (value) {
              if (value == null) return;
              AppSettings.instance.setLanguage(value);
              onChanged();
              Navigator.pop(context);
            },
            secondary: const Icon(Icons.translate),
            title: const Text('Indonesia'),
          ),
          RadioListTile<AppLanguage>(
            value: AppLanguage.english,
            groupValue: selected,
            onChanged: (value) {
              if (value == null) return;
              AppSettings.instance.setLanguage(value);
              onChanged();
              Navigator.pop(context);
            },
            secondary: const Icon(Icons.language),
            title: const Text('English'),
          ),
        ],
      ),
    );
  }
}

class _AddressSettingsSheet extends StatefulWidget {
  final VoidCallback onChanged;

  const _AddressSettingsSheet({required this.onChanged});

  @override
  State<_AddressSettingsSheet> createState() => _AddressSettingsSheetState();
}

class _AddressSettingsSheetState extends State<_AddressSettingsSheet> {
  late final TextEditingController _addressController;
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: AppSettings.instance.manualAddress,
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _saveManualAddress() {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat tidak boleh kosong')),
      );
      return;
    }

    AppSettings.instance.setManualAddress(address);
    widget.onChanged();
    Navigator.pop(context);
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi HP belum aktif');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi belum diberikan');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final locationText =
          'Lokasi saat ini: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';

      AppSettings.instance.setCurrentLocationAddress(locationText);
      widget.onChanged();

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final addressMode = AppSettings.instance.addressMode;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: _SettingsSheetFrame(
        title: 'Alamat',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<AddressMode>(
              value: AddressMode.manual,
              groupValue: addressMode,
              onChanged: (_) {},
              secondary: const Icon(Icons.edit_location_alt_outlined),
              title: const Text('Alamat sendiri'),
              subtitle: const Text('Tulis alamat pengiriman customer'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat lengkap',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _saveManualAddress,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan Alamat Sendiri'),
              ),
            ),
            const SizedBox(height: 14),
            RadioListTile<AddressMode>(
              value: AddressMode.currentLocation,
              groupValue: addressMode,
              onChanged: (_) => _useCurrentLocation(),
              secondary: const Icon(Icons.my_location),
              title: const Text('Sesuai lokasi HP saat ini'),
              subtitle: Text(AppSettings.instance.currentLocationAddress.isEmpty
                  ? 'Ambil koordinat lokasi customer sekarang'
                  : AppSettings.instance.currentLocationAddress),
            ),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: _loadingLocation ? null : _useCurrentLocation,
                icon: _loadingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(
                  _loadingLocation ? 'Mengambil Lokasi...' : 'Gunakan Lokasi HP',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSheetFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSheetFrame({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      color: const Color(0xFFFFB84D),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, color: Color(0xFFFFB84D), size: 20),
          ),
          Icon(Icons.notifications, color: Colors.black, size: 28),
        ],
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const ProfileInfoCard({
    super.key,
    required this.name,
    required this.email,
    this.phone = '-',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4B8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, size: 55, color: Color(0xFFFFE4B8)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  phone == '-' ? 'Nomor HP belum tersedia' : phone,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "#1 Campus Food Solution",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
}

class _OrderTotalCard extends StatelessWidget {
  final int total;

  const _OrderTotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4B8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long, size: 30, color: Colors.black),
          const SizedBox(height: 6),
          Text(
            "$total",
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const Text(
            "Total Pesanan",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Pesanan akun ini",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class PillInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;

  const PillInputField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SaveButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC9F5CF)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 3)),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF89C66B),
                ),
              )
            : const Text(
                "SAVE",
                style: TextStyle(
                  color: Color(0xFF89C66B),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}

class BackRedButton extends StatelessWidget {
  const BackRedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.keyboard_return, color: Colors.redAccent),
        label: const Text(
          "Kembali",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4B8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.black54),
          ...children,
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

class ProfileBottomMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final Widget? page;

  const ProfileBottomMenu({
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
          : () => Navigator.pushReplacement(context, _noAnimationRoute(page!)),
      child: Container(
        width: 55,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE08A1E) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.black),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 9, color: Colors.black),
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

String _themeLabel(ThemeMode mode) {
  return mode == ThemeMode.dark ? 'Dark' : 'Light';
}

String _languageLabel(AppLanguage language) {
  return language == AppLanguage.english ? 'Eng' : 'Ind';
}