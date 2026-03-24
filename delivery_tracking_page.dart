import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';
import '../widgets/dashboard_shell.dart';

class DeliveryTrackingPage extends StatelessWidget {
  const DeliveryTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return dashBody(
      title: 'My Deliveries',
      sub: 'Track your orders in real-time.',
      content: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('ownerID', isEqualTo: uid)
            .snapshots(),
        builder: (ctx, regularSnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('customFoodOrders')
                .where('ownerID', isEqualTo: uid)
                .snapshots(),
            builder: (ctx, customSnap) {
              if (regularSnap.connectionState == ConnectionState.waiting ||
                  customSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final regularOrders = (regularSnap.data?.docs ?? [])
                ..sort((a, b) {
                  final aTime = (a.data() as Map)['createdAt'] as String? ?? '';
                  final bTime = (b.data() as Map)['createdAt'] as String? ?? '';
                  return bTime.compareTo(aTime);
                });
              final customOrders = (customSnap.data?.docs ?? [])
                ..sort((a, b) {
                  final aTime = (a.data() as Map)['createdAt'] as String? ?? '';
                  final bTime = (b.data() as Map)['createdAt'] as String? ?? '';
                  return bTime.compareTo(aTime);
                });
              final totalCount = regularOrders.length + customOrders.length;

              if (totalCount == 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 72,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: kNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Visit the Store to place your first order!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Build stat counts
              int inTransit = 0, delivered = 0, preparing = 0;
              for (final doc in regularOrders) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] as String? ?? '';
                if (status == 'On the Way')
                  inTransit++;
                else if (status == 'Delivered')
                  delivered++;
                else
                  preparing++;
              }
              for (final doc in customOrders) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] as String? ?? '';
                if (status == 'on the way')
                  inTransit++;
                else if (status == 'delivered')
                  delivered++;
                else
                  preparing++;
              }

              return Column(
                children: [
                  // Stats row
                  Row(
                    children: [
                      StatCard(
                        number: '$inTransit',
                        label: 'In Transit',
                        color: kOrange,
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        number: '$delivered',
                        label: 'Delivered',
                        color: kGreen,
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        number: '$preparing',
                        label: 'Preparing',
                        color: kSky,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Custom food orders
                  ...customOrders.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _CustomOrderCard(docId: doc.id, data: data);
                  }),

                  // Regular orders
                  ...regularOrders.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _RegularOrderCard(docId: doc.id, data: data);
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Custom Order Card (Firestore-driven) ──────────────────────
class _CustomOrderCard extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  const _CustomOrderCard({required this.docId, required this.data});
  @override
  State<_CustomOrderCard> createState() => _CustomOrderCardState();
}

class _CustomOrderCardState extends State<_CustomOrderCard> {
  bool _expanded = false;

  Color _statusColor(String status) {
    if (status == 'delivered') return kGreen;
    if (status == 'on the way') return kOrange;
    return kSky;
  }

  String _statusLabel(String status) {
    if (status == 'delivered') return 'Delivered';
    if (status == 'on the way') return 'On the Way';
    return 'Preparing';
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final status = (data['status'] as String? ?? 'pending').toLowerCase();
    final total =
        ((data['price'] ?? 0) as num) + ((data['deliveryFee'] ?? 0) as num);
    final files = List<String>.from(data['files'] ?? []);
    final allergies = data['allergies'] as String? ?? '';
    final feedingMethod = data['feedingMethod'] as String? ?? '';
    final recipe = data['recipe'] as String? ?? '';
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOrange.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('🍳', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Custom Food Delivery',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: kOrange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
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
                      'Rs. $total',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (files.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: files
                  .map(
                    (f) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F6FF),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '📄 $f',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: kSky,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: kSky.withOpacity(0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text('⏱', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                const Text(
                  'ETA: ~45–60 min (fresh preparation)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kSky,
                  ),
                ),
              ],
            ),
          ),
          if (recipe.isNotEmpty ||
              feedingMethod.isNotEmpty ||
              allergies.isNotEmpty) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: kNavy.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _expanded
                      ? '🐾 Hide feeding instructions ▴'
                      : '🐾 View feeding instructions ▾',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kNavy,
                  ),
                ),
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipe.isNotEmpty) _infoRow('📋', 'Recipe', recipe),
                    if (feedingMethod.isNotEmpty)
                      _infoRow('🥣', 'Feeding', feedingMethod),
                    if (allergies.isNotEmpty)
                      _infoRow('🚫', 'Allergies', allergies),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: kNavy,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),
      ],
    ),
  );
}

