import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/payment_model.dart';
import '../../domain/enums/payment_method.dart';
import '../../domain/enums/payment_status.dart';
import '../../../../core/utils/formatters.dart';

class PaymentDetailScreen extends StatelessWidget {
  final PaymentModel payment;

  const PaymentDetailScreen({super.key, required this.payment});

  void _copyToClipboard(BuildContext context, String text, String label) {
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

  @override
  Widget build(BuildContext context) {
    final status = paymentStatusFromString(payment.paymentStatus);
    final method = paymentMethodFromString(payment.paymentMethod);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Transaction Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A1A)),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, status),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Transaction Info',
              children: [
                _buildDetailRow(
                  context,
                  label: 'Transaction ID',
                  value: payment.transactionId,
                  displayValue:
                      Formatters.formatTransactionId(payment.transactionId),
                  copyLabel: 'Transaction ID',
                ),
                const Divider(height: 1, thickness: 0.5),
                _buildDetailRow(
                  context,
                  label: 'Order ID',
                  value: payment.orderId,
                  displayValue: payment.orderId,
                  copyLabel: 'Order ID',
                ),
                const Divider(height: 1, thickness: 0.5),
                _buildStatusRow(status),
              ],
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: 'Payment Info',
              children: [
                _buildSimpleDetailRow(
                  label: 'Amount',
                  value: Formatters.formatCurrency(payment.amount),
                  valueColor: status.color,
                  valueBold: true,
                ),
                const Divider(height: 1, thickness: 0.5),
                _buildSimpleDetailRow(
                  label: 'Payment Method',
                  value: method.displayName,
                ),
                const Divider(height: 1, thickness: 0.5),
                _buildSimpleDetailRow(
                  label: 'Payment Date',
                  value: Formatters.formatDate(payment.paymentDate),
                ),
                if (payment.failureReason != null &&
                    payment.paymentStatus == PaymentStatus.failed.name) ...[
                  const Divider(height: 1, thickness: 0.5),
                  _buildSimpleDetailRow(
                    label: 'Failure Reason',
                    value: payment.failureReason!,
                    valueColor: const Color(0xFFE53935),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: 'Timestamps',
              children: [
                _buildSimpleDetailRow(
                  label: 'Created At',
                  value: Formatters.formatDate(payment.createdAt),
                ),
                const Divider(height: 1, thickness: 0.5),
                _buildSimpleDetailRow(
                  label: 'Updated At',
                  value: Formatters.formatDate(payment.updatedAt),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, PaymentStatus status) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status.color.withOpacity(0.15),
            ),
            child: Icon(
              status.icon,
              color: status.color,
              size: 38,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(payment.amount),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A5F),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required String displayValue,
    required String copyLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    displayValue,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _copyToClipboard(context, value, copyLabel),
                  child: const Icon(
                    Icons.copy_rounded,
                    size: 15,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(PaymentStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: status.color.withOpacity(0.3)),
            ),
            child: Text(
              status.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
