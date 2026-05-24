import 'package:flutter/material.dart';
import 'screen/opening_page.dart';

void main() {
  runApp(const CateringApp());
}

class CateringApp extends StatelessWidget {
  const CateringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OpeningPage(),
    );
  }
}