import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart' as api;
import '../services/app_session.dart';
import 'user_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(api.ApiConfig.login);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      final data = response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data is Map &&
          data['success'] == true) {
        final loginData = data['data'];

        if (loginData is! Map) {
          throw Exception('Format response login tidak sesuai');
        }

        final user = loginData['user'];

        if (user is! Map) {
          throw Exception('Data user tidak ditemukan');
        }

        final role = (user['role'] ?? '').toString().toLowerCase();

        if (!mounted) return;

        if (role == 'admin') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Akun admin, silakan login melalui menu ADMIN'),
            ),
          );
          return;
        }

        AppSession.saveLoginData(Map<String, dynamic>.from(loginData));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserHomePage(
              name: user['nama_lengkap']?.toString() ?? 'User',
              email: user['email']?.toString() ?? '',
            ),
          ),
        );
      } else {
        if (!mounted) return;

        final message = data is Map
            ? data['message']?.toString()
            : 'Login gagal';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message ?? 'Login gagal'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak bisa terhubung ke backend: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.7),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
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
                  "LOG IN",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 120),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputDecoration("Enter your email"),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: inputDecoration("Enter your password"),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC978),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "LOG IN",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}