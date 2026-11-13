import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../cart/presentation/screens/cart_view_screen.dart';
import '../../../payment/presentation/cubit/payment_cubit.dart';
import '../../../payment/presentation/screens/payment_history_screen.dart';
import '../../data/datasources/sample_products.dart';
import '../../data/models/product_model.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  String _category = 'All';
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthCubit>().currentUser;
      context.read<PaymentCubit>().loadPaymentHistory(
        filter: 'all',
        userId: user?.id,
      );
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ProductModel> get _products {
    return SampleProducts.list.where((p) {
      final catOk =
          _category == 'All' || p.category == _category;
      final searchOk = _search.isEmpty ||
          p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.category.toLowerCase().contains(_search.toLowerCase());
      return catOk && searchOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _tabIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_tabIndex != 0) {
          setState(() => _tabIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: IndexedStack(
          index: _tabIndex,
          children: [
            _buildShopTab(),
            const CartViewScreen(),
            const PaymentHistoryScreen(),
            _buildProfileTab(),
          ],
        ),
        bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
          builder: (context, cart) {
            return NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (i) => setState(() => _tabIndex = i),
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.12),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon:
                      Icon(Icons.storefront_rounded, color: AppTheme.primaryColor),
                  label: 'Shop',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: cart.totalItemCount > 0,
                    label: Text('${cart.totalItemCount}'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: cart.totalItemCount > 0,
                    label: Text('${cart.totalItemCount}'),
                    child: const Icon(Icons.shopping_cart_rounded,
                        color: AppTheme.primaryColor),
                  ),
                  label: 'Cart',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded,
                      color: AppTheme.primaryColor),
                  label: 'Orders',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon:
                      Icon(Icons.person_rounded, color: AppTheme.primaryColor),
                  label: 'Profile',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Shop Tab ─────────────────────────────────────────────────────────────

  Widget _buildShopTab() {
    final products = _products;

    return SafeArea(
      child: Column(
        children: [
          // ── Fixed header ──────────────────────────────────────
          _buildHeader(),

          // ── Category chips ────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: SampleProducts.categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = SampleProducts.categories[i];
                final selected = cat == _category;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (v) {
                    if (v) setState(() => _category = cat);
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : AppTheme.textPrimaryColor,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected
                        ? AppTheme.primaryColor
                        : AppTheme.borderColor,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Section label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  _category == 'All' ? 'All Products' : _category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${products.length})',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Scrollable product grid ───────────────────────────
          Expanded(
            child: products.isEmpty
                ? _buildEmptySearch()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.70,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) =>
                        _buildProductCard(products[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    AppTheme.primaryColor.withValues(alpha: 0.12),
                child: const Icon(Icons.person,
                    color: AppTheme.primaryColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (_, state) {
                    final name = state is Authenticated
                        ? state.user.name
                        : 'Guest';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, $name 👋',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimaryColor)),
                        const Text('What would you like to buy today?',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondaryColor)),
                      ],
                    );
                  },
                ),
              ),
              BlocBuilder<CartCubit, CartState>(
                builder: (_, cart) => IconButton(
                  icon: Badge(
                    isLabelVisible: cart.totalItemCount > 0,
                    label: Text('${cart.totalItemCount}'),
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CartViewScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Search bar
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search vegetables, fruits, dairy...',
              prefixIcon: const Icon(Icons.search,
                  color: AppTheme.textSecondaryColor, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppTheme.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel p) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: p)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product icon area
            Container(
              height: 115,
              width: double.infinity,
              decoration: BoxDecoration(
                color: p.color.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(p.icon, size: 56, color: p.color),
                  ),
                  if (p.hasDiscount)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${p.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'per ${p.unit}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondaryColor),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatCurrency(p.price),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          if (p.hasDiscount)
                            Text(
                              formatCurrency(p.originalPrice!),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondaryColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      BlocBuilder<CartCubit, CartState>(
                        builder: (context, cart) {
                          final qty = cart.getProductQuantity(p.id);
                          if (qty == 0) {
                            return GestureDetector(
                              onTap: () {
                                context.read<CartCubit>().addItem(
                                      productId: p.id,
                                      name: p.name,
                                      price: p.price,
                                      unit: p.unit,
                                      icon: p.icon,
                                      iconColor: p.color,
                                    );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppTheme.primaryColor,
                                      width: 1.5),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ADD',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primaryColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(Icons.add,
                                        size: 14,
                                        color: AppTheme.primaryColor),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => context
                                      .read<CartCubit>()
                                      .decrementProduct(p.id),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 5),
                                    child: Icon(Icons.remove,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context
                                      .read<CartCubit>()
                                      .addItem(
                                        productId: p.id,
                                        name: p.name,
                                        price: p.price,
                                        unit: p.unit,
                                        icon: p.icon,
                                        iconColor: p.color,
                                      ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 5),
                                    child: Icon(Icons.add,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 60, color: AppTheme.borderColor),
          const SizedBox(height: 12),
          Text('No results for "$_search"',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 8),
          const Text('Try a different keyword or category',
              style:
                  TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor)),
        ],
      ),
    );
  }

  // ── Profile Tab ──────────────────────────────────────────────────────────

  Widget _buildProfileTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user =
                  state is Authenticated ? state.user : null;
              return Column(
                children: [
                  // User avatar card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E3A5F),
                          Color(0xFF2C5282),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            user != null && user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'G',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Guest User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                user?.email ?? 'guest@example.com',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                              if (user?.phone != null &&
                                  user!.phone.isNotEmpty)
                                Text(
                                  user.phone,
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Options
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.receipt_long_outlined,
                              color: AppTheme.primaryColor),
                          title: const Text('Order History',
                              style:
                                  TextStyle(fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    const PaymentHistoryScreen()),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.shopping_cart_outlined,
                              color: AppTheme.primaryColor),
                          title: const Text('My Cart',
                              style:
                                  TextStyle(fontWeight: FontWeight.w600)),
                          trailing: BlocBuilder<CartCubit, CartState>(
                            builder: (_, cart) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (cart.totalItemCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${cart.totalItemCount} items',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CartViewScreen()),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout,
                              color: AppTheme.errorColor),
                          title: const Text('Logout',
                              style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.w600)),
                          onTap: () {
                            context.read<CartCubit>().clearCart();
                            context.read<AuthCubit>().logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

