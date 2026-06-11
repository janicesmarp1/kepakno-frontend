import 'package:flutter/material.dart';
import 'user_home_page.dart';
import 'package_page.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';

// ==========================================
// VARIABEL GLOBAL & FUNGSI FORMAT RUPIAH
// ==========================================
// Saldo ini bisa diakses dari file mana saja
int globalSaldo = 0;

String formatRupiah(int value) {
  String str = value.toString();
  String result = '';
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    count++;
    result = str[i] + result;
    if (count % 3 == 0 && i != 0) {
      result = '.$result';
    }
  }
  return result;
}

// ==========================================
// 1. HALAMAN MENU UTAMA SALDO
// ==========================================
class SaldoPage extends StatefulWidget {
  final String name;
  final String email;

  const SaldoPage({
    super.key,
    this.name = "Andry Wee",
    this.email = "andrywee@gmail.com",
  });

  @override
  State<SaldoPage> createState() => _SaldoPageState();
}

class _SaldoPageState extends State<SaldoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB84D), Colors.white],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildProfileCard(widget.name, widget.email),
                      const SizedBox(height: 25),

                      // Saldo memanggil variabel global
                      _buildBalanceCard("Rp. ${formatRupiah(globalSaldo)}"),

                      const SizedBox(height: 25),
                      Row(
                        children: [
                          _buildActionMenu(
                            context,
                            Icons.account_balance_wallet,
                            "Isi Saldo",
                            IsiSaldoPage(
                              name: widget.name,
                              email: widget.email,
                            ),
                          ),
                          const SizedBox(width: 15),
                          _buildActionMenu(
                            context,
                            Icons.price_change_outlined,
                            "Tarik\nSaldo",
                            TarikSaldoPage(
                              name: widget.name,
                              email: widget.email,
                            ),
                          ),
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
      bottomNavigationBar: _buildBottomNav(context, widget.name, widget.email),
    );
  }

  Widget _buildActionMenu(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          // Navigasi lalu refresh halaman saat kembali
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          ).then((_) => setState(() {}));
        },
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.black),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN ISI SALDO
// ==========================================
class IsiSaldoPage extends StatefulWidget {
  final String name;
  final String email;
  const IsiSaldoPage({super.key, required this.name, required this.email});

  @override
  State<IsiSaldoPage> createState() => _IsiSaldoPageState();
}

