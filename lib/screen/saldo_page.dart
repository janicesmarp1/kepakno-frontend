import 'package:flutter/material.dart';
import 'user_home_page.dart';
import 'package_page.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';

// --- 1. HALAMAN UTAMA SALDO ---
class SaldoPage extends StatelessWidget {
  final String name;
  final String email;

  const SaldoPage({
    super.key,
    this.name = "Andry Wee",
    this.email = "andrywee@gmail.com",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB84D), Colors.white],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildProfileCard(name, email),
                      const SizedBox(height: 25),
                      _buildBalanceCard("Rp. 145.000"),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          _buildActionMenu(context, Icons.account_balance_wallet, "Isi Saldo", IsiSaldoPage(name: name, email: email)),
                          const SizedBox(width: 15),
                          _buildActionMenu(context, Icons.shopping_bag, "Tarik\nSaldo", TarikSaldoPage(name: name, email: email)),
                        ],
                      ),
                      const SizedBox(height: 50),
                      _buildBackButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, name, email),
    );
  }

  // Widget Helper biar kode ga kepanjangan
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          CircleAvatar(radius: 14, backgroundColor: Colors.black, child: Icon(Icons.person, color: Color(0xFFFFB84D), size: 18)),
          Icon(Icons.notifications, color: Colors.black, size: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFFFE4B8), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const CircleAvatar(radius: 28, backgroundColor: Colors.black, child: Icon(Icons.person, color: Color(0xFFFFE4B8), size: 40)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(email, style: const TextStyle(fontSize: 10)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(border: Border.all(color: Colors.black54), borderRadius: BorderRadius.circular(10)),
                child: const Text("#1 Campus Food Solution", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String balance) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet, size: 28),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Saldo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(balance, style: const TextStyle(fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, IconData icon, String title, Widget page) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        child: Container(
          height: 90,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.exit_to_app, color: Colors.redAccent, size: 20),
        label: const Text("Kembali", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}

// --- 2. HALAMAN INPUT ISI SALDO ---
class IsiSaldoPage extends StatelessWidget {
  final String name;
  final String email;
  const IsiSaldoPage({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFB84D), Colors.white], stops: [0.0, 0.6])),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeaderManual(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildMiniProfile(name, email),
                      const SizedBox(height: 20),
                      const Text("Nominal", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(decoration: InputDecoration(hintText: "Rp", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: ["Rp. 50.000", "Rp. 100.000", "Rp. 150.000", "Rp. 200.000"].map((val) => _buildNominalBtn(val)).toList(),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage(title: "Top-up Berhasil", name: name))),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text("Deposit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSimpleBack(context),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- 3. HALAMAN INPUT TARIK SALDO ---
class TarikSaldoPage extends StatelessWidget {
  final String name;
  final String email;
  const TarikSaldoPage({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFB84D), Colors.white], stops: [0.0, 0.6])),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeaderManual(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildMiniProfile(name, email),
                      const SizedBox(height: 20),
                      const Text("Nominal", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(decoration: InputDecoration(hintText: "Rp", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: ["Rp. 50.000", "Rp. 100.000", "Rp. 150.000", "Rp. 200.000"].map((val) => _buildNominalBtn(val)).toList(),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage(title: "Penarikan Berhasil", name: name))),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text("Tarik", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSimpleBack(context),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- 4. HALAMAN SUKSES (BERHASIL) ---
class SuccessPage extends StatelessWidget {
  final String title;
  final String name;
  const SuccessPage({super.key, required this.title, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFB84D), Colors.white], stops: [0.0, 0.6])),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeaderManual(context),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 100, color: Colors.black),
                    const SizedBox(height: 20),
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text("25 Mei 2026 , 12:00 WIB", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 40),
                    const Text("kepakno.com", style: TextStyle(fontSize: 10, color: Colors.black45)),
                    Text("Kepakno Catering", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(name),
                    const SizedBox(height: 30),
                    const Text("Total Transaksi", style: TextStyle(fontSize: 10, color: Colors.black45)),
                    const Text("Rp 100.000", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 60),
                    TextButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: const Text("Kembali ke Beranda", style: TextStyle(color: Colors.black, decoration: TextDecoration.underline)))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET KOMPONEN TAMBAHAN ---

Widget _buildHeaderManual(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(onTap: () => Navigator.pop(context), child: const CircleAvatar(radius: 14, backgroundColor: Colors.black, child: Icon(Icons.person, color: Color(0xFFFFB84D), size: 18))),
        const Icon(Icons.notifications, color: Colors.black, size: 24),
      ],
    ),
  );
}

Widget _buildMiniProfile(String name, String email) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFFFE4B8), borderRadius: BorderRadius.circular(15)),
    child: Row(
      children: [
        const CircleAvatar(radius: 20, backgroundColor: Colors.black, child: Icon(Icons.person, color: Color(0xFFFFE4B8))),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(email, style: const TextStyle(fontSize: 9))]),
      ],
    ),
  );
}

Widget _buildNominalBtn(String label) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  );
}

Widget _buildSimpleBack(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.exit_to_app, color: Colors.redAccent, size: 18),
      label: const Text("Kembali", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
      style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Colors.redAccent)),
    ),
  );
}

Widget _buildBottomNav(BuildContext context, String name, String email) {
  return Container(
    height: 65,
    color: const Color(0xFFFFB84D),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _bottomIcon(context, Icons.home, "Home", UserHomePage(name: name, email: email)),
        _bottomIcon(context, Icons.restaurant, "Paket", const PackagePage()),
        _bottomIcon(context, Icons.badge, "Dasbor", const DashboardPage()),
        _bottomIcon(context, Icons.person, "Profile", ProfilePage(name: name, email: email)),
      ],
    ),
  );
}

Widget _bottomIcon(BuildContext context, IconData icon, String title, Widget page) {
  return InkWell(
    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 24), Text(title, style: const TextStyle(fontSize: 10))]),
  );
}
