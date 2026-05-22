import 'package:flutter/material.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

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

                const SizedBox(height: 40),

                const Text(
                  "ADMIN",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "LOG IN",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 120),

                _inputField("Enter your username"),

                const SizedBox(height: 16),

                _inputField(
                  "Enter your password",
                  isPassword: true,
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: ElevatedButton(
                    onPressed: () {},

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC978),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    child: const Text(
                      "LOG IN",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _inputField(
    String hint, {
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(
          color: Colors.grey.shade400,
        ),

        filled: true,
        fillColor: Colors.white.withOpacity(0.7),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}