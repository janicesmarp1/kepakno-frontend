import 'package:flutter/material.dart';
import 'user_home_page.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';
import 'checkout_page.dart';

class PackagePage extends StatefulWidget {
  final String name;
  final String email;
  final String scrollTo;

  const PackagePage({
    super.key,
    this.name = "User",
    this.email = "user@mail.com",
    this.scrollTo = "",
  });

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  final promoKey = GlobalKey();
  final sarapanKey = GlobalKey();
  final makanSiangKey = GlobalKey();
  final makanMalamKey = GlobalKey();
  final snackKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSection(widget.scrollTo);
    });
  }

  void scrollToSection(String section) {
    GlobalKey? targetKey;

    if (section == "promo") {
      targetKey = promoKey;
    } else if (section == "sarapan") {
      targetKey = sarapanKey;
    } else if (section == "makan_siang") {
      targetKey = makanSiangKey;
    } else if (section == "makan_malam") {
      targetKey = makanMalamKey;
    } else if (section == "snack") {
      targetKey = snackKey;
    }

    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 54,
              color: const Color(0xFFFFB84D),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFFFFB84D),
                      size: 20,
                    ),
                  ),
                  Icon(Icons.notifications, color: Colors.black, size: 28),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Paket Promo", promoKey),
                    const SizedBox(height: 12),
                    _buildPromoBanner(),

                    const SizedBox(height: 25),

                    sectionTitle("Paket Sarapan", sarapanKey),
                    const SizedBox(height: 12),
                    _buildPackageItem(
                      context,
                      title: "Nasi Goreng Pagi",
                      price: "Rp17.000",
                      description:
                          "Nasi goreng dengan telur mata sapi dan ayam suwir. Menu praktis dengan energi cukup untuk aktivitas pagi.",
                      imageUrl:
                          "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?q=80&w=500&auto=format&fit=crop",
                    ),
                    _buildPackageItem(
                      context,
                      title: "Morning Sandwich Set",
                      price: "Rp20.000",
                      description:
                          "Sandwich sehat dengan sayuran segar, telur, dan isian daging pilihan yang pas untuk sarapan ringan.",
                      imageUrl:
                          "https://images.unsplash.com/photo-1481070414801-51fd732d7184?q=80&w=500&auto=format&fit=crop",
                    ),

                    const SizedBox(height: 25),

                    sectionTitle("Paket Makan Siang", makanSiangKey),
                    const SizedBox(height: 12),
                    _buildPackageItem(
                      context,
                      title: "Chicken Katsu Curry",
                      price: "Rp30.000",
                      description:
                          "Daging ayam fillet krispi disiram kuah kari kental yang gurih khas Jepang, disajikan dengan nasi hangat.",
                      imageUrl:
                          "https://images.unsplash.com/photo-1604503468506-a8da13d82791?q=80&w=500&auto=format&fit=crop",
                    ),
                    _buildPackageItem(
                      context,
                      title: "Nasi Ayam Geprek",
                      price: "Rp20.000",
                      description:
                          "Ayam goreng tepung renyah yang digeprek dengan sambal bawang super pedas. Disajikan dengan nasi dan lalapan segar.",
                      imageUrl:
                          "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=500&auto=format&fit=crop",
                    ),

                    const SizedBox(height: 25),

                    sectionTitle("Paket Makan Malam", makanMalamKey),
                    const SizedBox(height: 12),
                    _buildPackageItem(
                      context,
                      title: "Rice Bowl Ayam Teriyaki",
                      price: "Rp25.000",
                      description:
                          "Potongan ayam lembut berbalut saus teriyaki manis gurih dengan taburan wijen di atas nasi hangat.",
                      imageUrl:
                          "https://images.unsplash.com/photo-1574484284002-952d92456975?q=80&w=500&auto=format&fit=crop",
                    ),
                    _buildPackageItem(
                      context,
                      title: "Nasi Rendang",
                      price: "Rp25.000",
                      description:
                          "Daging sapi pilihan yang dimasak lama dengan rempah-rempah tradisional kaya rasa dan santan kental.",
                      imageUrl:
                          "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?q=80&w=500&auto=format&fit=crop",
                    ),

                    const SizedBox(height: 25),

                    sectionTitle("Snack", snackKey),
                    const SizedBox(height: 12),
                    _buildPackageItem(
                      context,
                      title: "Lumpia Goreng Spesial",
                      price: "Rp25.000",
                      description:
                          "Lumpia renyah dengan isian rebung, ayam, atau sayuran gurih. Cocok untuk menemani waktu santai kuliah.",
                      imageUrl:
                          "https://images.unsplash.com/photo-1596797038530-2c107229654b?q=80&w=500&auto=format&fit=crop",
                    ),
                    _buildPackageItem(
                      context,
                      title: "Risoles Mayo Premium",
                      price: "Rp25.000",
                      description:
                          "Risoles dengan kulit lembut dan isian smoked beef, telur rebus, serta lelehan mayonnaise premium yang lumer.",
                      imageUrl:
                          "https://images.unsplash.com/photo-1605333398744-8d9e60ea9b00?q=80&w=500&auto=format&fit=crop",
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 65,
        color: const Color(0xFFFFB84D),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PackageBottomMenu(
              icon: Icons.home,
              title: "Home",
              page: UserHomePage(name: widget.name, email: widget.email),
            ),
            const PackageBottomMenu(
              icon: Icons.restaurant,
              title: "Paket",
              active: true,
            ),
            const PackageBottomMenu(
              icon: Icons.badge,
              title: "Dasbor",
              page: DashboardPage(),
            ),
            PackageBottomMenu(
              icon: Icons.person,
              title: "Profile",
              page: ProfilePage(name: widget.name, email: widget.email),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title, GlobalKey key) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  "https://images.unsplash.com/photo-1565557613262-b91c13d7890f?q=80&w=500&auto=format&fit=crop",
                  fit: BoxFit.cover,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImagePlaceholder(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PROMO DISKON 20%",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const Text(
                    "Paket Nasi Kebuli",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "- Nasi Kebuli + Sate\n- Gule + Sambal Goreng\n- Acar + Pisang",
                    style: TextStyle(fontSize: 11, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            name: widget.name,
                            email: widget.email,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFBF5E),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      "Pesan Sekarang",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageItem(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      price,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    "TOP",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            name: widget.name,
                            email: widget.email,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFFBF5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      "Pesan Sekarang",
                      style: TextStyle(
                        fontFamily: "Georgia",
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 50),
    );
  }
}

class PackageBottomMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final Widget? page;

  const PackageBottomMenu({
    super.key,
    required this.icon,
    required this.title,
    this.active = false,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: page == null
          ? null
          : () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => page!),
              );
            },
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE08A1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: Colors.black),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
