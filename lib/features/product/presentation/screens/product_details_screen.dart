import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../cart/presentation/screens/cart_view_screen.dart';
import '../../data/models/product_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  ProductModel get p => product;

  void _addToCart(BuildContext context) {
    context.read<CartCubit>().addItem(
          productId: p.id,
          name: p.name,
          price: p.price,
          unit: p.unit,
          icon: p.icon,
          iconColor: p.color,
          quantity: 1,
        );
  }

  void _increment(BuildContext context) {
    context.read<CartCubit>().addItem(
          productId: p.id,
          name: p.name,
          price: p.price,
          unit: p.unit,
          icon: p.icon,
          iconColor: p.color,
          quantity: 1,
        );
  }

  void _decrement(BuildContext context) {
    context.read<CartCubit>().decrementProduct(p.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        final inCartQty = cart.getProductQuantity(p.id);
        final isItemInCart = inCartQty > 0;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Collapsible hero header ────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: p.color,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          p.color,
                          p.color.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 48),
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(p.icon, size: 60, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            p.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Badge(
                      isLabelVisible: cart.totalItemCount > 0,
                      label: Text('${cart.totalItemCount}'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CartViewScreen()),
                    ),
                  ),
                ],
              ),

              // ── Product details body ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + Rating + Stock
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: p.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p.category,
                              style: TextStyle(
                                color: p.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFB300), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${p.rating} (${p.reviewCount} reviews)',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondaryColor),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: p.inStock
                                  ? AppTheme.secondaryColor.withValues(alpha: 0.1)
                                  : AppTheme.errorColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p.inStock ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                color: p.inStock
                                    ? AppTheme.secondaryColor
                                    : AppTheme.errorColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatCurrency(p.price),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '/ ${p.unit}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          if (p.hasDiscount) ...[
                            const SizedBox(width: 10),
                            Text(
                              formatCurrency(p.originalPrice!),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondaryColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${p.discountPercent}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Blinkit-style Quantity / Cart Status Section ──────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isItemInCart ? 'In Your Cart' : 'Quantity',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isItemInCart
                                      ? '$inCartQty ${p.unit} (Total: ${formatCurrency(p.price * inCartQty)})'
                                      : 'Not added to cart yet',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isItemInCart
                                        ? AppTheme.primaryColor
                                        : AppTheme.textSecondaryColor,
                                    fontWeight: isItemInCart
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (!isItemInCart)
                              ElevatedButton.icon(
                                onPressed: p.inStock ? () => _addToCart(context) : null,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text(
                                  'ADD',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _decrement(context),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        child: Icon(Icons.remove,
                                            size: 18, color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: Text(
                                        '$inCartQty',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: inCartQty < p.maxQty
                                          ? () => _increment(context)
                                          : null,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        child: Icon(Icons.add,
                                            size: 18, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'About this product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        p.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Delivery Info
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.delivery_dining_rounded,
                                color: AppTheme.secondaryColor),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Free delivery on orders above ₹500. Order now for same-day delivery.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w500,
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
            ],
          ),

          // ── Bottom Action Bar ───────────────────────────────────────
          bottomSheet: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: isItemInCart
                  ? Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$inCartQty × ${p.unit} in Cart',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondaryColor)),
                            Text(formatCurrency(p.price * inCartQty),
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryColor)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _decrement(context),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  child: Icon(Icons.remove,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '$inCartQty',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: inCartQty < p.maxQty
                                    ? () => _increment(context)
                                    : null,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  child: Icon(Icons.add,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CartViewScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 18),
                              SizedBox(width: 4),
                              Text('View Cart',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('per ${p.unit}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondaryColor)),
                            Text(formatCurrency(p.price),
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryColor)),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart_rounded,
                              size: 20),
                          label: const Text('Add to Cart',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                          onPressed: p.inStock ? () => _addToCart(context) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
