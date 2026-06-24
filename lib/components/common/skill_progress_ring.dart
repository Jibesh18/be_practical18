import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SkillProgressRing extends StatefulWidget {
  final int currentXp;
  final int maxXp;
  final double size;
  final Color color;

  const SkillProgressRing({
    Key? key,
    required this.currentXp,
    required this.maxXp,
    this.size = 60,
    this.color = AppColors.primary,
  }) : super(key: key);

  @override
  State<SkillProgressRing> createState() => _SkillProgressRingState();
}

class _SkillProgressRingState extends State<SkillProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    final progress = widget.currentXp / widget.maxXp;
    _animation = Tween<double>(begin: 0, end: progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ProgressRingPainter(
            progress: _animation.value,
            color: widget.color,
          ),
          size: Size(widget.size, widget.size),
          child: Center(
            child: Text(
              '${(_animation.value * 100).toInt()}%',
              style: TextStyle(
                fontSize: widget.size * 0.3,
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
