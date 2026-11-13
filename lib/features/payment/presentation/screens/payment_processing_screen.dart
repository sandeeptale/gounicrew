import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../../data/models/payment_model.dart';
import '../../../../core/utils/formatters.dart';
import 'payment_result_screen.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final String orderId;
  final String transactionId;
  final double amount;
  final String paymentMethodName;

  const PaymentProcessingScreen({
    super.key,
    required this.orderId,
    required this.transactionId,
    required this.amount,
    required this.paymentMethodName,
  });

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _progressController;
  late final AnimationController _pulseController;

  late final Animation<double> _ring1;
  late final Animation<double> _ring2;
  late final Animation<double> _ring3;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: false);

    _ring1 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
    ]).animate(_pulseController);

    _ring2 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
    ]).animate(_pulseController);

    _ring3 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 60),
    ]).animate(_pulseController);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToResult(BuildContext context, String result, PaymentModel payment) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentResultScreen(
          result: result,
          payment: payment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          _navigateToResult(context, 'success', state.payment);
        } else if (state is PaymentFailure) {
          _navigateToResult(context, 'failure', state.payment);
        } else if (state is PaymentPending) {
          _navigateToResult(context, 'pending', state.payment);
        } else if (state is PaymentCancelled) {
          _navigateToResult(context, 'cancelled', state.payment);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E3A5F),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  _buildAnimatedRings(),
                  const SizedBox(height: 48),
                  const Text(
                    'Processing Payment...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatCurrency(widget.amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Order #${widget.orderId}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Txn: ${widget.transactionId}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildProgressBar(),
                  const SizedBox(height: 8),
                  Text(
                    'via ${widget.paymentMethodName}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(flex: 2),
                  _buildSecurityBadge(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedRings() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outermost ring (ring 3)
          AnimatedBuilder(
            animation: _ring3,
            builder: (_, __) => Opacity(
              opacity: (1.0 - _ring3.value).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.6 + (_ring3.value * 0.4),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Middle ring (ring 2)
          AnimatedBuilder(
            animation: _ring2,
            builder: (_, __) => Opacity(
              opacity: (1.0 - _ring2.value).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.65 + (_ring2.value * 0.35),
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Inner ring (ring 1)
          AnimatedBuilder(
            animation: _ring1,
            builder: (_, __) => Opacity(
              opacity: (1.0 - _ring1.value * 0.5).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.7 + (_ring1.value * 0.3),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Spinning arc (CustomPainter)
          AnimatedBuilder(
            animation: _rotationController,
            builder: (_, __) => CustomPaint(
              size: const Size(80, 80),
              painter: _SpinningArcPainter(_rotationController.value),
            ),
          ),
          // Center icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: _progressAnimation.value,
          minHeight: 4,
          backgroundColor: Colors.white.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white.withOpacity(0.85),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.security, color: Colors.white70, size: 16),
          SizedBox(width: 8),
          Text(
            '🔒 Secured by 256-bit encryption (Simulated)',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painter: Spinning Arc ──────────────────────────────────────────────

class _SpinningArcPainter extends CustomPainter {
  final double progress;

  _SpinningArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Main spinning arc
    final startAngle = (progress * 2 * math.pi * 1.5) - math.pi / 2;
    const sweepAngle = math.pi * 1.1;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Trailing arc (lighter)
    final trailPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle,
      (2 * math.pi) - sweepAngle,
      false,
      trailPaint,
    );
  }

  @override
  bool shouldRepaint(_SpinningArcPainter old) => old.progress != progress;
}
