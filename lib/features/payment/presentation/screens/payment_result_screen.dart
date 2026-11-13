import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../../data/models/payment_model.dart';
import '../../domain/enums/payment_method.dart';
import '../../../../core/utils/formatters.dart';
import 'order_summary_screen.dart';
import 'payment_method_screen.dart';
import 'package:gounicrewsan/features/product/presentation/screens/home_screen.dart';

class PaymentResultScreen extends StatefulWidget {
  final String result; // 'success' | 'failure' | 'pending' | 'cancelled'
  final PaymentModel payment;

  const PaymentResultScreen({
    super.key,
    required this.result,
    required this.payment,
  });

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _shakeController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;

  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start entry animations based on result type
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _fadeController.forward();
    });
    if (widget.result == 'failure' || widget.result == 'cancelled') {
      _shakeController.forward();
    }
    if (widget.result == 'pending') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _navigateToCart() => _navigateToHome();

  void _navigateToPaymentMethod() {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == '/payment-method' || route.isFirst,
    );
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentMethodScreen(
            orderId: widget.payment.orderId,
            userId: widget.payment.userId,
            amount: widget.payment.amount,
            selectedAddress: '',
          ),
        ),
      );
    }
  }

  Future<void> _checkPendingStatus() async {
    setState(() => _isCheckingStatus = true);
    try {
      await context
          .read<PaymentCubit>()
          .checkPendingStatus(widget.payment.transactionId);
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateToHome();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1E3A5F), size: 20),
            tooltip: 'Home',
            onPressed: _navigateToHome,
          ),
          actions: [
            TextButton.icon(
              onPressed: _navigateToHome,
              icon: const Icon(Icons.home_outlined,
                  size: 18, color: Color(0xFF1E3A5F)),
              label: const Text(
                'Home',
                style: TextStyle(
                  color: Color(0xFF1E3A5F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocListener<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (state is PaymentSuccess) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PaymentResultScreen(
                    result: 'success',
                    payment: state.payment,
                  ),
                ),
              );
            } else if (state is PaymentFailure) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PaymentResultScreen(
                    result: 'failure',
                    payment: state.payment,
                  ),
                ),
              );
            }
          },
          child: SafeArea(
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.result) {
      case 'success':
        return _buildSuccessState();
      case 'failure':
        return _buildFailureState();
      case 'pending':
        return _buildPendingState();
      case 'cancelled':
        return _buildCancelledState();
      default:
        return _buildSuccessState();
    }
  }

  // ─── SUCCESS ─────────────────────────────────────────────────────────────

  Widget _buildSuccessState() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildStatusBadge('Successful', const Color(0xFF4CAF50)),
                const SizedBox(height: 24),
                _buildSuccessCircle(),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Payment Successful!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your order has been confirmed',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _buildDetailsCard(showFailureReason: false),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildSuccessButtons(),
      ],
    );
  }

  Widget _buildSuccessCircle() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF4CAF50),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 56,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderSummaryScreen.fromPayment(
                      payment: widget.payment,
                      deliveryAddress: 'Home Address',
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Order Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _navigateToHome,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4CAF50)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── FAILURE ─────────────────────────────────────────────────────────────

  Widget _buildFailureState() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildStatusBadge('Failed', const Color(0xFFE53935)),
                const SizedBox(height: 24),
                _buildFailureCircle(),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Payment Failed',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.payment.failureReason ??
                            'Transaction could not be completed',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _buildDetailsCard(showFailureReason: true),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildFailureButtons(),
      ],
    );
  }

  Widget _buildFailureCircle() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeOffset = _shakeController.isAnimating
            ? 10 *
                (0.5 - (_shakeAnimation.value - 0.5).abs()) *
                (_shakeAnimation.value > 0.5 ? 1 : -1)
            : 0.0;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE53935),
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 56,
          ),
        ),
      ),
    );
  }

  Widget _buildFailureButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _navigateToPaymentMethod,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _navigateToCart,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE53935)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Cart',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE53935),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PENDING ─────────────────────────────────────────────────────────────

  Widget _buildPendingState() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildStatusBadge('Pending', const Color(0xFFFF9800)),
                const SizedBox(height: 24),
                _buildPendingCircle(),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Payment Pending',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your payment is being verified',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _buildDetailsCard(showFailureReason: false),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildPendingButtons(),
      ],
    );
  }

  Widget _buildPendingCircle() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _pulseAnimation.value,
          child: child,
        );
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFF9800),
          ),
          child: const Icon(
            Icons.hourglass_top_rounded,
            color: Colors.white,
            size: 56,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _isCheckingStatus ? null : _checkPendingStatus,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCheckingStatus
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Check Status',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _navigateToCart,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF9800)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Return to Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF9800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CANCELLED ───────────────────────────────────────────────────────────

  Widget _buildCancelledState() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildStatusBadge('Cancelled', const Color(0xFF9E9E9E)),
                const SizedBox(height: 24),
                _buildCancelledCircle(),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Payment Cancelled',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your payment was not processed',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _buildDetailsCard(showFailureReason: false),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildCancelledButtons(),
      ],
    );
  }

  Widget _buildCancelledCircle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF9E9E9E),
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 56,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelledButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _navigateToPaymentMethod,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _navigateToCart,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF9E9E9E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Return to Cart',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SHARED COMPONENTS ───────────────────────────────────────────────────

  Widget _buildStatusBadge(String label, Color color) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => Opacity(
        opacity: _fadeAnimation.value,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard({required bool showFailureReason}) {
    final payment = widget.payment;
    final isFailed = widget.result == 'failure';

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => Opacity(
        opacity: _fadeAnimation.value,
        child: child,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _DetailRow(
              label: 'Transaction ID',
              value: Formatters.formatTransactionId(payment.transactionId),
              onCopy: () =>
                  _copyToClipboard(payment.transactionId, 'Transaction ID'),
            ),
            const Divider(height: 20, thickness: 0.8),
            _DetailRow(
              label: 'Order ID',
              value: payment.orderId,
              onCopy: () => _copyToClipboard(payment.orderId, 'Order ID'),
            ),
            const Divider(height: 20, thickness: 0.8),
            _DetailRow(
              label: 'Amount',
              value: Formatters.formatCurrency(payment.amount),
              valueColor: isFailed
                  ? Colors.grey[600]
                  : const Color(0xFF4CAF50),
              valueBold: true,
            ),
            const Divider(height: 20, thickness: 0.8),
            _DetailRow(
              label: 'Payment Method',
              value: paymentMethodFromString(payment.paymentMethod).displayName,
            ),
            const Divider(height: 20, thickness: 0.8),
            _DetailRow(
              label: 'Date & Time',
              value: Formatters.formatDate(payment.paymentDate),
            ),
            if (showFailureReason && payment.failureReason != null) ...[
              const Divider(height: 20, thickness: 0.8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFE53935), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payment.failureReason!,
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── SHARED DETAIL ROW WIDGET ─────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;
  final VoidCallback? onCopy;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  valueBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onCopy != null) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onCopy,
            child: const Icon(
              Icons.copy_rounded,
              size: 16,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ],
      ],
    );
  }
}
