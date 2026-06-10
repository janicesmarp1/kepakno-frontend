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
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> slides = [
    {
      "image": "assets/images/image 1.png",
      "text": "Set your location to do the\ncatering services",
    },
    {"image": "combo", "text": "Choose and order your favorite\nmeals easily"},
    {
      "image": "assets/images/image 2.png",
      "text": "Complete your payment and your\norder will be delivered on time",
    },
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 3200), (timer) {
      final nextPage = (_currentPage + 1) % slides.length;

      setState(() {
        _currentPage = nextPage;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  Route<T> splashRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 650),
      reverseTransitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return Container(
          color: const Color(0xFFFFB84D),
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }

  void goToLogin() {
    Navigator.push(context, splashRoute(const LoginPage()));
  }

  void goToSignUp() {
    Navigator.push(context, splashRoute(const SignUpPage()));
  }

  void goToAdminLogin() {
    Navigator.push(context, splashRoute(const AdminLoginPage()));
  }

  Widget slideImage(String image) {
    if (image == "combo") {
      return SizedBox(
        width: 250,
        height: 180,
        child: Stack(
          children: [
            Positioned(
              left: 8,
              top: 0,
              child: Image.asset(
                "assets/images/image 3.png",
                width: 145,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              right: 8,
              bottom: 0,
              child: Image.asset(
                "assets/images/image 4.png",
                width: 145,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      );
    }

    return Image.asset(image, width: 250, height: 180, fit: BoxFit.contain);
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
            colors: [Color(0xFFFFBF5E), Color(0xFFFFE2B8), Color(0xFFFFF7EF)],
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
                  height: 320,
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 700),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.86,
                                end: 1,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(slides[_currentPage]["image"]!),
                          child: slideImage(slides[_currentPage]["image"]!),
                        ),
                      ),
                      const SizedBox(height: 45),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 550),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.96,
                                end: 1,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          slides[_currentPage]["text"]!,
                          key: ValueKey(slides[_currentPage]["text"]!),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(slides.length, (i) => indicator(i)),
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
                        letterSpacing: 0.8,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0x33000000),
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
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
                        letterSpacing: 0.8,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0x33000000),
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                TextButton(
                  onPressed: goToAdminLogin,
                  child: const Text(
                    "ADMIN",
                    style: TextStyle(color: Color(0xFFFFA726), fontSize: 16),
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