// ─── Regular Order Card (Firestore-driven) ──────────────────────
class _RegularOrderCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const _RegularOrderCard({required this.docId, required this.data});

  Color get _statusColor {
    final status = data['status'] as String? ?? '';
    if (status == 'Delivered') return kGreen;
    if (status == 'On the Way') return kOrange;
    return kSky;
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(
      (data['items'] as List? ?? []).map(
        (e) => Map<String, dynamic>.from(e as Map),
      ),
    );
    final status = data['status'] as String? ?? 'Order Placed';
    final eta = data['eta'] as String? ?? '~30 min';
    final progress = (data['progress'] as num? ?? 1).toInt();
    final total = data['total'] ?? data['subtotal'] ?? 0;
    final agent = data['agent'] as String?;
    final agentPhone = data['agentPhone'] as String?;
    final steps = ['Order Placed', 'Out for Delivery', 'Delivered'];
    final statusColor = _statusColor;

    final productSummary = items
        .map((i) {
          final qty = i['qty'] ?? 1;
          return qty > 1 ? '${i['name']} x$qty' : '${i['name']}';
        })
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  productSummary,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Rs. $total',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(steps.length, (i) {
              final done = i < progress;
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done ? statusColor : Colors.grey.shade200,
                          ),
                          child: Center(
                            child: done
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: i == progress - 1
                                          ? kNavy
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[i],
                          style: TextStyle(
                            fontSize: 9,
                            color: done ? statusColor : Colors.grey.shade400,
                            fontWeight: done
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          color: i < progress - 1
                              ? statusColor
                              : Colors.grey.shade200,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  'ETA: $eta',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (status != 'Delivered' && agent != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: kNavy.withOpacity(0.1),
                  child: const Icon(
                    Icons.person_rounded,
                    color: kNavy,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Delivery Agent',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (agentPhone != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kNavy.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_rounded, size: 14, color: kNavy),
                        const SizedBox(width: 5),
                        Text(
                          agentPhone,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Legacy DeliveryCard (kept for compatibility) ───────────────
class _DeliveryCard extends StatelessWidget {
  final Map<String, String> order;
  const _DeliveryCard({required this.order});
  Color get _statusColor => order['status'] == 'Delivered'
      ? kGreen
      : order['status'] == 'On the Way'
      ? kOrange
      : kSky;
  @override
  Widget build(BuildContext context) {
    final progress = int.parse(order['progress']!);
    final steps = ['Order Placed', 'Out for Delivery', 'Delivered'];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order['product']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['status']!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Order ID: ${order['id']}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(steps.length, (i) {
              final done = i < progress;
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done ? _statusColor : Colors.grey.shade200,
                          ),
                          child: Center(
                            child: done
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: i == progress - 1
                                          ? kNavy
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[i],
                          style: TextStyle(
                            fontSize: 9,
                            color: done ? _statusColor : Colors.grey.shade400,
                            fontWeight: done
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          color: i < progress - 1
                              ? _statusColor
                              : Colors.grey.shade200,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: _statusColor),
                const SizedBox(width: 6),
                Text(
                  'ETA: ${order['eta']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (order['status'] != 'Delivered') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: kNavy.withOpacity(0.1),
                  child: const Icon(
                    Icons.person_rounded,
                    color: kNavy,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['agent']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Delivery Agent',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: kNavy,
                    backgroundColor: kNavy.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.phone_rounded, size: 15),
                  label: Text(
                    order['agentPhone']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
