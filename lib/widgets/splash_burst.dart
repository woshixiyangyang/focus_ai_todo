// lib/widgets/splash_burst.dart
import 'dart:math';
import 'package:flutter/material.dart';

/// 水花碎裂散开动画组件
class SplashBurst extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;
  final int particleCount;
  final Duration duration;

  const SplashBurst({
    super.key,
    required this.position,
    required this.onComplete,
    this.particleCount = 22,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<SplashBurst> createState() => _SplashBurstState();
}

class _SplashBurstState extends State<SplashBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();

    // 创建动画控制器
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // 生成粒子
    _particles = _generateParticles();

    // 开始动画
    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  List<Particle> _generateParticles() {
    final random = Random();
    final particles = <Particle>[];

    for (int i = 0; i < widget.particleCount; i++) {
      // 随机角度（360度均匀分布）
      final angle =
          (2 * pi * i) / widget.particleCount + random.nextDouble() * 0.5;

      // 随机速度（距离）
      final speed = 60 + random.nextDouble() * 80;

      // 计算x和y方向的速度
      final vx = cos(angle) * speed;
      final vy = sin(angle) * speed + random.nextDouble() * 30; // y方向多一点模拟重力

      // 随机大小
      final size = 3 + random.nextDouble() * 6;

      // 浅蓝/白色系
      final colors = [
        Colors.lightBlue.shade200,
        Colors.lightBlue.shade300,
        Colors.cyan.shade200,
        Colors.white.withOpacity(0.9),
        Colors.blue.shade100,
      ];
      final color = colors[random.nextInt(colors.length)];

      particles.add(Particle(vx: vx, vy: vy, size: size, color: color));
    }

    return particles;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SplashPainter(
            particles: _particles,
            progress: _controller.value,
            origin: widget.position,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// 粒子数据类
class Particle {
  final double vx; // x方向速度
  final double vy; // y方向速度
  final double size;
  final Color color;

  Particle({
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
  });
}

/// 自定义绘制器
class SplashPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Offset origin;

  SplashPainter({
    required this.particles,
    required this.progress,
    required this.origin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // 计算当前位置（加入轻微的重力效果）
      final x = origin.dx + particle.vx * progress;
      final y =
          origin.dy +
          particle.vy * progress +
          50 * progress * progress; // 重力加速度

      // 计算透明度（渐隐效果）
      final opacity = 1.0 - progress;

      // 绘制粒子
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1 - progress * 0.5), // 尺寸稍微缩小
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SplashPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
