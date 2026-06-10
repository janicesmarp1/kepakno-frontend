import 'package:flutter/material.dart';
import 'user_home_page.dart';
import 'package_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatelessWidget {
  final String? name;
  final String? email;
  const DashboardPage({super.key, this.name, this.email});

  @override
  Widget build(BuildContext context) {
    // Kita tangani nilainya di sini. Jika kosong, pakai nama default.
    final String displayName = name ?? "User";
    final String displayEmail = email ?? "user@mail.com";

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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Riwayat Pemesanan",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildOrderHistoryCard(
                      title: "Nasi Goreng Komplit",
                      subtitle: "Terkirim, 08 Apr, 12:06",
                      price: "Rp15.000",
                    ),
                    _buildOrderHistoryCard(
                      title: "Nasi Ayam Bali + Es Teh",
                      subtitle: "Terkirim, 12 Mar, 22:28",
                      price: "Rp22.000",
                    ),
                    _buildOrderHistoryCard(
                      title: "Rice Bowl Ayam Teriyaki",
                      subtitle: "Terkirim, 20 Feb, 18:15",
                      price: "Rp25.000",
                    ),
                    const SizedBox(height: 22),
                    _buildMonthlySchedule(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        height: 65,
        color: const Color(0xFFFFB84D),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DashboardBottomMenu(
              icon: Icons.home,
              title: "Home",
              page: UserHomePage(name: displayName, email: displayEmail),
            ),
            DashboardBottomMenu(
              icon: Icons.restaurant,
              title: "Paket",
              page: PackagePage(
                name: displayName,
                email: displayEmail,
                scrollTo: "",
              ),
            ),
            const DashboardBottomMenu(
              icon: Icons.badge,
              title: "Dasbor",
              active: true,
            ),
            DashboardBottomMenu(
              icon: Icons.person,
              title: "Profile",
              page: ProfilePage(name: displayName, email: displayEmail),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistoryCard({
    required String title,
    required String subtitle,
    required String price,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD98F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4B8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_dining,
              size: 28,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 44),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                "Pesan lagi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySchedule() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Jadwal Minggu Ini",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final day = index + 1;
              final active = day == now.day;
              final date = DateTime(now.year, now.month, day);

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD98F),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dayName(date.weekday),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFFE08A1E) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        "$day",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _dayName(int weekday) {
    const days = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];

    return days[weekday - 1];
  }
}

class DashboardBottomMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final Widget? page;

  const DashboardBottomMenu({
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
