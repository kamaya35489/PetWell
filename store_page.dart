import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';
import '../widgets/dashboard_shell.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final PageController _pc = PageController(viewportFraction: 0.85);
  int _current = 0;
  final Map<int, int> _cart = {};
  bool _showCart = false;
  String _payMethod = 'Card';
  bool _showCustomOrder = false;

  final _cardNumCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _pc.dispose();
    _cardNumCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  final _products = [
    {
      'name': 'Premium Dog Food',
      'price': 'Rs. 1,000',
      'priceInt': 1000,
      'desc': 'High-protein formula for active dogs',
      'img':
          'https://www.puprise.com/wp-content/uploads/2018/07/Arden-Grange-Premium-Rich-in-Fresh-Chicken-Rice-Dry-Dog-Food.jpg',
      'color': '0xFFE67E22',
    },
    {
      'name': 'Cat Toy Bundle',
      'price': 'Rs. 1,200',
      'priceInt': 1200,
      'desc': 'Feather wand, ball & scratch pad set',
      'img':
          'https://as2.ftcdn.net/v2/jpg/02/16/41/63/1000_F_216416382_bYKaUaal3IHlyaPYKW6AclL6Asbv4yEV.jpg',
      'color': '0xFF8E44AD',
    },
    {
      'name': 'Pet Shampoo',
      'price': 'Rs. 750',
      'priceInt': 750,
      'desc': 'Gentle, vet-approved formula',
      'img':
          'https://media.istockphoto.com/id/1433506264/vector/cosmetic-for-pets-shampoo-and-spray-for-dog-and-puppy-illustration-vector.jpg?s=1024x1024&w=is&k=20&c=fjKtwiBhk5TaJyw-4KYEf5KgC2zMUmyJDW8lqcS_Xek=',
      'color': '0xFF1E7EC8',
    },
    {
      'name': 'Dog Collar & Lead',
      'price': 'Rs. 500',
      'priceInt': 500,
      'desc': 'Adjustable, durable nylon collar',
      'img':
          'https://www.bellsandwhiskers.co.uk/wp-content/uploads/2023/07/OldGreenPuppySet-uai-1032x1032.webp',
      'color': '0xFF27AE60',
    },
    {
      'name': 'Bird Seed Mix',
      'price': 'Rs. 450',
      'priceInt': 450,
      'desc': 'Nutritious blend for all bird breeds',
      'img':
          'https://www.kingsseeds.co.nz/cdn/shop/files/A0018-1_4a89d6de-06ed-4fe0-9339-b52a04a16c37_1440x.jpg?v=1720660802',
      'color': '0xFF0B3B66',
    },
    {
      'name': 'Rabbit Hutch',
      'price': 'Rs. 3,500',
      'priceInt': 3500,
      'desc': 'Spacious wooden indoor/outdoor hutch',
      'img':
          'https://www.qdstores.co.uk/cdn/shop/files/vRHd7b17dc1534d99.jpg?v=1722613367&width=823',
      'color': '0xFFE74C3C',
    },
  ];

  int get _cartTotal => _cart.values.fold(0, (s, v) => s + v);

  void _addToCart(int idx) {
    setState(() => _cart[idx] = (_cart[idx] ?? 0) + 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_products[idx]['name']} added · $_cartTotal item${_cartTotal > 1 ? 's' : ''} in cart',
        ),
        backgroundColor: kNavy,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _changeQty(int idx, int delta) {
    setState(() {
      final v = (_cart[idx] ?? 0) + delta;
      if (v <= 0)
        _cart.remove(idx);
      else
        _cart[idx] = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showCustomOrder)
      return _CustomFoodOrderPage(
        onBack: () => setState(() => _showCustomOrder = false),
      );
    if (_showCart) return _buildCartView();
    return dashBody(
      title: 'Store',
      sub: 'Browse our pet products.',
      content: Column(
        children: [
          if (_cartTotal > 0)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => setState(() => _showCart = true),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kNavy,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_cartTotal item${_cartTotal != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Custom Food Banner
          GestureDetector(
            onTap: () => setState(() => _showCustomOrder = true),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4520D), kOrange],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('🍳', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Custom Food Delivery',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Submit your own recipe + feeding notes',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Rs. 2,500 excl. delivery',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white70,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),

          // Carousel
          SizedBox(
            height: 230,
            child: PageView.builder(
              controller: _pc,
              itemCount: _products.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (ctx, i) {
                final p = _products[i];
                final col = Color(int.parse(p['color'] as String));
                return AnimatedScale(
                  scale: _current == i ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: col.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            p['img'] as String,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [col, col.withOpacity(0.7)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.75),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['name'] as String,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p['desc'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      p['price'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: col,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    onPressed: () => _addToCart(i),
                                    child: const Text('Add to Cart'),
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
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _products.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _current == i ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _current == i ? kNavy : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          SectionCard(
            title: 'All Products',
            child: Column(
              children: [
                ..._products.asMap().entries.map((e) {
                  final p = e.value;
                  final col = Color(int.parse(p['color'] as String));
                  final qty = _cart[e.key] ?? 0;
                  return Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              p['img'] as String,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: col.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: col,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  p['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (qty == 0)
                            GestureDetector(
                              onTap: () => _addToCart(e.key),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: col.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  p['price'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: col,
                                  ),
                                ),
                              ),
                            )
                          else
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _changeQty(e.key, -1),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.remove, size: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _changeQty(e.key, 1),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: kNavy.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 14,
                                      color: kNavy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      // Custom food item in list
                      if (e.key == _products.length - 1) ...[
                        const Divider(height: 16),
                        GestureDetector(
                          onTap: () => setState(() => _showCustomOrder = true),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: kOrange.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    '🍳',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Custom Food Delivery',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: kOrange.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Text(
                                            'CUSTOM',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: kOrange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Your recipe, delivered fresh',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: kOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Rs. 2,500 ›',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: kOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (e.key < _products.length - 1)
                        const Divider(height: 16),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartView() {
    final keys = _cart.keys.toList();
    final subtotal = keys.fold<int>(
      0,
      (s, k) => s + ((_products[k]['priceInt']) as int) * _cart[k]!,
    );
    const delivery = 150;
    final grandTotal = subtotal + delivery;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: kNavy,
                ),
                onPressed: () => setState(() => _showCart = false),
              ),
              const Text(
                'Your Cart',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kNavy,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kNavy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_cartTotal item${_cartTotal != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (keys.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add some products first!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ...keys.map((k) {
              final p = _products[k];
              final col = Color(int.parse(p['color'] as String));
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        p['img'] as String,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 58,
                          height: 58,
                          color: col.withOpacity(0.1),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: col,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            p['price'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _changeQty(k, -1),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.remove, size: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '${_cart[k]}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _changeQty(k, 1),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: kNavy.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: kNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _sumRow('Subtotal', 'Rs. $subtotal'),
                  const SizedBox(height: 8),
                  _sumRow('Delivery', 'Rs. $delivery'),
                  const Divider(height: 18),
                  _sumRow('Total', 'Rs. $grandTotal', bold: true),
                ],
              ),
            ),
            Row(
              children: [
                _payOpt(Icons.credit_card_rounded, 'Card'),
                const SizedBox(width: 10),
                _payOpt(Icons.money_rounded, 'COD'),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onPressed: keys.isEmpty
                    ? null
                    : () async {
                        final uid =
                            FirebaseAuth.instance.currentUser?.uid ?? 'guest';
                        final items = keys
                            .map(
                              (k) => {
                                'name': _products[k]['name'],
                                'qty': _cart[k],
                                'price': _products[k]['priceInt'],
                              },
                            )
                            .toList();
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc()
                            .set({
                              'ownerID': uid,
                              'items': items,
                              'subtotal': subtotal,
                              'deliveryFee': delivery,
                              'total': grandTotal,
                              'paymentMethod': _payMethod,
                              'status': 'Order Placed',
                              'progress': 1,
                              'eta': '~30 min',
                              'createdAt': DateTime.now().toIso8601String(),
                            });
                        setState(() {
                          _cart.clear();
                          _showCart = false;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Order placed! Track it in Delivery.',
                              ),
                              backgroundColor: kGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: Text(
                  _payMethod == 'Card'
                      ? 'Pay with Card →'
                      : 'Confirm COD Order →',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sumRow(String label, String value, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
          color: bold ? kNavy : Colors.grey.shade600,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          color: bold ? kNavy : Colors.black87,
        ),
      ),
    ],
  );

  Widget _payOpt(IconData icon, String label) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _payMethod = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _payMethod == label ? kNavy.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _payMethod == label ? kNavy : Colors.grey.shade200,
            width: _payMethod == label ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: _payMethod == label ? kNavy : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _payMethod == label ? kNavy : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Custom Food Order Page ────────────────────────────────────
class _CustomFoodOrderPage extends StatefulWidget {
  final VoidCallback onBack;
  const _CustomFoodOrderPage({required this.onBack});
  @override
  State<_CustomFoodOrderPage> createState() => _CustomFoodOrderPageState();
}

class _CustomFoodOrderPageState extends State<_CustomFoodOrderPage> {
  final _recipeCtrl = TextEditingController();
  final _servingCtrl = TextEditingController();
  final _feedingCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _addressCtrl = TextEditingController(text: '12 Palm St, Colombo 03');
  final List<String> _uploadedFiles = ['Bruno_chicken_recipe.pdf'];
  bool _done = false;
  String _payMethod = 'Card';

  final _cardNumCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _recipeCtrl,
      _servingCtrl,
      _feedingCtrl,
      _allergiesCtrl,
      _notesCtrl,
      _addressCtrl,
      _cardNumCtrl,
      _cardNameCtrl,
      _expiryCtrl,
      _cvvCtrl,
    ])
      c.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      await FirebaseFirestore.instance
          .collection('customFoodOrders')
          .doc()
          .set({
            'ownerID': uid,
            'recipe': _recipeCtrl.text.trim(),
            'servingStyle': _servingCtrl.text.trim(),
            'feedingMethod': _feedingCtrl.text.trim(),
            'allergies': _allergiesCtrl.text.trim(),
            'additionalNotes': _notesCtrl.text.trim(),
            'address': _addressCtrl.text.trim(),
            'files': _uploadedFiles,
            'price': 2500,
            'deliveryFee': 300,
            'paymentMethod': _payMethod,
            'status': 'pending',
            'createdAt': DateTime.now().toIso8601String(),
          });
    } catch (_) {}
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_done)
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: kGreen, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your custom food order has been placed. Our kitchen will prepare it exactly as you specified.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.onBack,
                child: const Text('Back to Store'),
              ),
            ],
          ),
        ),
      );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: kNavy,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Custom Food Delivery',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kNavy,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kNavy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Rs. 2,500',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SectionCard(
            title: '🍳 Your Recipe',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF8FAFF),
                  ),
                  child: Column(
                    children: [
                      const Text('📎', style: TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap to upload recipe files',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kNavy,
                        ),
                      ),
                      Text(
                        'PDF, Word, images, MP4 videos · Max 50MB',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ..._uploadedFiles.map(
                  (f) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF),
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text('📄', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Uploaded',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          '✓',
                          style: TextStyle(color: kGreen, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Or type your recipe',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kNavy,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _recipeCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Boiled chicken breast (no salt), steamed carrots, brown rice...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFF),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kNavy, width: 1.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SectionCard(
            title: '🐾 Feeding Instructions',
            child: Column(
              children: [
                _instrField(
                  _servingCtrl,
                  'Serving style',
                  'e.g. Flat bowl on the floor, not elevated',
                ),
                _instrField(
                  _feedingCtrl,
                  'Feeding method / preferences',
                  'e.g. Allow 20 min, prefers eating alone',
                  maxLines: 3,
                ),
                _instrField(
                  _allergiesCtrl,
                  'Allergies / dietary restrictions',
                  'e.g. No beef, no dairy, no onions',
                ),
                _instrField(
                  _notesCtrl,
                  'Additional notes',
                  'e.g. Serve warm, not hot',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SectionCard(
            title: '📍 Delivery Address',
            child: Column(
              children: [
                TextField(
                  controller: _addressCtrl,
                  decoration: InputDecoration(
                    hintText: 'Street address',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFF),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kNavy, width: 1.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SectionCard(
            title: '💳 Payment',
            child: Column(
              children: [
                _cartPayOpt('Card', Icons.credit_card_rounded, '💳'),
                if (_payMethod == 'Card') ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
                    child: Column(
                      children: [
                        _cardFieldSimple(
                          'Card Number',
                          _cardNumCtrl,
                          TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        _cardFieldSimple(
                          'Name on Card',
                          _cardNameCtrl,
                          TextInputType.name,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _cardFieldSimple(
                                'Expiry MM/YY',
                                _expiryCtrl,
                                TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _cardFieldSimple(
                                'CVV',
                                _cvvCtrl,
                                TextInputType.number,
                                obscure: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                _cartPayOpt('Cash', Icons.money_rounded, '💵'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Order summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                _sumRowSimple('Custom food preparation', 'Rs. 2,500'),
                _sumRowSimple('Delivery fee', 'Rs. 150'),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kNavy,
                      ),
                    ),
                    const Text(
                      'Rs. 2,650',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: _placeOrder,
              child: Text(
                _payMethod == 'Card' ? 'Pay Rs. 2,650 →' : 'Confirm Order →',
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _instrField(
    TextEditingController ctrl,
    String label,
    String hint, {
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kNavy,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kNavy, width: 1.8),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _cartPayOpt(String id, IconData icon, String emoji) {
    final sel = _payMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _payMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? kSky : Colors.grey.shade200),
          color: sel ? kSky.withOpacity(0.05) : Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? kSky : Colors.transparent,
                border: Border.all(
                  color: sel ? kSky : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: sel
                  ? const Center(
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text(
              id == 'Card' ? 'Credit / Debit Card' : 'Cash on Delivery',
              style: TextStyle(
                fontSize: 13,
                fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardFieldSimple(
    String hint,
    TextEditingController ctrl,
    TextInputType kb, {
    bool obscure = false,
  }) => TextField(
    controller: ctrl,
    keyboardType: kb,
    obscureText: obscure,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kNavy, width: 1.8),
      ),
    ),
    style: const TextStyle(fontSize: 13),
  );

  Widget _sumRowSimple(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
