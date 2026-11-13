import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../cubit/payment_cubit.dart';
import '../../data/models/payment_model.dart';
import '../../../../core/utils/hive_boxes.dart';
import 'cart_screen.dart';
import 'payment_history_screen.dart';

class DevSettingsScreen extends StatefulWidget {
  const DevSettingsScreen({super.key});

  @override
  State<DevSettingsScreen> createState() => _DevSettingsScreenState();
}

class _DevSettingsScreenState extends State<DevSettingsScreen> {
  int _totalTransactions = 0;
  int _successfulTransactions = 0;
  int _failedTransactions = 0;
  int _pendingTransactions = 0;
  int _cancelledTransactions = 0;

  @override
  void initState() {
    super.initState();
    _loadHiveStats();
  }

  Future<void> _loadHiveStats() async {
    try {
      final box = Hive.box<PaymentModel>(HiveBoxes.payments);
      final payments = box.values.toList();
      setState(() {
        _totalTransactions = payments.length;
        _successfulTransactions =
            payments.where((p) => p.paymentStatus == 'success').length;
        _failedTransactions =
            payments.where((p) => p.paymentStatus == 'failed').length;
        _pendingTransactions =
            payments.where((p) => p.paymentStatus == 'pending').length;
        _cancelledTransactions =
            payments.where((p) => p.paymentStatus == 'cancelled').length;
      });
    } catch (_) {
      // Box may not be open yet
    }
  }

  Future<void> _clearAllTestData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Test Data'),
        content: const Text(
          'This will permanently delete all test transactions from local storage. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final box = Hive.box<PaymentModel>(HiveBoxes.payments);
        await box.clear();
        await _loadHiveStats();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ All test data cleared successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to clear data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showTestScenarioSheet(
    BuildContext context, {
    required String scenarioLabel,
    required String scenarioKey,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Proceed to test $scenarioLabel payment?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test Amount: ₹999.00',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Scenario: $scenarioKey',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<PaymentCubit>(),
                            child: CartScreen(
                              testScenario: scenarioKey,
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Start Test Flow'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('⚙️ Dev Settings'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: const Text(
                'BETA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.orange.shade700,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHiveStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Warning Banner ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                border: Border.all(color: Colors.amber.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.amber.shade700, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      '🧪 Developer Mode — This screen is for testing only. No real payments are processed.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6D4C00),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Section: Test Payment Scenarios ─────────────────────────
            _SectionHeader(title: 'Test Payment Outcomes'),
            const SizedBox(height: 12),

            _ScenarioCard(
              icon: Icons.check_circle,
              iconColor: Colors.green.shade600,
              title: 'Simulate Successful Payment',
              subtitle: 'Creates a successful transaction in Hive',
              backgroundColor: const Color(0xFFE8F5E9),
              borderColor: Colors.green.shade200,
              scenarioLabel: 'Success',
              scenarioKey: 'success',
              onTap: () => _showTestScenarioSheet(
                context,
                scenarioLabel: 'Success',
                scenarioKey: 'success',
              ),
            ),
            const SizedBox(height: 10),

            _ScenarioCard(
              icon: Icons.error,
              iconColor: Colors.red.shade600,
              title: 'Simulate Failed Payment',
              subtitle: 'Creates a failed transaction with error reason',
              backgroundColor: const Color(0xFFFFEBEE),
              borderColor: Colors.red.shade200,
              scenarioLabel: 'Failure',
              scenarioKey: 'failed',
              onTap: () => _showTestScenarioSheet(
                context,
                scenarioLabel: 'Failure',
                scenarioKey: 'failed',
              ),
            ),
            const SizedBox(height: 10),

            _ScenarioCard(
              icon: Icons.hourglass_empty,
              iconColor: Colors.orange.shade700,
              title: 'Simulate Pending Payment',
              subtitle: 'Creates a pending transaction awaiting confirmation',
              backgroundColor: const Color(0xFFFFF3E0),
              borderColor: Colors.orange.shade200,
              scenarioLabel: 'Pending',
              scenarioKey: 'pending',
              onTap: () => _showTestScenarioSheet(
                context,
                scenarioLabel: 'Pending',
                scenarioKey: 'pending',
              ),
            ),
            const SizedBox(height: 10),

            _ScenarioCard(
              icon: Icons.cancel,
              iconColor: Colors.grey.shade600,
              title: 'Simulate Cancelled Payment',
              subtitle: 'Creates a cancelled transaction record',
              backgroundColor: const Color(0xFFF5F5F5),
              borderColor: Colors.grey.shade300,
              scenarioLabel: 'Cancellation',
              scenarioKey: 'cancelled',
              onTap: () => _showTestScenarioSheet(
                context,
                scenarioLabel: 'Cancellation',
                scenarioKey: 'cancelled',
              ),
            ),

            const SizedBox(height: 28),

            // ─── Section: Hive Storage Info ───────────────────────────────
            _SectionHeader(title: 'Hive Storage Info'),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StorageStat(
                      label: 'Total Transactions',
                      value: _totalTransactions,
                      color: const Color(0xFF1E3A5F),
                    ),
                    const Divider(height: 20),
                    _StorageStat(
                      label: 'Successful',
                      value: _successfulTransactions,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _StorageStat(
                      label: 'Failed',
                      value: _failedTransactions,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _StorageStat(
                      label: 'Pending',
                      value: _pendingTransactions,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _StorageStat(
                      label: 'Cancelled',
                      value: _cancelledTransactions,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _clearAllTestData,
                        icon: const Icon(Icons.delete_forever_outlined,
                            color: Colors.red),
                        label: const Text(
                          'Clear All Test Data',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ─── Section: App Info ────────────────────────────────────────
            _SectionHeader(title: 'App Info'),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.info_outline,
                      label: 'App Version',
                      value: '1.0.0 (Simulated Payment Mode)',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.flutter_dash,
                      label: 'Framework',
                      value: 'Flutter (Latest stable)',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_outlined,
                              size: 18, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '⚠️ This is a payment simulation. No real financial transactions occur.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6D4C00),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Quick nav to history
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<PaymentCubit>(),
                    child: const PaymentHistoryScreen(),
                  ),
                ),
              ).then((_) => _loadHiveStats()),
              icon: const Icon(Icons.history),
              label: const Text('View Payment History'),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E3A5F),
        letterSpacing: 0.3,
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.borderColor,
    required this.scenarioLabel,
    required this.scenarioKey,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color borderColor;
  final String scenarioLabel;
  final String scenarioKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StorageStat extends StatelessWidget {
  const _StorageStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black87)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1E3A5F)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
