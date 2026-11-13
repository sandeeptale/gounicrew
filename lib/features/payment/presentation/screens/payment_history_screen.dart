import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../../data/models/payment_model.dart';
import '../../domain/enums/payment_method.dart';
import '../../domain/enums/payment_status.dart';
import '../../../../core/utils/formatters.dart';
import 'payment_detail_screen.dart';
import 'package:gounicrewsan/features/auth/presentation/cubit/auth_cubit.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _selectedFilter = 'all';

  final List<_FilterOption> _filters = const [
    _FilterOption(label: 'All', value: 'all'),
    _FilterOption(label: 'Success', value: 'success'),
    _FilterOption(label: 'Failed', value: 'failed'),
    _FilterOption(label: 'Pending', value: 'pending'),
    _FilterOption(label: 'Cancelled', value: 'cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthCubit>().currentUser;
      context.read<PaymentCubit>().loadPaymentHistory(
        filter: _selectedFilter,
        userId: user?.id,
      );
    });
  }

  void _applyFilter(String filter) {
    setState(() => _selectedFilter = filter);
    final user = context.read<AuthCubit>().currentUser;
    context.read<PaymentCubit>().loadPaymentHistory(
      filter: filter,
      userId: user?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Payment History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF1A1A1A)),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined,
                color: Color(0xFF1E3A5F)),
            onPressed: () {},
            tooltip: 'Filter by Date',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChipsRow(),
          Expanded(
            child: BlocBuilder<PaymentCubit, PaymentState>(
              builder: (context, state) {
                if (state is PaymentHistoryLoading) {
                  return _buildLoadingState();
                } else if (state is PaymentHistoryLoaded) {
                  final payments = state.payments;
                  if (payments.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildTransactionList(payments);
                } else if (state is PaymentHistoryError) {
                  return _buildErrorState(state.message);
                }
                return _buildLoadingState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _applyFilter(filter.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1E3A5F)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1E3A5F)
                          : Colors.grey[400]!,
                    ),
                  ),
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<PaymentModel> payments) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TransactionCard(
            payment: payments[index],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      PaymentDetailScreen(payment: payments[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(height: 88),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () =>
                context.read<PaymentCubit>().loadPaymentHistory(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── FILTER OPTION MODEL ─────────────────────────────────────────────────

class _FilterOption {
  final String label;
  final String value;
  const _FilterOption({required this.label, required this.value});
}

// ─── TRANSACTION CARD WIDGET ─────────────────────────────────────────────

class TransactionCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.payment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = paymentStatusFromString(payment.paymentStatus);
    final method = paymentMethodFromString(payment.paymentMethod);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left: status icon in colored circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status.color.withValues(alpha: 0.12),
              ),
              child: Icon(
                status.icon,
                color: status.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Middle column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show items summary if available, else show orderId nicely
                  if (payment.itemsSummary != null && payment.itemsSummary!.isNotEmpty)
                    Text(
                      payment.itemsSummary!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      payment.orderId,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 3),
                  Text(
                    Formatters.formatCurrency(payment.amount),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: status.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${method.displayName}  •  ${Formatters.formatDate(payment.paymentDate)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right: status badge chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: status.color.withValues(alpha: 0.3)),
              ),
              child: Text(
                status.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: status.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
