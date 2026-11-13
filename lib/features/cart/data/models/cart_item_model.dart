import 'package:flutter/material.dart';
import 'package:gounicrewsan/features/payment/presentation/screens/checkout_screen.dart';

// ── Cart Item model ──────────────────────────────────────────────────────────

class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String unit;
  final IconData icon;
  final Color iconColor;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.icon,
    required this.iconColor,
  });

  double get totalPrice => price * quantity;

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? unit,
    IconData? icon,
    Color? iconColor,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
    );
  }

  CheckoutCartItem toCheckoutCartItem() {
    return CheckoutCartItem(
      id: id,
      name: name,
      price: price,
      quantity: quantity,
      icon: icon,
      iconBg: iconColor.withValues(alpha: 0.15),
    );
  }
}
