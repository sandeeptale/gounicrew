import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_item_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addItem({
    required String productId,
    required String name,
    required double price,
    required String unit,
    required IconData icon,
    required Color iconColor,
    int quantity = 1,
  }) {
    final existingIndex =
        state.items.indexWhere((item) => item.productId == productId);

    List<CartItemModel> updated;
    if (existingIndex >= 0) {
      updated = List.from(state.items);
      final cur = updated[existingIndex];
      updated[existingIndex] = cur.copyWith(quantity: cur.quantity + quantity);
    } else {
      final newItem = CartItemModel(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        name: name,
        price: price,
        quantity: quantity,
        unit: unit,
        icon: icon,
        iconColor: iconColor,
      );
      updated = [...state.items, newItem];
    }
    emit(state.copyWith(items: updated));
  }

  void updateQuantity(String cartItemId, int newQty) {
    if (newQty <= 0) {
      removeItem(cartItemId);
      return;
    }
    final updated = state.items.map((item) {
      return item.id == cartItemId ? item.copyWith(quantity: newQty) : item;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void removeItem(String cartItemId) {
    final updated =
        state.items.where((item) => item.id != cartItemId).toList();
    emit(state.copyWith(items: updated));
  }

  int getProductQuantity(String productId) =>
      state.getProductQuantity(productId);

  CartItemModel? getItemByProductId(String productId) =>
      state.getItemByProductId(productId);

  void decrementProduct(String productId) {
    final item = getItemByProductId(productId);
    if (item != null) {
      updateQuantity(item.id, item.quantity - 1);
    }
  }

  bool applyPromo(String code) {
    final cleaned = code.trim().toUpperCase();
    final promos = {
      'SAVE10': 0.10,
      'FRESH20': 0.20,
      'WELCOME15': 0.15,
      'HALF50': 0.50,
    };
    if (promos.containsKey(cleaned)) {
      emit(state.copyWith(promoCode: cleaned, discountRate: promos[cleaned]!));
      return true;
    }
    return false;
  }

  void removePromo() => emit(state.copyWith(clearPromo: true));

  void clearCart() => emit(const CartState());
}
