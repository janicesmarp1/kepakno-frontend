import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart' as api;
import '../services/app_session.dart';
import 'user_home_page.dart';

class CheckoutPage extends StatefulWidget {
  final String name;
  final String email;

  final int menuId;
  final String packageName;
  final int price;
  final String description;
  final String imageUrl;

  const CheckoutPage({
    super.key,
    required this.name,
    required this.email,
    this.menuId = 1,
    this.packageName = "Paket Nasi Kebuli",
    this.price = 20000,
    this.description =
        "- Nasi kebuli\n- Sate\n- Gule\n- Sambal goreng ati kentang\n- Acar",
    this.imageUrl = "",
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool isLoading = false;
  int currentSaldo = 0;
  bool isSaldoLoaded = false;

  int quantity = 1;
  int alamatPengirimanId = 1;

  final catatanController = TextEditingController();

  int get subtotal => widget.price * quantity;
  int get diskon => 0;
  int get totalPembayaran => subtotal - diskon;

  @override
  void initState() {
    super.initState();
    _fetchSaldoSaatIni();
  }

  @override
  void dispose() {
    catatanController.dispose();
    super.dispose();
  }

  Future<void> _fetchSaldoSaatIni() async {
    if (!AppSession.isLoggedIn) return;

    try {
      final response = await http.get(
        Uri.parse(api.ApiConfig.me),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AppSession.authorizationHeader,
        },
      );

      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode == 200 && decoded != null) {
        final data = decoded['data'] ?? decoded['user'] ?? decoded;
        if (data is Map) {
          int saldoDariDb = _readInt(Map<String, dynamic>.from(data), [
            'saldo',
            'balance',
            'wallet',
          ]);
          if (mounted) {
            setState(() {
              currentSaldo = saldoDariDb;
              isSaldoLoaded = true;
            });
          }
        }
      }
    } catch (_) {
      int saldoSesi = _readInt(AppSession.user ?? {}, [
        'saldo',
        'balance',
        'wallet',
      ]);
      if (mounted) {
        setState(() {
          currentSaldo = saldoSesi;
          isSaldoLoaded = true;
        });
      }
    }
  }

  Future<void> _prosesPembayaran() async {
    if (AppSession.accessToken == null || AppSession.accessToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan login terlebih dahulu"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!isSaldoLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tunggu sebentar, sedang mengecek dompetmu..."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (currentSaldo < totalPembayaran) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Maaf, Saldo Aplikasi kamu kurang!",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(api.ApiConfig.pesanan);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AppSession.authorizationHeader,
        },
        body: jsonEncode({
          "alamat_pengiriman_id": alamatPengirimanId,
          "catatan": catatanController.text.trim(),
          "items": [
            {"menu_id": widget.menuId, "jumlah": quantity},
          ],
        }),
      );

      final data = response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data is Map &&
          data['success'] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Pesanan berhasil dibuat dan sedang diproses.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UserHomePage(name: widget.name, email: widget.email),
          ),
          (route) => false,
        );
      } else {
        final message = data is Map
            ? data['message']?.toString()
            : 'Gagal membuat pesanan';

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message ?? 'Gagal membuat pesanan'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak bisa terhubung ke backend: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _tambahJumlah() {
    setState(() {
      quantity++;
    });
  }

  void _kurangiJumlah() {
    if (quantity <= 1) return;

    setState(() {
      quantity--;
    });
  }

  String _formatCurrency(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);

      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return "Rp$buffer";
  }

  int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.round();
      if (value is String) {
        final parsed = int.tryParse(value.replaceAll(RegExp(r'[^0-9-]'), ''));
        if (parsed != null) return parsed;
      }
    }
    return 0;
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
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.arrow_back,
                          color: Color(0xFFFFB84D),
                          size: 18,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.notifications,
                      color: Colors.black,
                      size: 28,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Checkout",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        "Lengkapi detail pesanan anda",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 15),

                      _buildPackageCard(),
                      const SizedBox(height: 15),

                      _buildScheduleCard(),
                      const SizedBox(height: 15),

                      _buildAddressCard(),
                      const SizedBox(height: 15),

                      _buildNoteCard(),
                      const SizedBox(height: 15),

                      _buildPaymentMethodCard(),
                      const SizedBox(height: 15),

                      _buildPaymentDetailCard(),
                      const SizedBox(height: 30),

                      Center(
                        child: InkWell(
                          onTap: isLoading ? null : _prosesPembayaran,
                          child: Container(
                            width: 150,
                            height: 45,
                            decoration: BoxDecoration(
                              color: isLoading
                                  ? Colors.grey.shade200
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFC9F5CF),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3389C66B),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF89C66B),
                                      ),
                                    )
                                  : const Text(
                                      "Bayar",
                                      style: TextStyle(
                                        color: Color(0xFF89C66B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.keyboard_return,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            "Kembali",
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

  Widget _buildPackageCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 75,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4B8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: widget.imageUrl.isEmpty
                      ? Center(
                          child: Text(
                            widget.packageName,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: Colors.brown,
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.fastfood, color: Colors.brown),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Harga paket",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  _formatCurrency(widget.price),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Jumlah",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _kurangiJumlah,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  "$quantity",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _tambahJumlah,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Jadwal\nPengiriman",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Hari ini\nJam 10.30",
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),
            ],
          ),
          const Divider(color: Colors.black12, height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: _smallActionButton("Ganti Jadwal"),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Alamat\npengiriman",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  "Alamat default pengguna",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.black12, height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: _smallActionButton("Ganti Alamat"),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: TextField(
        controller: catatanController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: "Catatan pesanan",
          hintText: "Contoh: jangan terlalu pedas",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Metode Pembayaran",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Saldo Aplikasi",
                  style: TextStyle(fontSize: 10, color: Colors.green),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 18,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Saldo Aplikasi (${isSaldoLoaded ? _formatCurrency(currentSaldo) : 'Memuat...'})",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.check_circle, size: 18, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Rincian Pembayaran",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _paymentRow("Subtotal Pesanan", _formatCurrency(subtotal)),
                const SizedBox(height: 4),
                _paymentRow(
                  "Diskon",
                  "-${_formatCurrency(diskon)}",
                  isDiscount: true,
                ),
                const SizedBox(height: 12),
                _paymentRow(
                  "Total Pembayaran",
                  _formatCurrency(totalPembayaran),
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 12 : 11,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 12 : 11,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? Colors.redAccent : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _smallActionButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.black12),
    );
  }
}
