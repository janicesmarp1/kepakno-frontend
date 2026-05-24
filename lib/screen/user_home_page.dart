import 'package:flutter/material.dart';
import 'package:kepakno_app/screen/package_page.dart';
import 'package:kepakno_app/screen/dashboard_page.dart';
import 'package:kepakno_app/screen/profile_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

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
                          subtitle: "Rp. 145.000",
                          color: const Color(0xFFFFD98F),
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
                                          builder: (context) =>
                                              const PackagePage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFFFB84D),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      "Lihat Paket",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
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
                      children: const [
                        CategoryCard(
                          icon: Icons.wb_twilight,
                          title: "Sarapan",
                          page: PackagePage(),
                        ),
                        CategoryCard(
                          icon: Icons.wb_sunny,
                          title: "Makan Siang",
                          page: PackagePage(),
                        ),
                        CategoryCard(
                          icon: Icons.nightlight_round,
                          title: "Makan Malam",
                          page: PackagePage(),
                        ),
                        CategoryCard(
                          icon: Icons.cookie,
                          title: "Snack",
                          page: PackagePage(),
                        ),
                      ],
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
                        Text(
                          "Lihat Semua",
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row (
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DayCard(
                              day: "Sen",
                              date: "1",
                              active: selectedDay == 0,
                              onTap: () {
                                setState(() {
                                  selectedDay = 0;
                                });
                              },
                            ),

                            DayCard(
                              day: "Sel",
                              date: "2",
                              active: selectedDay == 1,
                              onTap: () {
                                setState(() {
                                  selectedDay = 1;
                                });
                              },
                            ),

                            DayCard(
                              day: "Rab",
                              date: "3",
                              active: selectedDay == 2,
                              onTap: () {
                                setState(() {
                                  selectedDay = 2;
                                });
                              },
                            ),

                            DayCard(
                              day: "Kam",
                              date: "4",
                              active: selectedDay == 3,
                              onTap: () {
                                setState(() {
                                  selectedDay = 3;
                                });
                              },
                            ),

                            DayCard(
                              day: "Jum",
                              date: "5",
                              active: selectedDay == 4,
                              onTap: () {
                                setState(() {
                                  selectedDay = 4;
                                });
                              },
                            ),

                            DayCard(
                              day: "Sab",
                              date: "6",
                              active: selectedDay == 5,
                              onTap: () {
                                setState(() {
                                  selectedDay = 5;
                                });
                              },
                            ),
                          ],
                        ),

                    const SizedBox(height: 22),

                    const Row(
                      children: [
                        Expanded(
                          child: PackageSmallCard(
                            icon: Icons.stars,
                            title: "Paket Pro",
                            subtitle: "Bisa Custom",
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: PackageSmallCard(
                            icon: Icons.flash_on,
                            title: "Mode Hemat",
                            subtitle: "Mulai Rp. 15rb",
                          ),
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
        decoration: const BoxDecoration(
          color: Color(0xFFFFB84D),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomMenu(icon: Icons.home, title: "Home", active: true),
            BottomMenu(
              icon: Icons.restaurant,
              title: "Paket",
              page: PackagePage(),
            ),
            BottomMenu(
              icon: Icons.badge,
              title: "Dasbor",
              page: DashboardPage(),
            ),
            BottomMenu(
              icon: Icons.person,
              title: "Profile",
              page: ProfilePage(),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoBox({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
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
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
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
                MaterialPageRoute(
                  builder: (context) => page!,
                ),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4B8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
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
  final VoidCallback onTap;

  const DayCard({
    super.key,
    required this.day,
    required this.date,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      child: Container(
        width: 42,
        padding: const EdgeInsets.symmetric(vertical: 6),

        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFFFD98F)
              : const Color(0xFFFFF1D9),

          border: Border.all(
            color: active ? Colors.orange : Colors.black26,
          ),

          borderRadius: BorderRadius.circular(15),
        ),

        child: Column(
          children: [

            Text(
              day,
              style: const TextStyle(fontSize: 10),
            ),

            const SizedBox(height: 2),

            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,

              child: Text(
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
  final IconData icon;
  final String title;
  final String subtitle;

  const PackageSmallCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4B8),
        border: Border.all(color: Colors.black, width: 1.3),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            offset: Offset(1, 2),
            color: Colors.black26,
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundColor: Colors.black,
            child: Icon(
              Icons.restaurant,
              color: Color(0xFFFFE4B8),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page!),
              );
            },
      child: Container(
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF89C66B) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Colors.black),
            Text(title, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}