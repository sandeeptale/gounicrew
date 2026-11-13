import 'package:flutter/material.dart';
import '../models/product_model.dart';

class SampleProducts {
  static const List<ProductModel> list = [
    // ── Vegetables ──────────────────────────────────────────────
    ProductModel(
      id: 'veg_01', name: 'Fresh Tomatoes', category: 'Vegetables',
      price: 29, originalPrice: 45, unit: 'kg',
      description: 'Farm-fresh red tomatoes, perfect for curries, salads and chutneys. Handpicked daily from local farms.',
      icon: Icons.eco_rounded, color: Color(0xFFE53935),
      rating: 4.5, reviewCount: 320,
    ),
    ProductModel(
      id: 'veg_02', name: 'Potatoes', category: 'Vegetables',
      price: 22, unit: 'kg',
      description: 'Premium quality potatoes ideal for frying, boiling and curries. Rich in carbohydrates and vitamins.',
      icon: Icons.grass_rounded, color: Color(0xFFBCAAA4),
      rating: 4.3, reviewCount: 210,
    ),
    ProductModel(
      id: 'veg_03', name: 'Onions', category: 'Vegetables',
      price: 35, originalPrice: 50, unit: 'kg',
      description: 'Fresh red onions with intense flavour. Essential kitchen ingredient for Indian cooking.',
      icon: Icons.spa_rounded, color: Color(0xFF7B1FA2),
      rating: 4.4, reviewCount: 290,
    ),
    ProductModel(
      id: 'veg_04', name: 'Baby Spinach', category: 'Vegetables',
      price: 25, unit: 'bunch',
      description: 'Tender baby spinach leaves, rich in iron & vitamins. Great for salads, dals and smoothies.',
      icon: Icons.eco_rounded, color: Color(0xFF388E3C),
      rating: 4.6, reviewCount: 180,
    ),
    ProductModel(
      id: 'veg_05', name: 'Carrots', category: 'Vegetables',
      price: 32, unit: 'kg',
      description: 'Crunchy, sweet carrots loaded with beta-carotene. Great for halwa, salads and juicing.',
      icon: Icons.eco_rounded, color: Color(0xFFE65100),
      rating: 4.4, reviewCount: 150,
    ),
    ProductModel(
      id: 'veg_06', name: 'Broccoli', category: 'Vegetables',
      price: 59, originalPrice: 79, unit: 'piece',
      description: 'Fresh green broccoli head, packed with nutrients. Ideal for stir-fry and soups.',
      icon: Icons.grass_rounded, color: Color(0xFF2E7D32),
      rating: 4.3, reviewCount: 110,
    ),

    // ── Fruits ──────────────────────────────────────────────────
    ProductModel(
      id: 'frt_01', name: 'Red Apples', category: 'Fruits',
      price: 149, originalPrice: 180, unit: 'kg',
      description: 'Crisp and juicy Shimla apples imported from Himachal Pradesh. Naturally sweet with a tangy twist.',
      icon: Icons.eco_rounded, color: Color(0xFFC62828),
      rating: 4.7, reviewCount: 540,
    ),
    ProductModel(
      id: 'frt_02', name: 'Bananas', category: 'Fruits',
      price: 49, unit: 'dozen',
      description: 'Ripe and sweet Robusta bananas. Excellent source of potassium and instant energy.',
      icon: Icons.eco_rounded, color: Color(0xFFF9A825),
      rating: 4.5, reviewCount: 420,
    ),
    ProductModel(
      id: 'frt_03', name: 'Alphonso Mangoes', category: 'Fruits',
      price: 349, originalPrice: 420, unit: 'dozen',
      description: 'Premium Ratnagiri Alphonso mangoes – the king of mangoes. Sweet, aromatic and pulpy.',
      icon: Icons.eco_rounded, color: Color(0xFFFF8F00),
      rating: 4.9, reviewCount: 870,
    ),
    ProductModel(
      id: 'frt_04', name: 'Oranges', category: 'Fruits',
      price: 89, unit: 'kg',
      description: 'Juicy Nagpur oranges bursting with Vitamin C. Great for juice and direct eating.',
      icon: Icons.eco_rounded, color: Color(0xFFEF6C00),
      rating: 4.4, reviewCount: 290,
    ),
    ProductModel(
      id: 'frt_05', name: 'Black Grapes', category: 'Fruits',
      price: 119, originalPrice: 149, unit: 'kg',
      description: 'Sweet seedless black grapes from Nashik vineyards. Rich in antioxidants.',
      icon: Icons.eco_rounded, color: Color(0xFF4A148C),
      rating: 4.6, reviewCount: 340,
    ),

    // ── Dairy ───────────────────────────────────────────────────
    ProductModel(
      id: 'dai_01', name: 'Full Cream Milk', category: 'Dairy',
      price: 32, unit: 'litre',
      description: 'Fresh full cream cow milk, pasteurized and hygienically packed. Delivered fresh every morning.',
      icon: Icons.local_drink_rounded, color: Color(0xFF0288D1),
      rating: 4.6, reviewCount: 650,
    ),
    ProductModel(
      id: 'dai_02', name: 'Fresh Curd', category: 'Dairy',
      price: 55, unit: 'kg',
      description: 'Thick and creamy homestyle curd made from fresh whole milk. Perfect with rice and parathas.',
      icon: Icons.local_drink_rounded, color: Color(0xFFFFF8E1),
      rating: 4.5, reviewCount: 380,
    ),
    ProductModel(
      id: 'dai_03', name: 'Fresh Paneer', category: 'Dairy',
      price: 89, originalPrice: 109, unit: '200g',
      description: 'Soft and fresh cottage cheese made from full-fat milk. Ideal for curries and tikka.',
      icon: Icons.kitchen_rounded, color: Color(0xFFFFF9C4),
      rating: 4.7, reviewCount: 520,
    ),
    ProductModel(
      id: 'dai_04', name: 'Amul Butter', category: 'Dairy',
      price: 59, unit: '100g pack',
      description: 'India\'s favourite butter – Amul. Creamy, salted butter perfect for bread, parathas and baking.',
      icon: Icons.kitchen_rounded, color: Color(0xFFFFB300),
      rating: 4.8, reviewCount: 910,
    ),
    ProductModel(
      id: 'dai_05', name: 'Processed Cheese', category: 'Dairy',
      price: 115, originalPrice: 135, unit: '200g pack',
      description: 'Creamy processed cheese slices that melt perfectly. Ideal for sandwiches and burgers.',
      icon: Icons.kitchen_rounded, color: Color(0xFFFFF176),
      rating: 4.4, reviewCount: 290,
    ),

    // ── Clothing ─────────────────────────────────────────────────
    ProductModel(
      id: 'clo_01', name: 'Cotton Round-Neck T-Shirt', category: 'Clothing',
      price: 299, originalPrice: 599, unit: 'piece',
      description: 'Comfortable 100% cotton round-neck t-shirt. Available in multiple colours. Breathable and durable.',
      icon: Icons.checkroom_rounded, color: Color(0xFF1565C0),
      rating: 4.3, reviewCount: 760,
    ),
    ProductModel(
      id: 'clo_02', name: 'Slim Fit Jeans', category: 'Clothing',
      price: 799, originalPrice: 1499, unit: 'piece',
      description: 'Premium denim slim fit jeans with stretch comfort fabric. Modern cut for all occasions.',
      icon: Icons.checkroom_rounded, color: Color(0xFF0D47A1),
      rating: 4.4, reviewCount: 430,
    ),
    ProductModel(
      id: 'clo_03', name: 'Summer Floral Dress', category: 'Clothing',
      price: 549, originalPrice: 999, unit: 'piece',
      description: 'Light and breezy floral print dress. Perfect for summer outings and casual events.',
      icon: Icons.checkroom_rounded, color: Color(0xFFAD1457),
      rating: 4.5, reviewCount: 310,
    ),
    ProductModel(
      id: 'clo_04', name: 'Hoodie Jacket', category: 'Clothing',
      price: 699, originalPrice: 1199, unit: 'piece',
      description: 'Warm fleece-lined hoodie jacket. Perfect for evenings and winters.',
      icon: Icons.checkroom_rounded, color: Color(0xFF37474F),
      rating: 4.6, reviewCount: 520,
    ),

    // ── Snacks ──────────────────────────────────────────────────
    ProductModel(
      id: 'snk_01', name: 'Lay\'s Classic Chips', category: 'Snacks',
      price: 20, unit: 'pack',
      description: 'America\'s favourite potato chips. Light, crispy and perfectly salted.',
      icon: Icons.fastfood_rounded, color: Color(0xFFFFB300),
      rating: 4.4, reviewCount: 980,
    ),
    ProductModel(
      id: 'snk_02', name: 'Parle-G Biscuits', category: 'Snacks',
      price: 10, unit: 'pack',
      description: 'India\'s most beloved biscuit. Classic glucose biscuit loved across all age groups.',
      icon: Icons.fastfood_rounded, color: Color(0xFFE65100),
      rating: 4.7, reviewCount: 2100,
    ),
    ProductModel(
      id: 'snk_03', name: 'Dairy Milk Chocolate', category: 'Snacks',
      price: 60, originalPrice: 75, unit: 'piece',
      description: 'Rich, smooth Cadbury Dairy Milk chocolate. A classic treat for every mood.',
      icon: Icons.fastfood_rounded, color: Color(0xFF4E342E),
      rating: 4.8, reviewCount: 1450,
    ),
    ProductModel(
      id: 'snk_04', name: 'Haldiram\'s Namkeen Mix', category: 'Snacks',
      price: 65, unit: '200g pack',
      description: 'Spicy and crunchy namkeen mix by Haldiram\'s. Perfect evening snack.',
      icon: Icons.fastfood_rounded, color: Color(0xFFF57F17),
      rating: 4.5, reviewCount: 760,
    ),
    ProductModel(
      id: 'snk_05', name: 'Act II Popcorn', category: 'Snacks',
      price: 30, unit: 'pack',
      description: 'Movie-time butter popcorn. Light, fluffy and perfectly buttered.',
      icon: Icons.fastfood_rounded, color: Color(0xFFFFCC02),
      rating: 4.3, reviewCount: 390,
    ),
  ];

  static const List<String> categories = [
    'All', 'Vegetables', 'Fruits', 'Dairy', 'Clothing', 'Snacks',
  ];
}

