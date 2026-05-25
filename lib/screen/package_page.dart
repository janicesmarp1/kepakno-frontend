import 'package:flutter/material.dart';

class PackagePage extends StatefulWidget {
  const PackagePage({super.key});

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF), // Warna krem sesuai homepage temanmu

      // 1. TOP BAR / APP BAR (Sama seperti desain yang kamu kirim)
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB03A), // Warna oranye katering
        elevation: 0,
        leading: const Icon(Icons.account_circle, size: 32, color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 28, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),

      // 2. AREA ISI KONTEN MENU
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teks judul section pertama
                const Text(
                  "Paket Promo",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // TODO: Bagian kartu Nasi Kebuli & Nasi Goreng akan kita selipkan di sini
                const Text("Kartu-kartu makanan akan kita tambahkan di bawah teks ini..."),
              ],
            ),
          ),
        ),
      ),

      // 3. BOTTOM NAVIGATION BAR (Disamakan dengan model homepage temanmu)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Di halaman Paket, indeks yang aktif adalah nomor 1
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Menjaga posisi ikon tetap stabil
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Paket",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Dasbor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}