import 'package:flutter/material.dart';

class AdminNotificationPage extends StatelessWidget {
  const AdminNotificationPage({super.key});

  static const Color _background = Color(0xFFFFF7EF);
  static const Color _green = Color(0xFF2E7D32);
  static const Color _yellow = Color(0xFFF5A623);
  static const Color _muted = Color(0xFF7B7067);
  static const Color _line = Color(0xFFE5E5E5);

  @override
  Widget build(BuildContext context) {
    const notifications = [
      _NotificationData(
        customer: 'Jonathan Ezar',
        packageName: 'Paket Sarapan Sehat',
        invoice: 'INV-15062026-001',
        price: 'Rp150.000',
        time: 'Baru saja',
        unread: true,
      ),
      _NotificationData(
        customer: 'Sinta Purnama',
        packageName: 'Paket Lunch Premium',
        invoice: 'INV-15062026-002',
        price: 'Rp280.000',
        time: '10 menit lalu',
        unread: true,
      ),
      _NotificationData(
        customer: 'Andi Pratama',
        packageName: 'Paket Dinner Hemat',
        invoice: 'INV-15062026-003',
        price: 'Rp210.000',
        time: '35 menit lalu',
      ),
      _NotificationData(
        customer: 'Rina Apriyani',
        packageName: 'Paket Sehat Mingguan',
        invoice: 'INV-14062026-009',
        price: 'Rp150.000',
        time: 'Kemarin',
      ),
    ];

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 20, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Notifikasi',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8C7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      '2 Baru',
                      style: TextStyle(
                        color: _yellow,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _NotificationCard(data: notifications[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationData {
  final String customer;
  final String packageName;
  final String invoice;
  final String price;
  final String time;
  final bool unread;

  const _NotificationData({
    required this.customer,
    required this.packageName,
    required this.invoice,
    required this.price,
    required this.time,
    this.unread = false,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationData data;

  const _NotificationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: data.unread ? AdminNotificationPage._green : AdminNotificationPage._line,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: data.unread
                ? const Color(0xFFE5F6E8)
                : const Color(0xFFFFF1D9),
            child: Icon(
              Icons.receipt_long,
              color: data.unread
                  ? AdminNotificationPage._green
                  : AdminNotificationPage._yellow,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Orderan Masuk',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      data.time,
                      style: const TextStyle(
                        color: AdminNotificationPage._muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${data.customer} memesan ${data.packageName}',
                  style: const TextStyle(fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.invoice,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AdminNotificationPage._muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      data.price,
                      style: const TextStyle(
                        color: AdminNotificationPage._green,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
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
