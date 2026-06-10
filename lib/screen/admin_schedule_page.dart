import 'package:flutter/material.dart';

import 'admin_dashboard_page.dart';
import 'admin_order_page.dart';

class AdminSchedulePage extends StatelessWidget {
  const AdminSchedulePage({super.key});

  static const Color _background = Color(0xFFFFF7EF);
  static const Color _green = Color(0xFF2E7D32);
  static const Color _yellow = Color(0xFFF5A623);
  static const Color _softGreen = Color(0xFFE5F6E8);
  static const Color _softYellow = Color(0xFFFFF1D9);
  static const Color _line = Color(0xFFE5E5E5);
  static const Color _muted = Color(0xFF7B7067);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _Header(),
              _WelcomeBanner(),
              SizedBox(height: 14),
              _DateSelector(),
              SizedBox(height: 18),
              Text(
                'Ringkasan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.local_shipping,
                      value: '12',
                      title: 'Pengiriman',
                      color: _softGreen,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.groups,
                      iconColor: _yellow,
                      value: '36',
                      title: 'Porsi',
                      color: _softYellow,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18),
              _ScheduleCard(
                time: '06.00 - 08.00',
                meal: 'Sarapan',
                total: '4 Pengiriman',
                items: [
                  _ScheduleItemData(
                    name: 'Jonathan Ezar',
                    packageName: 'Paket Sehat Mingguan',
                  ),
                  _ScheduleItemData(
                    name: 'Budi Santoso',
                    packageName: 'Paket Hemat 2 Minggu',
                  ),
                  _ScheduleItemData(
                    name: 'Rina Apriyani',
                    packageName: 'Paket Sehat Mingguan',
                  ),
                  _ScheduleItemData(
                    name: 'Dewi Lestari',
                    packageName: 'Paket Premium 1 Bulan',
                  ),
                ],
              ),
              SizedBox(height: 14),
              _ScheduleCard(
                time: '11.00 - 13.00',
                meal: 'Makan Siang',
                total: '5 Pengiriman',
                items: [
                  _ScheduleItemData(
                    name: 'Sinta Purnama',
                    packageName: 'Paket Sehat Mingguan',
                  ),
                  _ScheduleItemData(
                    name: 'Andi Pratama',
                    packageName: 'Paket Hemat 2 Minggu',
                  ),
                  _ScheduleItemData(
                    name: 'Rizky Maulana',
                    packageName: 'Paket Premium 1 Bulan',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _AdminBottomNavigation(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Jadwal Pengiriman',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Icon(Icons.notifications, size: 30),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

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

class _DateSelector extends StatelessWidget {
  const _DateSelector();

  @override
  Widget build(BuildContext context) {
    const dates = [
      _DateItemData(day: 'Sab', date: '6 Jun', active: true),
      _DateItemData(day: 'Min', date: '7 Jun'),
      _DateItemData(day: 'Sen', date: '8 Jun'),
      _DateItemData(day: 'Sel', date: '9 Jun'),
      _DateItemData(day: 'Rab', date: '10 Jun'),
      _DateItemData(day: 'Kam', date: '11 Jun'),
    ];

    return Center(
      child: SizedBox(
        height: 58,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final date = dates[index];

            return _DateItem(
              day: date.day,
              date: date.date,
              active: date.active,
            );
          },
        ),
      ),
    );
  }
}

class _DateItemData {
  final String day;
  final String date;
  final bool active;

  const _DateItemData({
    required this.day,
    required this.date,
    this.active = false,
  });
}

class _DateItem extends StatelessWidget {
  final String day;
  final String date;
  final bool active;

  const _DateItem({required this.day, required this.date, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: active ? AdminSchedulePage._softGreen : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? AdminSchedulePage._green : AdminSchedulePage._line,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: active ? AdminSchedulePage._green : Colors.black,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            date,
            style: const TextStyle(
              fontSize: 10,
              color: AdminSchedulePage._muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String title;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.title,
    required this.color,
    this.iconColor = Colors.black,
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
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.transparent,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
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

class _ScheduleCard extends StatelessWidget {
  final String time;
  final String meal;
  final String total;
  final List<_ScheduleItemData> items;

  const _ScheduleCard({
    required this.time,
    required this.meal,
    required this.total,
    required this.items,
  });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                  children: [
                    TextSpan(
                      text: time,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(
                      text: ' ($meal)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Text(
                total,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _ScheduleItem(item: item)),
        ],
      ),
    );
  }
}

class _ScheduleItemData {
  final String name;
  final String packageName;

  const _ScheduleItemData({required this.name, required this.packageName});
}

class _ScheduleItem extends StatelessWidget {
  final _ScheduleItemData item;

  const _ScheduleItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.person, size: 17, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '- ${item.packageName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AdminSchedulePage._muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.phone_outlined,
            size: 19,
            color: AdminSchedulePage._green,
          ),
        ],
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
            icon: Icons.calendar_month,
            title: 'Jadwal',
            active: true,
          ),
        ],
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
