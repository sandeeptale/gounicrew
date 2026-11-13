import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gounicrewsan/features/auth/presentation/cubit/auth_cubit.dart';
import 'payment_method_screen.dart';

// ---------------------------------------------------------------------------
// Data transfer types used between Cart and Checkout
// ---------------------------------------------------------------------------

class CheckoutCartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final IconData icon;
  final Color iconBg;

  const CheckoutCartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.icon,
    required this.iconBg,
  });
}

class SavedAddress {
  final String id;
  final String type;      // "Home" | "Office"
  final String street;
  final String city;
  final String state;
  final String pincode;
  final IconData typeIcon;
  final Color typeBadgeColor;

  const SavedAddress({
    required this.id,
    required this.type,
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    required this.typeIcon,
    required this.typeBadgeColor,
  });

  String get fullAddress => '$street, $city, $state $pincode';
}

// ---------------------------------------------------------------------------
// CheckoutScreen
// ---------------------------------------------------------------------------

class CheckoutScreen extends StatefulWidget {
  final List<CheckoutCartItem> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const List<SavedAddress> _addresses = [
    SavedAddress(
      id: 'addr_001',
      type: 'Home',
      street: '42 MG Road',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560001',
      typeIcon: Icons.home_rounded,
      typeBadgeColor: Color(0xFF4CAF82),
    ),
    SavedAddress(
      id: 'addr_002',
      type: 'Office',
      street: '15 Tech Park, Whitefield',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560066',
      typeIcon: Icons.business_rounded,
      typeBadgeColor: Color(0xFF5C6BC0),
    ),
  ];

  String _selectedAddressId = 'addr_001';
  bool _orderSummaryExpanded = false;

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

  void _continueToPayment() {
    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    final authUser = context.read<AuthCubit>().currentUser;
    final userId = authUser?.id ?? 'USR_${DateTime.now().millisecondsSinceEpoch % 10000}';
    final selectedAddress = _addresses.firstWhere(
      (a) => a.id == _selectedAddressId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodScreen(
          orderId: orderId,
          userId: userId,
          amount: widget.total,
          selectedAddress: selectedAddress.fullAddress,
          cartItems: widget.cartItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E3A5F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF1E3A5F),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE0E0E0)),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('Delivery Address'),
                const SizedBox(height: 12),
                ..._addresses.map((addr) => _buildAddressCard(addr)),
                const SizedBox(height: 8),
                _buildAddNewAddressButton(),
                const SizedBox(height: 20),
                _buildOrderSummarySection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          _StepDot(label: 'Cart', isCompleted: true),
          _StepLine(isCompleted: true),
          _StepDot(label: 'Address', isActive: true),
          _StepLine(),
          _StepDot(label: 'Payment'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E3A5F),
      ),
    );
  }

  Widget _buildAddressCard(SavedAddress address) {
    final isSelected = _selectedAddressId == address.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressId = address.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFECEFF1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: address.typeBadgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: address.typeBadgeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: address.typeBadgeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(address.typeIcon,
                                  size: 12, color: address.typeBadgeColor),
                              const SizedBox(width: 4),
                              Text(
                                address.type,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: address.typeBadgeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedAddressId == address.id) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF82).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Selected',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4CAF82),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      address.fullAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF546E7A),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: address.id,
                groupValue: _selectedAddressId,
                activeColor: const Color(0xFF1E3A5F),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedAddressId = val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewAddressButton() {
    return OutlinedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Feature coming soon!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Add New Address'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1E3A5F),
        side: const BorderSide(color: Color(0xFF1E3A5F)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 0),
      ),
    );
  }

  Widget _buildOrderSummarySection() {
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
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () =>
                setState(() => _orderSummaryExpanded = !_orderSummaryExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _formatCurrency(widget.total),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _orderSummaryExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedSummary(),
            crossFadeState: _orderSummaryExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(color: Color(0xFFECEFF1)),
          const SizedBox(height: 8),
          ...widget.cartItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.iconBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Icon(item.icon, size: 18, color: const Color(0xFF1E3A5F)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF546E7A),
                        ),
                      ),
                    ),
                    Text(
                      '×${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCurrency(item.price * item.quantity),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(color: Color(0xFFECEFF1)),
          const SizedBox(height: 8),
          _SummaryLine(label: 'Subtotal', value: _formatCurrency(widget.subtotal)),
          const SizedBox(height: 6),
          _SummaryLine(
            label: 'Delivery',
            value: _formatCurrency(widget.deliveryFee),
            valueColor: const Color(0xFF4CAF82),
          ),
          const SizedBox(height: 10),
          _SummaryLine(
            label: 'Total',
            value: _formatCurrency(widget.total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: FilledButton(
        onPressed: _continueToPayment,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A5F),
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          'Continue to Payment',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepDot({
    required this.label,
    this.isActive = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isCompleted
        ? const Color(0xFF4CAF82)
        : isActive
            ? const Color(0xFF1E3A5F)
            : const Color(0xFFCFD8DC);
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          child: isCompleted
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive || isCompleted
                ? const Color(0xFF1E3A5F)
                : const Color(0xFF90A4AE),
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isCompleted;
  const _StepLine({this.isCompleted = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isCompleted ? const Color(0xFF4CAF82) : const Color(0xFFCFD8DC),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryLine({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? const Color(0xFF1E3A5F) : const Color(0xFF78909C),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF1E3A5F),
          ),
        ),
      ],
    );
  }
}