class _IsiSaldoPageState extends State<IsiSaldoPage> {
  final TextEditingController _nominalController = TextEditingController();

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  Widget _buildNominalBtn(String label, String value) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _nominalController.text = value;
            });
          },
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB84D), Colors.white],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildProfileCard(widget.name, widget.email),
                      const SizedBox(height: 20),

                      _buildBalanceCard("Rp. ${formatRupiah(globalSaldo)}"),

                      const SizedBox(height: 20),
                      const Text(
                        "Nominal",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nominalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: "Rp ",
                          prefixStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: "0",
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black45),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black45),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNominalBtn("Rp. 50.000", "50000"),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildNominalBtn("Rp. 100.000", "100000"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNominalBtn("Rp. 150.000", "150000"),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildNominalBtn("Rp. 200.000", "200000"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: 120,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              String rawInput = _nominalController.text
                                  .replaceAll('.', '');
                              int nominal = int.tryParse(rawInput) ?? 0;

                              if (nominal > 0) {
                                // TAMBAH SALDO
                                globalSaldo += nominal;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SuccessPage(
                                      title: "Top-up Berhasil",
                                      name: widget.name,
                                      email: widget.email,
                                      nominal: nominal.toString(),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Masukkan nominal yang valid!",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC9F5CF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Isi",
                              style: TextStyle(
                                color: Color(0xFF89C66B),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildBackButton(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. HALAMAN TARIK SALDO
// ==========================================
class TarikSaldoPage extends StatefulWidget {
  final String name;
  final String email;
  const TarikSaldoPage({super.key, required this.name, required this.email});

  @override
  State<TarikSaldoPage> createState() => _TarikSaldoPageState();
}

class _TarikSaldoPageState extends State<TarikSaldoPage> {
  final TextEditingController _nominalController = TextEditingController();

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  Widget _buildNominalBtn(String label, String value) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _nominalController.text = value;
            });
          },
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB84D), Colors.white],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildProfileCard(widget.name, widget.email),
                      const SizedBox(height: 20),

                      _buildBalanceCard("Rp. ${formatRupiah(globalSaldo)}"),

                      const SizedBox(height: 20),
                      const Text(
                        "Nominal",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nominalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: "Rp ",
                          prefixStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: "0",
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black45),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black45),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNominalBtn("Rp. 50.000", "50000"),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildNominalBtn("Rp. 100.000", "100000"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNominalBtn("Rp. 150.000", "150000"),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildNominalBtn("Rp. 200.000", "200000"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: 120,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              String rawInput = _nominalController.text
                                  .replaceAll('.', '');
                              int nominal = int.tryParse(rawInput) ?? 0;

                              if (nominal > 0) {
                                if (nominal > globalSaldo) {
                                  // Muncul peringatan kalau saldo nggak cukup
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Maaf, saldo kamu tidak cukup!",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                } else {
                                  // KURANGI SALDO
                                  globalSaldo -= nominal;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SuccessPage(
                                        title: "Penarikan Berhasil",
                                        name: widget.name,
                                        email: widget.email,
                                        nominal: nominal.toString(),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Masukkan nominal yang valid!",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC9F5CF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Tarik",
                              style: TextStyle(
                                color: Color(0xFF89C66B),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildBackButton(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. HALAMAN SUKSES TRANSAKSI
// ==========================================
class SuccessPage extends StatelessWidget {
  final String title;
  final String name;
  final String email;
  final String nominal;

  const SuccessPage({
    super.key,
    required this.title,
    required this.name,
    required this.email,
    required this.nominal,
  });

  @override
  Widget build(BuildContext context) {
    int parsedNominal = int.tryParse(nominal) ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB84D), Colors.white],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 90,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "26 Mei 2026 , 12:00 WIB",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 60),

                      const Text(
                        "Penyedia Jasa",
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const Text(
                        "Kepakno Catering",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        "Total Transaksi",
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),

                      // Nampilin nominal yang dinamis dari input form
                      Text(
                        "Rp ${formatRupiah(parsedNominal)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 80),

                      SizedBox(
                        width: 250,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Menuju Home Page dengan saldo terbaru
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserHomePage(name: name, email: email),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(
                            Icons.keyboard_return,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            "Kembali ke Beranda",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET KOMPONEN PENDUKUNG
// ==========================================

Widget _buildHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const CircleAvatar(
            radius: 15,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, color: Color(0xFFFFB84D), size: 20),
          ),
        ),
        const Icon(Icons.notifications, color: Colors.black, size: 28),
      ],
    ),
  );
}

Widget _buildProfileCard(String name, String email) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE4B8),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: Colors.black,
          child: Icon(Icons.person, size: 50, color: Color(0xFFFFE4B8)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "#1 Campus Food Solution",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildBalanceCard(String balance) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_balance_wallet, size: 35, color: Colors.black),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Saldo Anda",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            Text(
              balance,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildBackButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: OutlinedButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.keyboard_return, color: Colors.redAccent),
      label: const Text(
        "Kembali",
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.redAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
        _bottomIcon(
          context,
          Icons.home,
          "Home",
          UserHomePage(name: name, email: email),
        ),
        _bottomIcon(context, Icons.restaurant, "Paket", const PackagePage()),
        _bottomIcon(context, Icons.badge, "Dasbor", const DashboardPage()),
        _bottomIcon(
          context,
          Icons.person,
          "Profile",
          ProfilePage(name: name, email: email),
        ),
      ],
    ),
  );
}

Widget _bottomIcon(
  BuildContext context,
  IconData icon,
  String title,
  Widget page,
) {
  return InkWell(
    onTap: () => Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    ),
    child: Container(
      width: 55,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 9, color: Colors.black)),
        ],
      ),
    ),
  );
}
