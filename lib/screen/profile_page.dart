import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'package_page.dart';
import 'dashboard_page.dart';
import 'user_home_page.dart';

class ProfilePage extends StatelessWidget {
  final String name;
  final String email;

  const ProfilePage({super.key, required this.name, required this.email});

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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4B8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.black,
                            child: Icon(
                              Icons.person,
                              size: 65,
                              color: Color(0xFFFFE4B8),
                            ),
                          ),

                          const SizedBox(width: 18),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),

                                Text(email),

                                const SizedBox(height: 6),

                                const Chip(
                                  label: Text("#1 Campus Food Solution"),
                                  backgroundColor: Color(0xFFFFF7EF),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: const [
                        Expanded(
                          child: StatCard(
                            icon: Icons.shopping_bag_outlined,
                            value: "12",
                            title: "Total Pesanan",
                            subtitle: "Pesanan selesai",
                          ),
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: StatCard(
                            icon: Icons.stars,
                            value: "Paket Pro",
                            title: "Paket Aktif",
                            subtitle: "Aktif sampai 30 Mei",
                          ),
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: StatCard(
                            icon: Icons.monetization_on,
                            value: "1250",
                            title: "Poin Reward",
                            subtitle: "Tukar sekarang",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SectionCard(
                      title: "Akun",
                      icon: Icons.person,
                      children: const [
                        ProfileMenuItem(
                          icon: Icons.person_outline,
                          title: "Edit Profile",
                        ),

                        ProfileMenuItem(
                          icon: Icons.lock_outline,
                          title: "Ganti Password",
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
                            icon: Icons.settings,
                            children: const [
                              ProfileMenuItem(
                                icon: Icons.notifications_none,
                                title: "Notifikasi",
                              ),

                              ProfileMenuItem(
                                icon: Icons.language,
                                title: "Bahasa",
                              ),

                              ProfileMenuItem(
                                icon: Icons.dark_mode,
                                title: "Tema",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: SectionCard(
                            title: "Layanan",
                            icon: Icons.shopping_bag_outlined,
                            children: const [
                              ProfileMenuItem(
                                icon: Icons.receipt_long,
                                title: "Riwayat Pesanan",
                              ),

                              ProfileMenuItem(
                                icon: Icons.location_on_outlined,
                                title: "Alamat",
                              ),

                              ProfileMenuItem(
                                icon: Icons.help_outline,
                                title: "Pusat Bantuan",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () {
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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
            ProfileBottomMenu(
              icon: Icons.home,
              title: "Home",
              page: UserHomePage(name: name, email: email),
            ),

            const ProfileBottomMenu(
              icon: Icons.restaurant,
              title: "Paket",
              page: PackagePage(),
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
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final String subtitle;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4B8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Colors.black54),
          ),
        ],
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
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon),

              const SizedBox(width: 8),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
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

  const ProfileMenuItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(icon, size: 20),

            const SizedBox(width: 10),

            Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),

            const Icon(Icons.chevron_right, size: 20),
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
