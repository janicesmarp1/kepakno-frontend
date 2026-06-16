import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart' as api;
import '../services/app_session.dart';

import 'admin_dashboard_page.dart';
import 'admin_menu_page.dart';
import 'admin_notification_page.dart';
import 'admin_order_page.dart';

class AdminSchedulePage extends StatefulWidget {
  const AdminSchedulePage({super.key});

  static const Color _background = Color(0xFFFFF7EF);
  static const Color _green = Color(0xFF2E7D32);
  static const Color _yellow = Color(0xFFF5A623);
  static const Color _softGreen = Color(0xFFE5F6E8);
  static const Color _softYellow = Color(0xFFFFF1D9);
  static const Color _line = Color(0xFFE5E5E5);
  static const Color _muted = Color(0xFF7B7067);

  @override
  State<AdminSchedulePage> createState() => _AdminSchedulePageState();
}

class _AdminSchedulePageState extends State<AdminSchedulePage> {
  late DateTime _selectedDate;
  late Future<List<_OrderScheduleData>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
    _ordersFuture = _fetchOrders();
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<List<_OrderScheduleData>> _fetchOrders() async {
    if (!AppSession.isLoggedIn) {
      throw Exception('Silakan login admin terlebih dahulu');
    }

    final url = Uri.parse('${api.ApiConfig.adminPesanan}?page=1&limit=100');

    final response = await http.get(
      url,
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

      throw Exception(message ?? 'Gagal memuat jadwal pengiriman');
    }

    final rawOrders = _extractList(decoded);

    return rawOrders
        .whereType<Map>()
        .map((item) => _OrderScheduleData.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((order) => !order.isCancelled)
        .toList();
  }

  void _refreshSchedule() {
    setState(() {
      _ordersFuture = _fetchOrders();
    });
  }

  _DailyScheduleData _scheduleForSelectedDate(List<_OrderScheduleData> orders) {
    final selected = _dateOnly(_selectedDate);

    final selectedOrders = orders.where((order) {
      if (order.date == null) return false;
      return _dateOnly(order.date!).isAtSameMomentAs(selected);
    }).toList();

    final grouped = <String, List<_OrderScheduleData>>{};

    for (final order in selectedOrders) {
      final key = '${order.time}|${order.meal}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(order);
    }

    final groups = grouped.entries.map((entry) {
      final parts = entry.key.split('|');

      return _ScheduleGroupData(
        time: parts.first,
        meal: parts.length > 1 ? parts[1] : 'Jadwal',
        items: entry.value
            .map(
              (order) => _ScheduleItemData(
                name: order.customerName,
                packageName: order.packageName,
                phoneNumber: order.phoneNumber,
              ),
            )
            .toList(),
      );
    }).toList();

    groups.sort((a, b) => a.time.compareTo(b.time));

    return _DailyScheduleData(groups: groups);
  }

  int _mealTotal(_DailyScheduleData schedule, String meal) {
    return schedule.groups
        .where((group) => group.meal == meal)
        .fold(0, (total, group) => total + group.items.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminSchedulePage._background,
      body: SafeArea(
        child: FutureBuilder<List<_OrderScheduleData>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _Header(),
                  ),
                  Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _Header(),
                  ),
                  Expanded(
                    child: _ScheduleErrorState(
                      message: snapshot.error
                          .toString()
                          .replaceFirst('Exception: ', ''),
                      onRetry: _refreshSchedule,
                    ),
                  ),
                ],
              );
            }

            final orders = snapshot.data ?? [];
            final schedule = _scheduleForSelectedDate(orders);

            final breakfastTotal = _mealTotal(schedule, 'Sarapan');
            final lunchTotal = _mealTotal(schedule, 'Makan Siang');
            final dinnerTotal = _mealTotal(schedule, 'Makan Malam');

            return RefreshIndicator(
              onRefresh: () async {
                _refreshSchedule();
                await _ordersFuture;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Header(),
                    const _WelcomeBanner(),
                    const SizedBox(height: 14),
                    _DateSelector(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Ringkasan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.breakfast_dining,
                            value: '$breakfastTotal',
                            title: 'Paket Sarapan',
                            color: AdminSchedulePage._softGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.lunch_dining,
                            iconColor: AdminSchedulePage._yellow,
                            value: '$lunchTotal',
                            title: 'Paket Siang',
                            color: AdminSchedulePage._softYellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _SummaryCard(
                      icon: Icons.dinner_dining,
                      iconColor: AdminSchedulePage._green,
                      value: '$dinnerTotal',
                      title: 'Paket Malam',
                      color: Colors.white,
                    ),
                    const SizedBox(height: 18),
                    if (schedule.groups.isEmpty)
                      const _EmptyScheduleState()
                    else
                      for (final group in schedule.groups) ...[
                        _ScheduleCard(
                          time: group.time,
                          meal: group.meal,
                          total: '${group.items.length} Pengiriman',
                          items: group.items,
                        ),
                        const SizedBox(height: 14),
                      ],
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Jadwal Pengiriman',
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
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DateSelector({
    required this.selectedDate,
    required this.onDateSelected,
  });

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _dayLabel(DateTime date, DateTime today) {
    if (_isSameDay(date, today)) return 'Hari ini';

    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[date.weekday - 1];
  }

  String _dateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final dates = List.generate(6, (index) => today.add(Duration(days: index)));

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
              day: _dayLabel(date, today),
              date: _dateLabel(date),
              active: _isSameDay(date, selectedDate),
              onTap: () {
                onDateSelected(date);
              },
            );
          },
        ),
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  final String day;
  final String date;
  final bool active;
  final VoidCallback onTap;

  const _DateItem({
    required this.day,
    required this.date,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 58,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AdminSchedulePage._softGreen : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? AdminSchedulePage._green
                  : AdminSchedulePage._line,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: day == 'Hari ini' ? 9 : 11,
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
        ),
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

class _DailyScheduleData {
  final List<_ScheduleGroupData> groups;

  const _DailyScheduleData({required this.groups});
}

class _ScheduleGroupData {
  final String time;
  final String meal;
  final List<_ScheduleItemData> items;

  const _ScheduleGroupData({
    required this.time,
    required this.meal,
    required this.items,
  });
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
  final String phoneNumber;

  const _ScheduleItemData({
    required this.name,
    required this.packageName,
    required this.phoneNumber,
  });
}

class _ScheduleItem extends StatelessWidget {
  final _ScheduleItemData item;

  const _ScheduleItem({required this.item});

  void _openCall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AdminCustomerCallPage(customer: item),
      ),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AdminCustomerChatPage(customer: item),
      ),
    );
  }

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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ContactButton(
                icon: Icons.phone_outlined,
                tooltip: 'Telepon customer',
                onTap: () {
                  _openCall(context);
                },
              ),
              const SizedBox(width: 2),
              _ContactButton(
                icon: Icons.message_outlined,
                tooltip: 'Kirim pesan',
                onTap: () {
                  _openChat(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 19, color: AdminSchedulePage._green),
    );
  }
}

