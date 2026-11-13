import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../../domain/enums/payment_method.dart';
import '../../domain/enums/payment_status.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

/// A placeholder CartScreen that demonstrates the payment flow.
/// This will be replaced by a richer implementation by the UI agent.
class CartScreen extends StatefulWidget {
  final String? testScenario;

  const CartScreen({super.key, this.testScenario});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.upi;
  late String _testScenario;
  final double _orderAmount = 1299.00;
  final String _userId = 'USER_001';

  @override
  void initState() {
    super.initState();
    _testScenario = widget.testScenario ?? 'success';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () => _showHistory(context),
            tooltip: 'Payment History',
          ),
        ],
      ),
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess ||
              state is PaymentFailure ||
              state is PaymentPending ||
              state is PaymentCancelled) {
            _showResultSheet(context, state);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Summary',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 16),
                        _OrderRow(
                          label: 'Flutter Dev Course',
                          value: formatCurrency(_orderAmount),
                        ),
                        const Divider(height: 24),
                        _OrderRow(
                          label: 'Total',
                          value: formatCurrency(_orderAmount),
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Payment Method Selection
                Text('Payment Method', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                ...PaymentMethod.values.map((method) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: RadioListTile<PaymentMethod>(
                        value: method,
                        groupValue: _selectedMethod,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedMethod = val);
                          }
                        },
                        title: Text(method.displayName),
                        secondary:
                            Icon(method.icon, color: AppTheme.primaryColor),
                        activeColor: AppTheme.primaryColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Test Scenario Selector
                Text('Test Scenario', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Simulate payment outcome (dev mode)',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['success', 'failure', 'pending', 'cancelled']
                      .map((scenario) {
                    return ChoiceChip(
                      label: Text(scenario),
                      selected: _testScenario == scenario,
                      onSelected: (_) =>
                          setState(() => _testScenario = scenario),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Pay Button / Processing indicator
                if (state is PaymentProcessing)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Processing Payment...',
                                    style: theme.textTheme.titleSmall),
                                Text(
                                  '${state.paymentMethod} · ${formatCurrency(state.amount)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  FilledButton(
                    onPressed: () => _pay(context),
                    child: Text(
                      'Pay ${formatCurrency(_orderAmount)} via ${_selectedMethod.displayName}',
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _pay(BuildContext context) {
    final cubit = context.read<PaymentCubit>();
    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    cubit.processPayment(
      orderId: orderId,
      userId: _userId,
      amount: _orderAmount,
      method: _selectedMethod,
      testScenario: _testScenario,
    );
  }

  void _showResultSheet(BuildContext context, PaymentState state) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _PaymentResultSheet(
        state: state,
        onDone: () {
          Navigator.pop(context);
          context.read<PaymentCubit>().resetState();
        },
        onRetry: (state is PaymentFailure)
            ? () {
                Navigator.pop(context);
                _pay(context);
              }
            : null,
        onCheckStatus: (state is PaymentPending)
            ? () {
                final txnId = state.payment.transactionId;
                Navigator.pop(context);
                context.read<PaymentCubit>().checkPendingStatus(txnId);
              }
            : null,
      ),
    );
  }

  void _showHistory(BuildContext context) {
    context.read<PaymentCubit>().loadPaymentHistory();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<PaymentCubit>(),
        child: const _HistorySheet(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order Row Widget
// ---------------------------------------------------------------------------

class _OrderRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _OrderRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleSmall
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleSmall!
                  .copyWith(color: AppTheme.primaryColor)
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Payment Result Sheet
// ---------------------------------------------------------------------------

class _PaymentResultSheet extends StatelessWidget {
  final PaymentState state;
  final VoidCallback onDone;
  final VoidCallback? onRetry;
  final VoidCallback? onCheckStatus;

  const _PaymentResultSheet({
    required this.state,
    required this.onDone,
    this.onRetry,
    this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title;
    String subtitle;
    Color iconColor;
    IconData iconData;

    if (state is PaymentSuccess) {
      final s = state as PaymentSuccess;
      title = 'Payment Successful!';
      subtitle = 'Amount: ${formatCurrency(s.payment.amount)}';
      iconColor = AppTheme.secondaryColor;
      iconData = Icons.check_circle_outline_rounded;
    } else if (state is PaymentFailure) {
      final s = state as PaymentFailure;
      title = 'Payment Failed';
      subtitle = s.reason;
      iconColor = const Color(0xFFE53935);
      iconData = Icons.cancel_outlined;
    } else if (state is PaymentPending) {
      final s = state as PaymentPending;
      title = 'Payment Pending';
      subtitle =
          'Your payment of ${formatCurrency(s.payment.amount)} is being verified.';
      iconColor = const Color(0xFFF59E0B);
      iconData = Icons.hourglass_empty_rounded;
    } else if (state is PaymentCancelled) {
      final s = state as PaymentCancelled;
      title = 'Payment Cancelled';
      subtitle = 'Amount: ${formatCurrency(s.payment.amount)}';
      iconColor = const Color(0xFF9E9E9E);
      iconData = Icons.remove_circle_outline_rounded;
    } else {
      title = 'Payment Status';
      subtitle = 'Unknown state.';
      iconColor = AppTheme.primaryColor;
      iconData = Icons.info_outline;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Icon(iconData, size: 72, color: iconColor),
          const SizedBox(height: 16),
          Text(title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium!
                .copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (onCheckStatus != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton(
                onPressed: onCheckStatus,
                child: const Text('Check Payment Status'),
              ),
            ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton(
                onPressed: onRetry,
                child: const Text('Retry Payment'),
              ),
            ),
          FilledButton(
            onPressed: onDone,
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History Sheet
// ---------------------------------------------------------------------------

class _HistorySheet extends StatefulWidget {
  const _HistorySheet();

  @override
  State<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<_HistorySheet> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text('Transaction History',
                      style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  'all',
                  'success',
                  'failed',
                  'pending',
                  'cancelled'
                ].map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) {
                        setState(() => _filter = f);
                        context
                            .read<PaymentCubit>()
                            .loadPaymentHistory(filter: f);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  if (state is! PaymentHistoryLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: AppTheme.textSecondaryColor
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions found',
                            style: theme.textTheme.bodyMedium!.copyWith(
                                color: AppTheme.textSecondaryColor),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final tx = state.transactions[index];
                      final status = paymentStatusFromString(tx.paymentStatus);
                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: status.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(status.icon,
                                color: status.color, size: 22),
                          ),
                          title: Text(
                              formatTransactionId(tx.transactionId)),
                          subtitle: Text(
                            '${formatCurrency(tx.amount)} · ${formatDate(tx.paymentDate)}',
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: status.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.label,
                              style: theme.textTheme.labelSmall!
                                  .copyWith(color: status.color),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
