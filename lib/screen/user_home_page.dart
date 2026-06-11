import 'package:flutter/material.dart';
import 'package:kepakno_app/screen/package_page.dart';
import 'package:kepakno_app/screen/dashboard_page.dart';
import 'package:kepakno_app/screen/profile_page.dart';
import 'package:kepakno_app/screen/saldo_page.dart'; // IMPORT PENTING: Untuk mengenalkan halaman Saldo

class UserHomePage extends StatefulWidget {
  final String name;
  final String email;

  const UserHomePage({super.key, required this.name, required this.email});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int selectedDay = 0;

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
                    "Hi, ${widget.name}",
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _infoBox(
                          icon: Icons.account_balance_wallet,
                          title: "Saldo",
                          subtitle: "Rp. 0",
                          color: const Color(0xFFFFD98F),
                          // --- DI SINI KUNCI KLIKNYA ---
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SaldoPage(
                                  name: widget.name,
                                  email: widget.email,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 14),
                        _infoBox(
                          icon: Icons.history,
                          title: "Riwayat",
                          subtitle: "Pemesanan",
                          color: const Color(0xFFC9F5CF),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Container(
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
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 70,
                              color: Colors.orange,
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
                                    "PROMO 20%",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Paket Nasi Kebuli",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "• Nasi kebuli\n• Sate\n• Sambal goreng\n• Acar",
                                  style: TextStyle(fontSize: 11),
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
                                            name: widget.name,
                                            email: widget.email,
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
                    ),

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
                            name: widget.name,
                            email: widget.email,
                            scrollTo: "sarapan",
                          ),
                        ),

                        CategoryCard(
                          icon: Icons.wb_sunny,
                          title: "Makan Siang",
                          page: PackagePage(
                            name: widget.name,
                            email: widget.email,
                            scrollTo: "makan_siang",
                          ),
                        ),

                        CategoryCard(
                          icon: Icons.nightlight_round,
                          title: "Makan Malam",
                          page: PackagePage(
                            name: widget.name,
                            email: widget.email,
                            scrollTo: "makan_malam",
                          ),
                        ),

                        CategoryCard(
                          icon: Icons.cookie,
                          title: "Snack",
                          page: PackagePage(
                            name: widget.name,
                            email: widget.email,
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
                          title: "Mode Hemat",
                          subtitle: "Mulai Rp. 15rb",
                          page: PackagePage(
                            name: widget.name,
                            email: widget.email,
                            scrollTo: "promo",
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Jadwal Minggu Ini",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Lihat Semua", style: TextStyle(fontSize: 11)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DayCard(
                          day: "Sen",
                          date: "1",
                          active: selectedDay == 0,
                          onTap: () => setState(() => selectedDay = 0),
                        ),

                        DayCard(
                          day: "Sel",
                          date: "2",
                          active: selectedDay == 1,
                          onTap: () => setState(() => selectedDay = 1),
                        ),

                        DayCard(
                          day: "Rab",
                          date: "3",
                          active: selectedDay == 2,
                          onTap: () => setState(() => selectedDay = 2),
                        ),

                        DayCard(
                          day: "Kam",
                          date: "4",
                          active: selectedDay == 3,
                          onTap: () => setState(() => selectedDay = 3),
                        ),

                        DayCard(
                          day: "Jum",
                          date: "",
                          muted: true,
                          active: selectedDay == 4,
                          onTap: () => setState(() => selectedDay = 4),
                        ),

                        DayCard(
                          day: "Sab",
                          date: "6",
                          active: selectedDay == 5,
                          onTap: () => setState(() => selectedDay = 5),
                        ),
                      ],
                    ),

                    const SizedBox(height: 80),
                  ],
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
            const BottomMenu(icon: Icons.home, title: "Home", active: true),
            BottomMenu(
              icon: Icons.restaurant,
              title: "Paket",
              page: PackagePage(
                name: widget.name,
                email: widget.email,
                scrollTo: "",
              ),
            ),
            BottomMenu(
              icon: Icons.badge,
              title: "Dasbor",
              page: DashboardPage(name: widget.name, email: widget.email),
            ),
            BottomMenu(
              icon: Icons.person,
              title: "Profile",
              page: ProfilePage(name: widget.name, email: widget.email),
            ),
          ],
        ),
      ),
    );
  }

  // --- INFOBOX YANG SUDAH DIBUNGKUS INKWELL AGAR BISA DIKLIK ---
  static Widget _infoBox({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap, // <-- Parameter tambahan buat klik
  }) {
    return Expanded(
      child: InkWell(
        // <-- Pembungkus fungsi klik
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
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
