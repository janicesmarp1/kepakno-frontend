import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/app_settings.dart';
import 'screen/opening_page.dart';

void main() {
  runApp(const CateringApp());
}

class CateringApp extends StatelessWidget {
  const CateringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: AppSettings.instance.themeMode,
          locale: AppSettings.instance.locale,
          supportedLocales: const [
            Locale('id'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFB84D),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFB84D),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF15120F),
            useMaterial3: true,
          ),
          home: const OpeningPage(),
        );
      },
    );
  }
}
