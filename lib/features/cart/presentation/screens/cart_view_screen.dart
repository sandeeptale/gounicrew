import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../../../payment/presentation/screens/checkout_screen.dart';

class CartViewScreen extends StatefulWidget {
  const CartViewScreen({super.key});

  @override
  State<CartViewScreen> createState() => _CartViewScreenState();
}

class _CartViewScreenState extends State<CartViewScreen> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    final success = context.read<CartCubit>().applyPromo(code);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success
          ? 'Promo "$code" applied! 🎉'
          : 'Invalid code. Try SAVE10, FRESH20 or WELCOME15'),
      backgroundColor:
          success ? AppTheme.secondaryColor : AppTheme.errorColor,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _checkout(CartState cart) {
    if (cart.items.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CheckoutScreen(
        cartItems: cart.items.map((i) => i.toCheckoutCartItem()).toList(),
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        total: cart.grandTotal,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Clear Cart',
                onPressed: () => _confirmClear(context),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return _buildEmptyCart();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  children: [
                    // Cart Items
                    ...state.items.map((item) => _buildCartItem(context, item)),
                    const SizedBox(height: 12),

                    // Promo Code Card
                    _buildPromoCard(context, state),
                    const SizedBox(height: 12),

                    // Bill Summary
                    _buildBillCard(state),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Checkout Bar
              _buildCheckoutBar(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryColor)),
                  const SizedBox(height: 2),
                  Text('${formatCurrency(item.price)} / ${item.unit}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondaryColor)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatCurrency(item.totalPrice),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor)),
                      // Qty controls
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            _qtyBtn(Icons.remove, () {
                              context
                                  .read<CartCubit>()
                                  .updateQuantity(item.id, item.quantity - 1);
                            }),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('${item.quantity}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ),
                            _qtyBtn(Icons.add, () {
                              context
                                  .read<CartCubit>()
                                  .updateQuantity(item.id, item.quantity + 1);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(icon, size: 16, color: AppTheme.primaryColor),
        ),
      );

  Widget _buildPromoCard(BuildContext context, CartState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Promo Code',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryColor)),
            const SizedBox(height: 10),
            if (state.promoCode != null)
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.secondaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${state.promoCode} — ${(state.discountRate * 100).toInt()}% OFF applied',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondaryColor,
                          fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.read<CartCubit>().removePromo(),
                    child: const Text('Remove',
                        style: TextStyle(color: AppTheme.errorColor)),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'e.g. SAVE10, FRESH20',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppTheme.borderColor)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppTheme.borderColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppTheme.primaryColor, width: 2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _applyPromo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard(CartState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bill Summary',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryColor)),
            const Divider(height: 20),
            _billRow('Items (${state.totalItemCount})',
                formatCurrency(state.subtotal)),
            if (state.discountAmount > 0)
              _billRow(
                'Discount (${state.promoCode})',
                '- ${formatCurrency(state.discountAmount)}',
                valueColor: AppTheme.secondaryColor,
              ),
            _billRow('Delivery Fee', formatCurrency(state.deliveryFee)),
            const Divider(height: 20),
            _billRow('Grand Total', formatCurrency(state.grandTotal),
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _billRow(String label, String value,
      {bool isTotal = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 15 : 13,
                  fontWeight:
                      isTotal ? FontWeight.w800 : FontWeight.w500,
                  color: isTotal
                      ? AppTheme.textPrimaryColor
                      : AppTheme.textSecondaryColor)),
          Text(value,
              style: TextStyle(
                  fontSize: isTotal ? 17 : 13,
                  fontWeight: FontWeight.w800,
                  color: valueColor ??
                      (isTotal
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimaryColor))),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Payable',
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.textSecondaryColor)),
                Text(formatCurrency(state.grandTotal),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _checkout(state),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Checkout',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 44, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 20),
            const Text('Your Cart is Empty',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimaryColor)),
            const SizedBox(height: 8),
            const Text('Add some fresh products to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: AppTheme.textSecondaryColor)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // If this screen was pushed onto the navigator (e.g. from
                // profile tab), pop back. If it's embedded in an IndexedStack
                // tab (no route to pop), do nothing — the user can tap the
                // Shop tab themselves.
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart?'),
        content:
            const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              Navigator.pop(ctx);
            },
            child: const Text('Clear',
                style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
