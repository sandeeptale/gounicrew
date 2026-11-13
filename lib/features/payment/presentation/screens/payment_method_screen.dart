import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/payment_cubit.dart';
import '../../domain/enums/payment_method.dart';
import '../../../../core/utils/formatters.dart';
import 'payment_processing_screen.dart';
import 'checkout_screen.dart' show CheckoutCartItem;

class PaymentMethodScreen extends StatefulWidget {
  final String orderId;
  final String userId;
  final double amount;
  final String selectedAddress;
  final List<CheckoutCartItem>? cartItems;

  const PaymentMethodScreen({
    super.key,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.selectedAddress,
    this.cartItems,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentMethod? _selectedMethod;
  String _testScenario = 'success';
  bool _isLoading = false;

  // UPI
  final _upiController = TextEditingController();
  final _upiFormKey = GlobalKey<FormState>();

  // Card
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardFormKey = GlobalKey<FormState>();

  // Net Banking
  String? _selectedBank;

  static const double _walletBalance = 500.00;

  final List<String> _banks = [
    'SBI', 'HDFC', 'ICICI', 'Axis', 'Kotak', 'PNB', 'BOB', 'Yes Bank'
  ];

  final List<Map<String, dynamic>> _methods = [
    {
      'method': PaymentMethod.upi,
      'name': 'UPI',
      'subtitle': 'Pay using UPI ID or QR',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF6C63FF),
    },
    {
      'method': PaymentMethod.creditCard,
      'name': 'Credit Card',
      'subtitle': 'Visa, Mastercard, RuPay',
      'icon': Icons.credit_card,
      'color': Color(0xFF2196F3),
    },
    {
      'method': PaymentMethod.debitCard,
      'name': 'Debit Card',
      'subtitle': 'All major banks supported',
      'icon': Icons.credit_card_outlined,
      'color': Color(0xFF00BCD4),
    },
    {
      'method': PaymentMethod.netBanking,
      'name': 'Net Banking',
      'subtitle': '50+ banks supported',
      'icon': Icons.account_balance,
      'color': Color(0xFF4CAF50),
    },
    {
      'method': PaymentMethod.cashOnDelivery,
      'name': 'Cash on Delivery',
      'subtitle': 'Pay when delivered',
      'icon': Icons.local_shipping,
      'color': Color(0xFFFF9800),
    },
    {
      'method': PaymentMethod.wallet,
      'name': 'Wallet',
      'subtitle': 'Balance: ₹500.00',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Color(0xFFE91E63),
    },
  ];

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  bool get _isPayEnabled {
    if (_selectedMethod == null) return false;
    if (_isLoading) return false;
    switch (_selectedMethod!) {
      case PaymentMethod.upi:
        return _upiController.text.contains('@');
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        final digits = _cardNumberController.text.replaceAll(' ', '');
        return digits.length == 16 && _isExpiryValid(_expiryController.text);
      case PaymentMethod.netBanking:
        return _selectedBank != null;
      case PaymentMethod.wallet:
        return widget.amount <= _walletBalance;
      case PaymentMethod.cashOnDelivery:
        return true;
    }
  }

  bool _isExpiryValid(String expiry) {
    final parts = expiry.split('/');
    if (parts.length != 2) return false;
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    final now = DateTime.now();
    final fullYear = 2000 + year;
    if (fullYear < now.year) return false;
    if (fullYear == now.year && month < now.month) return false;
    return true;
  }

  double _expandedHeight() {
    if (_selectedMethod == null) return 0;
    switch (_selectedMethod!) {
      case PaymentMethod.upi:
        return 150;
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return 250;
      case PaymentMethod.netBanking:
        return 210;
      case PaymentMethod.wallet:
        return 110;
      case PaymentMethod.cashOnDelivery:
        return 100;
    }
  }

  void _onPayPressed() {
    if (!_isPayEnabled) return;

    // Validate forms
    if (_selectedMethod == PaymentMethod.upi) {
      if (!(_upiFormKey.currentState?.validate() ?? false)) return;
    }
    if (_selectedMethod == PaymentMethod.creditCard ||
        _selectedMethod == PaymentMethod.debitCard) {
      if (!(_cardFormKey.currentState?.validate() ?? false)) return;
    }

    setState(() => _isLoading = true);

    // Build a human-readable items summary from cart items
    final itemsSummary = widget.cartItems != null && widget.cartItems!.isNotEmpty
        ? widget.cartItems!
            .map((item) => '${item.name} ×${item.quantity}')
            .join(', ')
        : null;

    final method = _selectedMethod!;
    context.read<PaymentCubit>().processPayment(
      orderId: widget.orderId,
      userId: widget.userId,
      amount: widget.amount,
      method: method,
      testScenario: _testScenario,
      itemsSummary: itemsSummary,
    );

    final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PaymentCubit>(),
          child: PaymentProcessingScreen(
            orderId: widget.orderId,
            transactionId: transactionId,
            amount: widget.amount,
            paymentMethodName: method.displayName,
          ),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          color: const Color(0xFF1E3A5F),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A5F),
              ),
            ),
            Text(
              formatCurrency(widget.amount),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAmountCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._methods.map((m) => _buildMethodCard(m)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _buildPayButton(),
          _buildTestScenarioSection(),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D5B8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Amount',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatCurrency(widget.amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Order #${widget.orderId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> methodData) {
    final PaymentMethod method = methodData['method'];
    final bool isSelected = _selectedMethod == method;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMethod = method;
            _selectedBank = null;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1E3A5F)
                  : const Color(0xFFE0E0E0),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF1E3A5F).withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (methodData['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        methodData['icon'] as IconData,
                        color: methodData['color'] as Color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            methodData['name'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            methodData['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9E9E9E),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1E3A5F)
                              : const Color(0xFFBDBDBD),
                          width: isSelected ? 6 : 2,
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Expanded input section
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isSelected ? _expandedHeight() : 0,
                curve: Curves.easeInOut,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(),
                child: isSelected
                    ? SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: _buildExpandedInput(method),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedInput(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:
        return _buildUpiInput();
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return _buildCardInput();
      case PaymentMethod.netBanking:
        return _buildNetBankingInput();
      case PaymentMethod.wallet:
        return _buildWalletInfo();
      case PaymentMethod.cashOnDelivery:
        return _buildCodInfo();
    }
  }

  Widget _buildUpiInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Form(
            key: _upiFormKey,
            child: TextFormField(
              controller: _upiController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'yourname@upi',
                labelText: 'Enter UPI ID',
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '@',
                    style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Please enter UPI ID';
                if (!val.contains('@')) return 'Invalid UPI ID (must contain @)';
                return null;
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Text('⚠️', style: TextStyle(fontSize: 13)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'SIMULATION — No real transaction will occur',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF856404),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Form(
            key: _cardFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CardNumberFormatter(),
                  ],
                  maxLength: 19,
                  decoration: InputDecoration(
                    hintText: 'XXXX XXXX XXXX XXXX',
                    labelText: 'Card Number',
                    prefixIcon: const Icon(Icons.credit_card, size: 20, color: Color(0xFF2196F3)),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter card number';
                    if (val.replaceAll(' ', '').length != 16) return 'Must be 16 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        inputFormatters: [_ExpiryFormatter()],
                        maxLength: 5,
                        decoration: InputDecoration(
                          hintText: 'MM/YY',
                          labelText: 'Expiry',
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5)),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (!_isExpiryValid(val)) return 'Invalid/expired';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 3,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: '•••',
                          labelText: 'CVV',
                          counterText: '',
                          prefixIcon: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF2196F3)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5)),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (val.length != 3) return '3 digits';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, size: 13, color: Color(0xFF2E7D32)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '🔒 SIMULATED CARD — No real data collected',
                    style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetBankingInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 10),
          const Text('Select your bank', style: TextStyle(fontSize: 12, color: Color(0xFF757575), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _banks.map((bank) {
              final isSelected = _selectedBank == bank;
              return GestureDetector(
                onTap: () => setState(() => _selectedBank = bank),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1E3A5F).withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFE0E0E0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFF78909C),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          bank[0],
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        bank,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFF424242),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfo() {
    final bool insufficient = widget.amount > _walletBalance;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: insufficient ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: insufficient ? const Color(0xFFEF9A9A) : const Color(0xFFA5D6A7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  insufficient ? Icons.warning_amber_rounded : Icons.account_balance_wallet,
                  color: insufficient ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insufficient ? 'Insufficient Balance' : 'Available Balance: ₹${_walletBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: insufficient ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
                        ),
                      ),
                      if (insufficient)
                        const Text(
                          'Your wallet balance is insufficient for this order.',
                          style: TextStyle(fontSize: 12, color: Color(0xFFB71C1C)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_shipping, color: Color(0xFFE65100), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pay with cash when your order is delivered. Available for select pin codes.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF5D4037), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isPayEnabled ? _onPayPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A5F),
            disabledBackgroundColor: const Color(0xFFBDBDBD),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Pay ${formatCurrency(widget.amount)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTestScenarioSection() {
    final scenarios = [
      {'key': 'success', 'label': '✅ Success'},
      {'key': 'failure', 'label': '❌ Fail'},
      {'key': 'pending', 'label': '⏳ Pending'},
      {'key': 'cancelled', 'label': '✖ Cancel'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: const Color(0xFFE8F5E9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧪 Test Scenario (Dev Mode)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF388E3C),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: scenarios.map((s) {
              final bool isSelected = _testScenario == s['key'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _testScenario = s['key']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFBDBDBD),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        s['label']!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF616161),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Input Formatters ──────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 16) {
      return oldValue;
    }
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) return oldValue;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
