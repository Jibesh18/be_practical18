import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/splash_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;
  late final AnimationController _shimmerController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _pulse;
  late final Animation<double> _dotsOpacity;
  late final Animation<double> _shimmer;

  // Electric blue palette
  static const Color _bg         = Color(0xFF080810);
  static const Color _bgMid      = Color(0xFF0D0D1A);
  static const Color _bgBottom   = Color(0xFF0A0A14);
  static const Color _electric   = Color(0xFF1E90FF);
  static const Color _electricBright = Color(0xFF60B8FF);
  static const Color _electricDim    = Color(0xFF0A4A8A);
  static const Color _white      = Color(0xFFFFFFFF);
  static const Color _whiteDim   = Color(0xFFB0C4DE);

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.45, 0.75, curve: Curves.easeOut)),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.45, 0.75, curve: Curves.easeOut)),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.65, 1.0, curve: Curves.easeOut)),
    );

    _pulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dotsController, curve: Curves.easeIn),
    );

    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/logobp.png'), context);
  }

  Future<void> _start() async {
    await context.read<SplashViewModel>().initialize();
    if (!mounted) return;

    _mainController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    _dotsController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.authGate);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_bg, _bgMid, _bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Electric glow — top right
            Positioned(
              top: -140,
              right: -100,
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 420,
                      height: 420,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _electric.withOpacity(0.18),
                            _electric.withOpacity(0.04),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Electric glow — bottom left
            Positioned(
              bottom: -120,
              left: -90,
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Transform.scale(
                    scale: 1.3 - (_pulse.value - 0.85) * 0.4,
                    child: Container(
                      width: 340,
                      height: 340,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _electricDim.withOpacity(0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Horizontal scan line — pure tech detail
            Positioned(
              top: screenHeight * 0.38,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineOpacity,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _electric.withOpacity(0.25),
                        _electricBright.withOpacity(0.5),
                        _electric.withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.06),

                  // Logo — dark card, electric blue border glow
                  RepaintBoundary(
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(42),
                            border: Border.all(
                              color: _electric.withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _electric.withOpacity(0.5),
                                blurRadius: 60,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: _electricBright.withOpacity(0.25),
                                blurRadius: 25,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(0.5),
                          child: Image.asset(
                            'assets/images/logobp.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // App name — electric shimmer
                  RepaintBoundary(
                    child: SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: AnimatedBuilder(
                          animation: _shimmer,
                          builder: (_, __) => ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: const [
                                _whiteDim,
                                _white,
                                _electricBright,
                                _white,
                                _whiteDim,
                              ],
                              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                              begin: Alignment(_shimmer.value - 1, 0),
                              end: Alignment(_shimmer.value, 0),
                            ).createShader(bounds),
                            child: Text(
                              'Be Practical',
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.018),

                  // Pills — electric blue tones
                  RepaintBoundary(
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _TagPill(
                            label: 'Learn',
                            bgColor: Color(0xFF061428),
                            textColor: Color(0xFF60B8FF),
                            borderColor: Color(0xFF1255A0),
                          ),
                          SizedBox(width: 10),
                          _TagPill(
                            label: 'Apply',
                            bgColor: Color(0xFF040E20),
                            textColor: Color(0xFF90CEFF),
                            borderColor: Color(0xFF1E90FF),
                          ),
                          SizedBox(width: 10),
                          _TagPill(
                            label: 'Grow',
                            bgColor: Color(0xFF060F22),
                            textColor: Color(0xFFB8DBFF),
                            borderColor: Color(0xFF0A3D7A),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.06),

                  // Loading dots — electric blue
                  RepaintBoundary(
                    child: FadeTransition(
                      opacity: _dotsOpacity,
                      child: const _LoadingDots(),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;

  const _TagPill({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.7), width: 1.2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) =>
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
    );
    _animations = _controllers.map((c) =>
        Tween<double>(begin: 0.15, end: 1.0).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut))
    ).toList();
    _startDots();
  }

  Future<void> _startDots() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) _controllers[i].repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) =>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: FadeTransition(
              opacity: _animations[i],
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E90FF),
                ),
              ),
            ),
          ),
      ),
    );
  }
}