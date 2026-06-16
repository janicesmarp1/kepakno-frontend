import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_page.dart';

class OpeningPage extends StatefulWidget {
  const OpeningPage({super.key});

  @override
  State<OpeningPage> createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage> {
  bool _showLogo = true;
  bool _showWelcome = false;
  bool _moveWelcomeUp = false;
  bool _showTransitionSplash = false;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _startOpeningSequence();
  }

  void _startOpeningSequence() {
    _timers.add(
      Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _showLogo = false;
          _showWelcome = true;
        });
      }),
    );

    _timers.add(
      Timer(const Duration(milliseconds: 2600), () {
        if (!mounted) return;
        setState(() {
          _moveWelcomeUp = true;
        });
      }),
    );

    _timers.add(
      Timer(const Duration(milliseconds: 3500), () {
        if (!mounted) return;
        setState(() {
          _showTransitionSplash = true;
        });
      }),
    );

    _timers.add(
      Timer(const Duration(milliseconds: 4100), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 650),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const WelcomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );

                  return Container(
                    color: const Color(0xFFFFB84D),
                    child: FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.94,
                          end: 1,
                        ).animate(curved),
                        child: child,
                      ),
                    ),
                  );
                },
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final titleTop = mediaQuery.padding.top + 50;

    return Scaffold(
      backgroundColor: const Color(0xFFFFB84D),
      body: Stack(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 450),
            opacity: _showLogo ? 1 : 0,
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                scale: _showLogo ? 1 : 0.86,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            top: _moveWelcomeUp ? titleTop : screenHeight * 0.45,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOutCubic,
              opacity: _showWelcome ? 1 : 0,
              child: const Text(
                'WELCOME',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOutCubic,
              opacity: _showTransitionSplash ? 1 : 0,
              child: const ColoredBox(
                color: Color(0xFFFFB84D),
                child: SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