class _ScheduleErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ScheduleErrorState({
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
              'Jadwal belum bisa dimuat',
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
                backgroundColor: AdminSchedulePage._green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyScheduleState extends StatelessWidget {
  const _EmptyScheduleState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'Belum ada jadwal pengiriman pada tanggal ini',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AdminSchedulePage._muted,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _AdminCustomerCallPage extends StatefulWidget {
  final _ScheduleItemData customer;

  const _AdminCustomerCallPage({required this.customer});

  @override
  State<_AdminCustomerCallPage> createState() => _AdminCustomerCallPageState();
}

class _AdminCustomerCallPageState extends State<_AdminCustomerCallPage> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _muted = false;
  bool _speakerOn = false;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _durationText {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _openChat() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => _AdminCustomerChatPage(customer: widget.customer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB84D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                ),
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 54,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 56, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Text(
                widget.customer.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Panggilan Kepakno - $_durationText',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Menggunakan koneksi internet',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallActionButton(
                    icon: _muted ? Icons.mic_off : Icons.mic,
                    label: _muted ? 'Unmute' : 'Mute',
                    active: _muted,
                    onTap: () {
                      setState(() {
                        _muted = !_muted;
                      });
                    },
                  ),
                  _CallActionButton(
                    icon: _speakerOn ? Icons.volume_up : Icons.volume_down,
                    label: 'Speaker',
                    active: _speakerOn,
                    onTap: () {
                      setState(() {
                        _speakerOn = !_speakerOn;
                      });
                    },
                  ),
                  _CallActionButton(
                    icon: Icons.message_outlined,
                    label: 'Chat',
                    onTap: _openChat,
                  ),
                ],
              ),
              const SizedBox(height: 34),
              IconButton(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  fixedSize: const Size(68, 68),
                ),
                icon: const Icon(Icons.call_end, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor:
                active ? Colors.white : Colors.white.withValues(alpha: 0.24),
            foregroundColor: active ? Colors.black : Colors.white,
            fixedSize: const Size(58, 58),
          ),
          icon: Icon(icon, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _AdminCustomerChatPage extends StatefulWidget {
  final _ScheduleItemData customer;

  const _AdminCustomerChatPage({required this.customer});

  @override
  State<_AdminCustomerChatPage> createState() => _AdminCustomerChatPageState();
}

class _AdminCustomerChatPageState extends State<_AdminCustomerChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = const [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isAdmin: true));
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminSchedulePage._background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB84D),
        foregroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      _AdminCustomerCallPage(customer: widget.customer),
                ),
              );
            },
            tooltip: 'Telepon customer',
            icon: const Icon(Icons.phone_outlined),
          ),
          const SizedBox(width: 8),
        ],
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    widget.customer.packageName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada pesan',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    itemCount: _messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _ChatBubble(message: _messages[index]);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        filled: true,
                        fillColor: const Color(0xFFFFF7EF),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: AdminSchedulePage._green,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isAdmin;

  const _ChatMessage({required this.text, required this.isAdmin});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final alignment =
        message.isAdmin ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor =
        message.isAdmin ? AdminSchedulePage._green : Colors.white;
    final textColor = message.isAdmin ? Colors.white : Colors.black87;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              message.text,
              style: TextStyle(fontSize: 13, height: 1.35, color: textColor),
            ),
          ),
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
          _AdminBottomMenu(
            icon: Icons.restaurant_menu,
            title: 'Menu',
            onTap: () {
              Navigator.pushReplacement(
                context,
                _noAnimationRoute(const AdminMenuPage()),
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

class _OrderScheduleData {
  final String customerName;
  final String packageName;
  final String phoneNumber;
  final DateTime? date;
  final String meal;
  final String time;
  final String status;

  const _OrderScheduleData({
    required this.customerName,
    required this.packageName,
    required this.phoneNumber,
    required this.date,
    required this.meal,
    required this.time,
    required this.status,
  });

  bool get isCancelled {
    final lower = status.toLowerCase();
    return lower.contains('batal') || lower.contains('cancel');
  }

  factory _OrderScheduleData.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']) ??
        _asMap(json['customer']) ??
        _asMap(json['pelanggan']);

    final items = _extractList(
      json['items'] ??
          json['detail_pesanan'] ??
          json['detailPesanan'] ??
          json['menus'] ??
          json['menu'],
    );

    final firstItem = items.isNotEmpty ? _asMap(items.first) : null;

    final menu = firstItem == null
        ? null
        : _asMap(firstItem['menu']) ??
            _asMap(firstItem['menu_harian']) ??
            _asMap(firstItem['menuHarian']);

    final packageName = _readString(
      json,
      const ['nama_menu', 'nama_paket', 'packageName', 'paket', 'title'],
      fallback: _readString(
        firstItem ?? {},
        const ['nama_menu', 'nama_paket', 'name', 'title'],
        fallback: _readString(
          menu ?? {},
          const ['nama_menu', 'nama_paket', 'name', 'title'],
          fallback: 'Pesanan Catering',
        ),
      ),
    );

    final rawMeal = _readString(
      json,
      const ['jenis_paket', 'kategori', 'kategori_menu', 'meal'],
      fallback: _readString(
        firstItem ?? {},
        const ['jenis_paket', 'kategori', 'kategori_menu', 'meal'],
        fallback: _readString(
          menu ?? {},
          const ['jenis_paket', 'kategori', 'kategori_menu', 'meal'],
          fallback: '',
        ),
      ),
    );

    final meal = _normalizeMeal(rawMeal.isEmpty ? packageName : rawMeal);

    return _OrderScheduleData(
      customerName: _readString(
        user ?? json,
        const ['nama_lengkap', 'name', 'nama', 'customer_name'],
        fallback: 'Customer',
      ),
      packageName: packageName,
      phoneNumber: _readString(
        user ?? json,
        const ['nomor_hp', 'phone', 'phone_number', 'no_hp'],
        fallback: '-',
      ),
      date: _parseDate(
        _readString(
          json,
          const [
            'tanggal_pengiriman',
            'tanggal_pesanan',
            'tanggal_mulai',
            'delivery_date',
            'created_at',
            'createdAt',
          ],
          fallback: '',
        ),
      ),
      meal: meal,
      time: _timeForMeal(meal),
      status: _readString(
        json,
        const ['status_pesanan', 'status', 'state'],
        fallback: '',
      ),
    );
  }
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
    if (data['pesanan'] is List) return data['pesanan'];
    if (data['orders'] is List) return data['orders'];
    if (data['items'] is List) return data['items'];
    if (data['data'] is List) return data['data'];
    if (data['rows'] is List) return data['rows'];
  }

  if (decoded['pesanan'] is List) return decoded['pesanan'];
  if (decoded['orders'] is List) return decoded['orders'];
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

DateTime? _parseDate(String value) {
  if (value.isEmpty || value == '-') return null;
  return DateTime.tryParse(value);
}

String _normalizeMeal(String value) {
  final lower = value.toLowerCase();

  if (lower.contains('sarapan') || lower.contains('breakfast')) {
    return 'Sarapan';
  }

  if (lower.contains('siang') || lower.contains('lunch')) {
    return 'Makan Siang';
  }

  if (lower.contains('malam') || lower.contains('dinner')) {
    return 'Makan Malam';
  }

  if (lower.contains('snack') || lower.contains('cemilan')) {
    return 'Snack';
  }

  return 'Jadwal';
}

String _timeForMeal(String meal) {
  switch (meal) {
    case 'Sarapan':
      return '06.00 - 08.00';
    case 'Makan Siang':
      return '11.00 - 13.00';
    case 'Makan Malam':
      return '17.00 - 19.00';
    case 'Snack':
      return '15.00 - 16.00';
    default:
      return '08.00 - 17.00';
  }
}