import 'package:flutter/material.dart';
import '../../data/models/payment_model.dart';
import '../../domain/enums/payment_method.dart';
import '../../domain/enums/payment_status.dart';
import 'package:gounicrewsan/features/product/presentation/screens/home_screen.dart';

// ---------------------------------------------------------------------------
// OrderSummaryScreen — shown after a successful payment
// ---------------------------------------------------------------------------

class OrderSummaryScreen extends StatelessWidget {
  final PaymentModel payment;

  /// Items ordered (passed from checkout so we can display them here)
  final List<OrderItem> items;

  /// Delivery address selected during checkout
  final String deliveryAddress;

  const OrderSummaryScreen({
    super.key,
    required this.payment,
    required this.items,
    required this.deliveryAddress,
  });

  // Convenience constructor for callers that don't have OrderItem lists yet
  // (e.g., the payment-result screen can pass an empty list).
  factory OrderSummaryScreen.fromPayment({
    required PaymentModel payment,
    required String deliveryAddress,
    List<OrderItem>? items,
  }) =>
      OrderSummaryScreen(
        payment: payment,
        deliveryAddress: deliveryAddress,
        items: items ?? const [],
      );

  String _formatCurrency(double amount) {
    final str = amount.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0) {
        if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
          buf.write(',');
        }
      }
      buf.write(str[i]);
      count++;
    }
    return '₹${buf.toString().split('').reversed.join()}';
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $period';
  }

  String _truncateId(String id) {
    if (id.length <= 12) return id;
    return '...${id.substring(id.length - 12)}';
  }

  String _estimatedDelivery() {
    final delivery = payment.paymentDate.add(const Duration(days: 5));
    final deliveryEnd = payment.paymentDate.add(const Duration(days: 7));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${delivery.day}–${deliveryEnd.day} ${months[deliveryEnd.month - 1]} ${deliveryEnd.year}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            _buildSuccessBanner(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildOrderDetailsCard(),
                  const SizedBox(height: 14),
                  if (items.isNotEmpty) _buildItemsCard(),
                  if (items.isNotEmpty) const SizedBox(height: 14),
                  _buildPaymentSummaryCard(),
                  const SizedBox(height: 28),
                  _buildCTAButtons(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Success banner
  // ---------------------------------------------------------------------------

  Widget _buildSuccessBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 8, 16, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                tooltip: 'Back to Home',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.home_outlined,
                    color: Colors.white, size: 24),
                tooltip: 'Home',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 44,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Order Placed Successfully!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Thank you for your purchase 🎉',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDateTime(payment.paymentDate),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Order details card
  // ---------------------------------------------------------------------------

  Widget _buildOrderDetailsCard() {
    return _InfoCard(
      title: 'Order Details',
      icon: Icons.receipt_long_rounded,
      children: [
        _InfoRow(
          label: 'Order ID',
          value: payment.orderId,
          isMonospace: true,
        ),
        const _Divider(),
        _InfoRow(
          label: 'Estimated Delivery',
          value: _estimatedDelivery(),
          valueColor: const Color(0xFF2E7D32),
          icon: Icons.local_shipping_rounded,
        ),
        const _Divider(),
        _InfoRow(
          label: 'Delivery Address',
          value: deliveryAddress,
          isMultiLine: true,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Items ordered
  // ---------------------------------------------------------------------------

  Widget _buildItemsCard() {
    return _InfoCard(
      title: 'Items Ordered',
      icon: Icons.shopping_bag_rounded,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon,
                        size: 22, color: const Color(0xFF1E3A5F)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A5F),
                          ),
                        ),
                        Text(
                          'Qty: ${item.quantity}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF90A4AE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(item.price * item.quantity),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Payment summary
  // ---------------------------------------------------------------------------

  Widget _buildPaymentSummaryCard() {
    final methodLabel = () {
      try {
        final method = paymentMethodFromString(payment.paymentMethod);
        return method.displayName;
      } catch (_) {
        return payment.paymentMethod;
      }
    }();

    final statusLabel = () {
      try {
        final status = paymentStatusFromString(payment.paymentStatus);
        return status.label;
      } catch (_) {
        return payment.paymentStatus;
      }
    }();

    final statusColor = () {
      try {
        final status = paymentStatusFromString(payment.paymentStatus);
        return status.color;
      } catch (_) {
        return const Color(0xFF4CAF82);
      }
    }();

    return _InfoCard(
      title: 'Payment Summary',
      icon: Icons.payment_rounded,
      children: [
        _InfoRow(
          label: 'Amount Paid',
          value: _formatCurrency(payment.amount),
          isBold: true,
        ),
        const _Divider(),
        _InfoRow(label: 'Payment Method', value: methodLabel),
        const _Divider(),
        _InfoRow(
          label: 'Status',
          value: statusLabel,
          valueColor: statusColor,
        ),
        const _Divider(),
        _InfoRow(
          label: 'Transaction ID',
          value: _truncateId(payment.transactionId),
          isMonospace: true,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CTA buttons
  // ---------------------------------------------------------------------------

  Widget _buildCTAButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.local_shipping_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Order tracking coming soon!'),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF1E3A5F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          },
          icon: const Icon(Icons.local_shipping_outlined, size: 20),
          label: const Text(
            'Track Order',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A5F),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.shopping_bag_outlined, size: 20),
          label: const Text(
            'Continue Shopping',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1E3A5F),
            side: const BorderSide(color: Color(0xFF1E3A5F), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Local data model for order items
// ---------------------------------------------------------------------------

class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final IconData icon;
  final Color iconBg;

  const OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.icon,
    required this.iconBg,
  });
}

// ---------------------------------------------------------------------------
// Private reusable sub-widgets
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF1E3A5F)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFECEFF1)),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isMonospace;
  final bool isMultiLine;
  final Color? valueColor;
  final IconData? icon;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.isMonospace = false,
    this.isMultiLine = false,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final valueWidget = Text(
      value,
      textAlign: isMultiLine ? TextAlign.end : TextAlign.end,
      style: TextStyle(
        fontSize: 13,
        fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
        color: valueColor ?? const Color(0xFF1E3A5F),
        fontFamily: isMonospace ? 'monospace' : null,
        height: isMultiLine ? 1.5 : null,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: isMultiLine
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF90A4AE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                valueWidget,
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF90A4AE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                if (icon != null) ...[
                  Icon(icon, size: 14, color: valueColor ?? const Color(0xFF1E3A5F)),
                  const SizedBox(width: 4),
                ],
                Flexible(child: valueWidget),
              ],
            ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Divider(height: 1, color: Color(0xFFF5F5F5)),
      );
}

