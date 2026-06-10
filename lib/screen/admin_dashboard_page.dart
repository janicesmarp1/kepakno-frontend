import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'admin_order_page.dart';
import 'admin_schedule_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
                children: const [
                  Text(
                    "Dashboard",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  Icon(Icons.notifications, size: 30),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
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

                    const Row(
                      children: [
                        Expanded(
                          child: DashboardStatCard(
                            icon: Icons.shopping_cart,
                            value: "20",
                            title: "Pesanan Hari Ini",
                            color: Color(0xFFE6D9FF),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: DashboardStatCard(
                            icon: Icons.shopping_cart,
                            value: "486",
                            title: "Pesanan Bulan Ini",
                            color: Color(0xFFD9F4FF),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Row(
                      children: [
                        Expanded(
                          child: DashboardStatCard(
                            icon: Icons.wallet,
                            value: "Rp.500.000",
                            title: "Pendapatan Hari Ini",
                            color: Color(0xFFDFF5DF),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: DashboardStatCard(
                            icon: Icons.wallet,
                            value: "Rp.12.150.000",
                            title: "Pendapatan Bulan Ini",
                            color: Color(0xFFFFE4C7),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Container(
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
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
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
                                child: const Text(
                                  "30 Hari",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          const SizedBox(
                            height: 178,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ChartValueLabels(),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: CustomPaint(
                                          painter: RevenueChartPainter(),
                                          child: SizedBox.expand(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.only(left: 38),
                                  child: ChartDateLabels(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Menu Terlaris",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              Text("30 Hari", style: TextStyle(fontSize: 11)),
                            ],
                          ),
                          SizedBox(height: 14),
                          BestMenuItem(
                            number: "1.",
                            name: "Rice Bowl Ayam Teriyaki",
                            portion: "126 Porsi",
                          ),
                          BestMenuItem(
                            number: "2.",
                            name: "Chicken Katsu Curry",
                            portion: "98 Porsi",
                          ),
                          BestMenuItem(
                            number: "3.",
                            name: "Nasi Goreng Pagi",
                            portion: "72 Porsi",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
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
                            borderRadius: BorderRadius.circular(10),
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

class ChartValueLabels extends StatelessWidget {
  const ChartValueLabels({super.key});

  @override
  Widget build(BuildContext context) {
    const labels = ["15 jt", "10 jt", "5 jt", "0"];

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

class ChartDateLabels extends StatelessWidget {
  const ChartDateLabels({super.key});

  @override
  Widget build(BuildContext context) {
    const dates = [
      "1 Jun",
      "4 Jun",
      "7 Jun",
      "10 Jun",
      "13 Jun",
      "16 Jun",
      "19 Jun",
      "22 Jun",
      "25 Jun",
      "30 Jun",
    ];

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

class RevenueChartPainter extends CustomPainter {
  const RevenueChartPainter();

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

    final points = [
      Offset(0, size.height * 0.75),
      Offset(size.width * 0.12, size.height * 0.55),
      Offset(size.width * 0.22, size.height * 0.72),
      Offset(size.width * 0.34, size.height * 0.35),
      Offset(size.width * 0.45, size.height * 0.48),
      Offset(size.width * 0.56, size.height * 0.63),
      Offset(size.width * 0.68, size.height * 0.28),
      Offset(size.width * 0.78, size.height * 0.50),
      Offset(size.width * 0.88, size.height * 0.47),
      Offset(size.width, size.height * 0.58),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, linePaint);

    for (final point in points) {
      canvas.drawCircle(point, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
