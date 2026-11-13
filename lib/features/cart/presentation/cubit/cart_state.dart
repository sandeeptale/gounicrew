import 'package:equatable/equatable.dart';
import '../../data/models/cart_item_model.dart';

class CartState extends Equatable {
  final List<CartItemModel> items;
  final String? promoCode;
  final double discountRate;

  const CartState({
    this.items = const [],
    this.promoCode,
    this.discountRate = 0.0,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get discountAmount => subtotal * discountRate;
  double get deliveryFee => items.isNotEmpty ? 40.0 : 0.0;
  double get grandTotal =>
      items.isEmpty ? 0.0 : (subtotal - discountAmount + deliveryFee);

  int getProductQuantity(String productId) {
    for (final item in items) {
      if (item.productId == productId) return item.quantity;
    }
    return 0;
  }

  CartItemModel? getItemByProductId(String productId) {
    for (final item in items) {
      if (item.productId == productId) return item;
    }
    return null;
  }

  CartState copyWith({
    List<CartItemModel>? items,
    String? promoCode,
    double? discountRate,
    bool clearPromo = false,
  }) {
    return CartState(
      items: items ?? this.items,
      promoCode: clearPromo ? null : (promoCode ?? this.promoCode),
      discountRate: clearPromo ? 0.0 : (discountRate ?? this.discountRate),
    );
  }

  @override
  List<Object?> get props => [items, promoCode, discountRate];
}
