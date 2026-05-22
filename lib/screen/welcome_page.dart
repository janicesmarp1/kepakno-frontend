import 'dart:async';
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'signup_page.dart';
import 'admin_login.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> slides = [
    {
      "image": "assets/images/food1.png",
      "text": "Set your location to do the\ncatering services",
    },
    {
      "image": "assets/images/food2.png",
      "text": "Choose and order your favorite\nmeals easily",
    },
    {
      "image": "assets/images/delivery.png",
      "text": "Complete your payment and your\norder will be delivered on time",
    },
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final nextPage = (_currentPage + 1) % slides.length;

      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget indicator(int index) {
    final active = index == _currentPage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 34,
      height: 9,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF75C94C) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  void goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      ),
    );
  }

  void goToAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminLoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Color(0xFFFFBF5E),
              Color(0xFFFFE2B8),
              Color(0xFFFFF7EF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 50),

                const Text(
                  "WELCOME",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 70),

                SizedBox(
                  height: 330,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: slides.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Image.asset(
                            slides[index]["image"]!,
                            width: 220,
                            height: 170,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 45),

                          Text(
                            slides[index]["text"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              slides.length,
                              (i) => indicator(i),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: goToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC978),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: goToSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC978),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "SIGN UP",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                TextButton(
                  onPressed: goToAdminLogin,
                  child: const Text(
                    "ADMIN",
                    style: TextStyle(
                      color: Color(0xFFFFA726),
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}