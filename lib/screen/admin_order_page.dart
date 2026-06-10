import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import 'admin_schedule_page.dart';

class AdminOrderPage extends StatefulWidget {
  const AdminOrderPage({super.key});

  static const Color _background = Color(0xFFFFF7EF);
  static const Color _activeGreen = Color(0xFF2E7D32);
  static const Color _priceGreen = Color(0xFF178A2F);
  static const Color _buttonGreen = Color(0xFF168A16);
  static const Color _text = Color(0xFF241F1A);
  static const Color _muted = Color(0xFF7B7067);
  static const Color _line = Color(0xFFE5E5E5);

  @override
  State<AdminOrderPage> createState() => _AdminOrderPageState();
}

class _AdminOrderPageState extends State<AdminOrderPage> {
  String _activeFilter = 'Semua';

  final List<_OrderData> _orders = [
    _OrderData(
      invoice: 'INV-15062026-001',
      customer: 'Jonathan Ezar',
      packageName: 'Paket Sehat Mingguan',
      startDate: 'Mulai 15 Juni 2026',
      duration: '7 Hari',
      people: '1 Orang',
      price: 'Rp150.000',
      status: 'Baru',
    ),
    _OrderData(
      invoice: 'INV-15062026-002',
      customer: 'Sinta Purnama',
      packageName: 'Paket Hemat 2 Minggu',
      startDate: 'Mulai 15 Juni 2026',
      duration: '14 Hari',
      people: '1 Orang',
      price: 'Rp280.000',
      status: 'Diproses',
    ),
  ];

  List<_OrderData> get _visibleOrders {
    if (_activeFilter == 'Semua') {
      return _orders;
    }

    return _orders.where((order) => order.status == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleOrders = _visibleOrders;

    return Scaffold(
      backgroundColor: AdminOrderPage._background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const _WelcomeCard(),
              const SizedBox(height: 10),
              _FilterTabs(
                activeFilter: _activeFilter,
                onSelected: (filter) {
                  setState(() {
                    _activeFilter = filter;
                  });
                },
              ),
              const SizedBox(height: 8),
              const _SearchBar(),
              const SizedBox(height: 12),
              if (visibleOrders.isEmpty)
                const _EmptyOrderState()
              else
                ...visibleOrders.expand(
                  (order) => [
                    _OrderCard(
                      invoice: order.invoice,
                      customer: order.customer,
                      packageName: order.packageName,
                      startDate: order.startDate,
                      duration: order.duration,
                      people: order.people,
                      price: order.price,
                      status: order.status,
                      actionLabel: _actionLabel(order.status),
                      statusColor: _statusColor(order.status),
                      statusBackground: _statusBackground(order.status),
                      onAction: () => _handleOrderAction(order),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _AdminBottomNavigation(),
    );
  }

  String _actionLabel(String status) {
    return status == 'Baru' ? 'Konfirmasi' : 'Proses';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Baru':
        return const Color(0xFFF5A623);
      case 'Diproses':
        return const Color(0xFF2E8BE6);
      case 'Dikirim':
        return const Color(0xFFC9A400);
      case 'Selesai':
        return const Color(0xFF2E7D32);
      default:
        return AdminOrderPage._muted;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Baru':
        return const Color(0xFFFFE8C7);
      case 'Diproses':
        return const Color(0xFFE3F1FF);
      case 'Dikirim':
        return const Color(0xFFFFF3BF);
      case 'Selesai':
        return const Color(0xFFE5F6E8);
      default:
        return const Color(0xFFF2F2F2);
    }
  }

  void _handleOrderAction(_OrderData order) {
    if (order.status == 'Baru') {
      setState(() {
        order.status = 'Diproses';
        _activeFilter = 'Diproses';
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pesanan ${order.invoice} sedang diproses')),
    );
  }
}

class _OrderData {
  final String invoice;
  final String customer;
  final String packageName;
  final String startDate;
  final String duration;
  final String people;
  final String price;
  String status;

  _OrderData({
    required this.invoice,
    required this.customer,
    required this.packageName,
    required this.startDate,
    required this.duration,
    required this.people,
    required this.price,
    required this.status,
  });
}

class _EmptyOrderState extends StatelessWidget {
  const _EmptyOrderState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: _cardDecoration(radius: 8),
      child: const Center(
        child: Text(
          'Belum ada pesanan pada status ini',
          style: TextStyle(color: AdminOrderPage._muted, fontSize: 12),
        ),
      ),
    );
  }
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
            'Pesanan',
            style: TextStyle(
              color: AdminOrderPage._text,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              color: Colors.black,
              size: 30,
            ),
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

class _FilterTabs extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onSelected;

  const _FilterTabs({required this.activeFilter, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const filters = ['Semua', 'Diproses', 'Dikirim', 'Selesai'];

    return Row(
      children: filters
          .map(
            (filter) => _FilterTab(
              label: filter,
              active: activeFilter == filter,
              onTap: () => onSelected(filter),
            ),
          )
          .toList(),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? AdminOrderPage._activeGreen : Colors.black54,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                  color: active
                      ? AdminOrderPage._activeGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminOrderPage._line),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, size: 18, color: AdminOrderPage._muted),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Cari nama / nomor pesanan...',
              style: TextStyle(color: AdminOrderPage._muted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String invoice;
  final String customer;
  final String packageName;
  final String startDate;
  final String duration;
  final String people;
  final String price;
  final String status;
  final String actionLabel;
  final Color statusColor;
  final Color statusBackground;
  final VoidCallback onAction;

  const _OrderCard({
    required this.invoice,
    required this.customer,
    required this.packageName,
    required this.startDate,
    required this.duration,
    required this.people,
    required this.price,
    required this.status,
    required this.actionLabel,
    required this.statusColor,
    required this.statusBackground,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(radius: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#$invoice',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminOrderPage._text,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _StatusBadge(
                label: status,
                color: statusColor,
                background: statusBackground,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            customer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            packageName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AdminOrderPage._muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _OrderMeta(icon: Icons.event, text: startDate),
              ),
              const SizedBox(width: 6),
              _OrderMeta(icon: Icons.timelapse, text: duration, width: 44),
              const SizedBox(width: 6),
              _OrderMeta(icon: Icons.person, text: people, width: 50),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminOrderPage._priceGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 62,
                height: 28,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: AdminOrderPage._line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Detail',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 78,
                height: 28,
                child: actionLabel == 'Konfirmasi'
                    ? ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AdminOrderPage._buttonGreen,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          actionLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: onAction,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: AdminOrderPage._line),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          actionLabel,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderMeta extends StatelessWidget {
  final IconData icon;
  final String text;
  final double? width;

  const _OrderMeta({required this.icon, required this.text, this.width});

  @override
  Widget build(BuildContext context) {
    final child = Row(
      children: [
        Icon(icon, size: 12, color: AdminOrderPage._muted),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AdminOrderPage._muted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );

    if (width == null) {
      return child;
    }

    return SizedBox(width: width, child: child);
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
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
          const _AdminBottomMenu(
            icon: Icons.receipt_long,
            title: 'Pesanan',
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

BoxDecoration _cardDecoration({double radius = 8}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 5, offset: Offset(0, 2)),
    ],
  );
}
