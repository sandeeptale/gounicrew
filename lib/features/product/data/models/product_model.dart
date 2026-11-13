import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice; // null = no discount
  final String unit; // 'kg', 'piece', 'dozen', 'pack', 'litre'
  final String description;
  final IconData icon;
  final Color color;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int maxQty;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.unit,
    required this.description,
    required this.icon,
    required this.color,
    required this.rating,
    required this.reviewCount,
    this.inStock = true,
    this.maxQty = 10,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }
}

