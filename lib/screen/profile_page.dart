import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'package_page.dart';
import 'dashboard_page.dart';
import 'user_home_page.dart';

class ProfilePage extends StatelessWidget {
  final String name;
  final String email;

  const ProfilePage({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ProfileInfoCard(name: name, email: email),
                    const SizedBox(height: 20),

                    Center(
                      child: SizedBox(
                        width: 120,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4B8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: const [
                              Icon(
                                Icons.lock_outline,
                                size: 30,
                                color: Colors.black,
                              ),
                              SizedBox(height: 6),
                              Text(
                                "12",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "Total Pesanan",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Pesanan selesai",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SectionCard(
                      title: "Akun",
                      icon: Icons.person,
                      children: [
                        ProfileMenuItem(
                          icon: Icons.person_outline,
                          title: "Edit Profile",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfilePage(name: name, email: email),
                            ),
                          ),
                        ),
                        ProfileMenuItem(
                          icon: Icons.lock_outline,
                          title: "Ganti Password",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChangePasswordPage(name: name, email: email),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SectionCard(
                            title: "Pengaturan",
                            icon: Icons.settings_outlined,
                            children: const [
                              ProfileMenuItem(
                                icon: Icons.notifications_none,
                                title: "Notifikasi",
                                onTap: null,
                              ),
                              ProfileMenuItem(
                                icon: Icons.language,
                                title: "Bahasa",
                                onTap: null,
                              ),
                              ProfileMenuItem(
                                icon: Icons.dark_mode,
                                title: "Tema",
                                onTap: null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SectionCard(
                            title: "Layanan",
                            icon: Icons.shopping_bag_outlined,
                            children: const [
                              ProfileMenuItem(
                                icon: Icons.receipt_long,
                                title: "Riwayat Pesanan",
                                onTap: null,
                              ),
                              ProfileMenuItem(
                                icon: Icons.location_on_outlined,
                                title: "Alamat",
                                onTap: null,
                              ),
                              ProfileMenuItem(
                                icon: Icons.help_outline,
                                title: "Pusat Bantuan",
                                onTap: null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomePage(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text(
                          "Keluar Akun",
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
      bottomNavigationBar: Container(
        height: 65,
        color: const Color(0xFFFFB84D),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ProfileBottomMenu(
              icon: Icons.home,
              title: "Home",
              page: UserHomePage(name: name, email: email),
            ),
            const ProfileBottomMenu(
              icon: Icons.restaurant,
              title: "Paket",
              page: PackagePage(),
            ),
            const ProfileBottomMenu(
              icon: Icons.badge,
              title: "Dasbor",
              page: DashboardPage(),
            ),
            const ProfileBottomMenu(
              icon: Icons.person,
              title: "Profile",
              active: true,
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  final String name, email;
  const EditProfilePage({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ProfileInfoCard(name: name, email: email),
                    const SizedBox(height: 30),

                    PillInputField(hint: name),
                    const SizedBox(height: 15),
                    const PillInputField(hint: "Enter your new username"),
                    const SizedBox(height: 15),
                    const PillInputField(hint: "Re-enter your new username"),
                    const SizedBox(height: 30),

                    SaveButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profile berhasil diperbarui!"),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 60),
                    const BackRedButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  final String name, email;
  const ChangePasswordPage({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ProfileInfoCard(name: name, email: email),
                    const SizedBox(height: 30),

                    const PillInputField(hint: "XXXXXXXX", isPassword: true),
                    const SizedBox(height: 15),
                    const PillInputField(
                      hint: "Enter your new password",
                      isPassword: true,
                    ),
                    const SizedBox(height: 15),
                    const PillInputField(
                      hint: "Re-enter your new password",
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),

                    SaveButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Password berhasil diubah!"),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 60),
                    const BackRedButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      color: const Color(0xFFFFB84D),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, color: Color(0xFFFFB84D), size: 20),
          ),
          Icon(Icons.notifications, color: Colors.black, size: 28),
        ],
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final String name, email;
  const ProfileInfoCard({super.key, required this.name, required this.email});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4B8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, size: 55, color: Color(0xFFFFE4B8)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
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
                      fontSize: 10,
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
}

class PillInputField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  const PillInputField({
    super.key,
    required this.hint,
    this.isPassword = false,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SaveButton({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC9F5CF)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 3)),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: const Text(
          "SAVE",
          style: TextStyle(
            color: Color(0xFF89C66B),
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class BackRedButton extends StatelessWidget {
  const BackRedButton({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.keyboard_return, color: Colors.redAccent),
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
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4B8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.black54),
          ...children,
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

class ProfileBottomMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final Widget? page;
  const ProfileBottomMenu({
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
          : () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => page!),
            ),
      child: Container(
        width: 55,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE08A1E) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.black),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 9, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
