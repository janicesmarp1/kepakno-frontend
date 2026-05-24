import 'package:flutter/material.dart';

class PackagePage extends StatelessWidget {
  const PackagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB84D),
        title: const Text(
          "Paket Makanan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PackageCard(
            title: "Paket Sarapan",
            price: "Mulai Rp. 15.000",
            icon: Icons.wb_twilight,
          ),
          PackageCard(
            title: "Paket Makan Siang",
            price: "Mulai Rp. 20.000",
            icon: Icons.wb_sunny,
          ),
          PackageCard(
            title: "Paket Makan Malam",
            price: "Mulai Rp. 22.000",
            icon: Icons.nightlight_round,
          ),
          PackageCard(
            title: "Paket Snack",
            price: "Mulai Rp. 10.000",
            icon: Icons.cookie,
          ),
        ],
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  final String title;
  final String price;
  final IconData icon;

  const PackageCard({
    super.key,
    required this.title,
    required this.price,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4B8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.black,
            child: Icon(icon, color: Color(0xFFFFB84D), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(price),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB84D),
            ),
            child: const Text(
              "Lihat",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}