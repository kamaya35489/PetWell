import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';
import '../widgets/dashboard_shell.dart';

class _Review {
  final String name, comment;
  final int stars;
  const _Review(this.name, this.stars, this.comment);
}

// ═════════════════════════════════════════════════════════════
//  DELIVERY AGENT – PENDING DELIVERIES
// ═════════════════════════════════════════════════════════════
class _PendingDelivery {
  final String id, product, ownerName, contact, address, distance;
  bool accepted, declined;
  bool isCustomFood;
  _PendingDelivery({
    required this.id,
    required this.product,
    required this.ownerName,
    required this.contact,
    required this.address,
    required this.distance,
    this.accepted = false,
    this.declined = false,
    this.isCustomFood = false,
  });
}

// ═════════════════════════════════════════════════════════════
//  DELIVERY AGENT – HOME PAGE
// ═════════════════════════════════════════════════════════════
class DeliveryHomePage extends StatefulWidget {
  const DeliveryHomePage({super.key});
  @override
  State<DeliveryHomePage> createState() => _DeliveryHomePageState();
}

class _DeliveryHomePageState extends State<DeliveryHomePage> {
  final List<_PendingDelivery> _pending = [
    _PendingDelivery(
      id: 'D-5549',
      product: 'Custom Food Delivery',
      ownerName: 'Kamal Perera',
      contact: '0771234567',
      address: '12 Palm St, Colombo 03',
      distance: '3.2 km',
      isCustomFood: true,
    ),
    _PendingDelivery(
      id: 'D-5545',
      product: 'Premium Dog Food',
      ownerName: 'Kamal Perera',
      contact: '0771234567',
      address: '12 Palm St, Colombo 03',
      distance: '2.4 km',
    ),
    _PendingDelivery(
      id: 'D-5546',
      product: 'Cat Toy Bundle',
      ownerName: 'Nirosha Silva',
      contact: '0779876543',
      address: '5 Lake Rd, Kandy',
      distance: '5.1 km',
    ),
    _PendingDelivery(
      id: 'D-5547',
      product: 'Pet Shampoo',
      ownerName: 'Amal Fernando',
      contact: '0712223344',
      address: '88 Galle Rd, Colombo 06',
      distance: '3.7 km',
    ),
  ];
  int get _pendingCount =>
      _pending.where((d) => !d.accepted && !d.declined).length;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: kNavy,
                    ),
                  ),
                  Text(
                    'Manage your incoming deliveries',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kNavy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: kNavy,
                    size: 24,
                  ),
                ),
                if (_pendingCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: kOrange,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$_pendingCount',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_pendingCount > 0)
          GestureDetector(
            onTap: () => _showDeliveryList(context),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kNavy, kSky],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kNavy.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_pendingCount New Deliver${_pendingCount == 1 ? 'y' : 'ies'} Found!',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Tap to view & accept',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white54,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        Row(
          children: [
            StatCard(
              number: '$_pendingCount',
              label: 'Pending',
              color: kOrange,
            ),
            const SizedBox(width: 12),
            StatCard(
              number: '${_pending.where((d) => d.accepted).length}',
              label: 'Accepted',
              color: kGreen,
            ),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Delivery Requests',
          child: _pending.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inbox_rounded,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No pending deliveries',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: _pending.asMap().entries.map((e) {
                    final d = e.value;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: d.accepted
                                    ? kGreen.withOpacity(0.1)
                                    : d.declined
                                    ? Colors.grey.shade100
                                    : (d.isCustomFood
                                          ? kOrange.withOpacity(0.12)
                                          : kSky.withOpacity(0.1)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  d.accepted
                                      ? '✅'
                                      : d.declined
                                      ? '❌'
                                      : (d.isCustomFood ? '🍳' : '📦'),
                                  style: const TextStyle(fontSize: 20),
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
                                      Text(
                                        d.product,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: d.declined
                                              ? Colors.grey
                                              : Colors.black87,
                                        ),
                                      ),
                                      if (d.isCustomFood) ...[
                                        const SizedBox(width: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: kOrange.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              8,
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
                                    ],
                                  ),
                                  Text(
                                    '${d.ownerName} · ${d.distance}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!d.accepted && !d.declined)
                              TextButton(
                                onPressed: () => _showDeliveryList(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: kNavy,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                child: const Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: d.accepted
                                      ? kGreen.withOpacity(0.1)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  d.accepted ? 'Accepted' : 'Declined',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: d.accepted ? kGreen : Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (e.key < _pending.length - 1)
                          const Divider(height: 16),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    ),
  );

  void _showDeliveryList(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _DeliveryListPage(
        deliveries: _pending,
        onUpdate: () => setState(() {}),
      ),
    ),
  );
}

class _DeliveryListPage extends StatefulWidget {
  final List<_PendingDelivery> deliveries;
  final VoidCallback onUpdate;
  const _DeliveryListPage({required this.deliveries, required this.onUpdate});
  @override
  State<_DeliveryListPage> createState() => _DeliveryListPageState();
}

class _DeliveryListPageState extends State<_DeliveryListPage> {
  void _accept(_PendingDelivery d) {
    setState(() {
      d.accepted = true;
      d.declined = false;
    });
    widget.onUpdate();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted: ${d.product}'),
        backgroundColor: kGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _decline(_PendingDelivery d) {
    setState(() {
      d.declined = true;
      d.accepted = false;
    });
    widget.onUpdate();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Declined: ${d.product}'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(
      backgroundColor: kNavy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Delivery Requests',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.deliveries.where((d) => !d.accepted && !d.declined).length} pending',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.deliveries.length,
      itemBuilder: (ctx, i) {
        final d = widget.deliveries[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
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
            border: d.isCustomFood
                ? Border.all(color: kOrange.withOpacity(0.35), width: 1.5)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: d.isCustomFood
                            ? kOrange.withOpacity(0.1)
                            : kSky.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        d.isCustomFood ? '🍳' : '📦',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                d.product,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              if (d.isCustomFood) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kOrange.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
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
                            ],
                          ),
                          Text(
                            'Order ${d.id}',
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
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        d.distance,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _infoRow(Icons.person_rounded, 'Owner', d.ownerName),
                const SizedBox(height: 8),
                _infoRow(Icons.phone_rounded, 'Contact', d.contact),
                const SizedBox(height: 8),
                _infoRow(Icons.location_on_rounded, 'Address', d.address),
                // Custom food feeding notes
                if (d.isCustomFood) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kOrange.withOpacity(0.05),
                      border: Border.all(color: kOrange.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🐾 Feeding instructions',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kOrange,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '🥣 Serving: Flat ceramic bowl on floor',
                          style: TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                        const Text(
                          '🌡 Temp: Warm, not hot',
                          style: TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                        const Text(
                          '🚫 Allergies: No beef, dairy, onions',
                          style: TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: ['📄 Recipe PDF', '🎬 Cooking video']
                        .map(
                          (f) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F6FF),
                              border: Border.all(
                                color: const Color(0xFFDBEAFE),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              f,
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
                const SizedBox(height: 16),
                if (!d.accepted && !d.declined)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _decline(d),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text(
                            'Decline',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _accept(d),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text(
                            'Accept',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: d.accepted
                          ? kGreen.withOpacity(0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          d.accepted
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: d.accepted ? kGreen : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          d.accepted
                              ? 'Delivery Accepted'
                              : 'Delivery Declined',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: d.accepted ? kGreen : Colors.grey,
                          ),
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
  );

  Widget _infoRow(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: kSky),
      const SizedBox(width: 8),
      Text(
        '$label: ',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: kNavy,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ),
    ],
  );
}
