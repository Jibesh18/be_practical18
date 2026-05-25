import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/splash_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _logoReveal;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();


    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );


    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 150));
    await _textController.forward();

    await Future.delayed(const Duration(milliseconds: 450));

    if (mounted) {
      context.read<SplashViewModel>().initialize(context);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;


    final textScaler = mediaQuery.textScaler;


    final logoSize = screenWidth * 0.90;
    final progressWidth = screenWidth * 0.70;


    final titleFontSize = textScaler.scale((screenWidth * 0.15).clamp(38.0, 50.0));
    final taglineFontSize = textScaler.scale((screenWidth * 0.045).clamp(15.0, 19.0));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(), // Keeps layout locked & stable
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        heightFactor: _logoReveal.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Image(
                  image: const AssetImage('assets/images/logobp.png'),
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: screenWidth * 0.07), // Scalable gap

              /// APP NAME
              FadeTransition(
                opacity: _textOpacity,
                child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Be ",
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      TextSpan(
                        text: "Practical",
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0A66C2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: screenWidth * 0.03),

              /// TAGLINE
              FadeTransition(
                opacity: _taglineOpacity,
                child: Text(
                  "LEARN • APPLY • GROW",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: taglineFontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: const Color(0xFF374151),
                    height: 1.5, // Essential line-height to prevent letter clipping
                  ),
                ),
              ),

              SizedBox(height: screenWidth * 0.12),

              /// PROGRESS BAR
              SizedBox(
                width: progressWidth,
                child: const LinearProgressIndicator(
                  backgroundColor: Color(0xFFE5E7EB),
                  color: Color(0xFF0A66C2),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}