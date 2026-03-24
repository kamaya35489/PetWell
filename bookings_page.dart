import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';
import '../widgets/dashboard_shell.dart';

// ═════════════════════════════════════════════════════════════
//  BOOKINGS PAGE — Date strip + time slots + pricing + card form
// ═════════════════════════════════════════════════════════════

// Boarding price tables
const Map<int, int> _brdWeekday = {
  1: 2000,
  2: 2500,
  3: 3000,
  4: 3500,
  5: 4000,
  6: 4500,
  7: 5000,
  8: 5500,
  9: 6000,
  10: 6500,
  11: 7000,
  12: 7500,
  13: 8000,
};
const Map<int, int> _brdSpecial = {
  1: 2500,
  2: 3000,
  3: 3500,
  4: 4000,
  5: 4500,
  6: 5000,
  7: 5500,
  8: 6000,
  9: 6500,
  10: 7000,
};

// Pet sitting price tables (same structure)
const Map<int, int> _psWeekday = {
  1: 2000,
  2: 2500,
  3: 3000,
  4: 3500,
  5: 4000,
  6: 4500,
  7: 5000,
  8: 5500,
  9: 6000,
  10: 6500,
  11: 7000,
  12: 7500,
  13: 8000,
};
const Map<int, int> _psSpecial = {
  1: 2500,
  2: 3000,
  3: 3500,
  4: 4000,
  5: 4500,
  6: 5000,
  7: 5500,
  8: 6000,
  9: 6500,
  10: 7000,
};

// Auto delivery fee for pet sitting (calculated from owner's saved address)
const int _autoDeliveryFee = 300;

// Special days: Wed(3), Sat(6), Sun(0) → 8AM–6PM
bool _isSpecialDay(int dow) => dow == 0 || dow == 3 || dow == 6;

// Generate hourly slot labels for a given day-of-week
List<String> _generateSlots(int dow) {
  final special = _isSpecialDay(dow);
  final startH = special ? 8 : 9;
  final endH = special ? 18 : 22;
  final slots = <String>[];
  for (int h = startH; h < endH; h++) {
    slots.add('${_fmtHour(h)} – ${_fmtHour(h + 1)}');
  }
  return slots;
}

String _fmtHour(int h) {
  final suffix = h >= 12 ? 'PM' : 'AM';
  final display = h > 12 ? h - 12 : (h == 0 ? 12 : h);
  return '$display:00 $suffix';
}

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});
  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  // Service
  String _service = 'grooming'; // grooming | petsitting | boarding

  // Date
  DateTime _selectedDate = DateTime.now();
  final DateTime _today = DateTime.now();

  // Slots
  List<String> _allSlots = [];
  final Set<String> _selectedSlots = {}; // multi-select for boarding/petsitting
  String? _selectedSingleSlot; // single-select for grooming

  // Payment
  String _payMethod = 'card'; // card | cash | bank

  // Card controllers
  final _cardNumCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  bool _done = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _rebuildSlots();
  }

  @override
  void dispose() {
    _cardNumCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _rebuildSlots() {
    _allSlots = _generateSlots(
      _selectedDate.weekday % 7,
    ); // weekday: Mon=1..Sun=7 → %7 gives Sun=0
    _selectedSlots.clear();
    _selectedSingleSlot = null;
  }

  bool get _isSpecial => _isSpecialDay(_selectedDate.weekday % 7);
  int get _dow => _selectedDate.weekday % 7;

  int? _getBrdPrice(int n) => _isSpecial ? _brdSpecial[n] : _brdWeekday[n];
  int? _getPsPrice(int n) => _isSpecial ? _psSpecial[n] : _psWeekday[n];

  int? get _currentBrdPrice => _getBrdPrice(_selectedSlots.length);
  int? get _currentPsPrice => _getPsPrice(_selectedSlots.length);

  String get _hoursLabel {
    if (_isSpecial) {
      final names = {0: 'Sunday', 3: 'Wednesday', 6: 'Saturday'};
      return '${names[_dow]}: 8:00 AM – 6:00 PM';
    }
    return 'Open: 9:00 AM – 10:00 PM';
  }

  void _onSlotTap(String slot) {
    setState(() {
      if (_service == 'grooming') {
        _selectedSingleSlot = slot;
      } else {
        if (_selectedSlots.contains(slot))
          _selectedSlots.remove(slot);
        else
          _selectedSlots.add(slot);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedSlots.length == _allSlots.length)
        _selectedSlots.clear();
      else {
        _selectedSlots.clear();
        _selectedSlots.addAll(_allSlots);
      }
    });
  }

  Future<void> _confirm() async {
    // Validate
    if (_service == 'grooming' && _selectedSingleSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }
    if ((_service == 'boarding' || _service == 'petsitting') &&
        _selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one slot')),
      );
      return;
    }
    if (_payMethod == 'card' &&
        (_cardNumCtrl.text.trim().length < 16 ||
            _expiryCtrl.text.trim().isEmpty ||
            _cvvCtrl.text.trim().length < 3)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid card details')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final db = FirebaseFirestore.instance;
      final paySnap = await db.collection('payments').get();
      final payCount = paySnap.size + 1;
      final paymentID = 'payment${payCount.toString().padLeft(3, '0')}';
      final bookSnap = await db.collection('bookings').get();
      final bookCount = bookSnap.size + 1;
      final bookingID = 'booking${bookCount.toString().padLeft(3, '0')}';

      int amount = 0;
      if (_service == 'grooming')
        amount = 1500;
      else if (_service == 'boarding')
        amount = _currentBrdPrice ?? 0;
      else if (_service == 'petsitting')
        amount = (_currentPsPrice ?? 0) + _autoDeliveryFee;

      await db.collection('payments').doc(paymentID).set({
        'paymentID': paymentID,
        'amount': amount,
        'method': _payMethod,
        'paymentDate': DateTime.now().toIso8601String(),
        'status': 'completed',
      });

      await db.collection('bookings').doc(bookingID).set({
        'bookingID': bookingID,
        'ownerID': uid,
        'service': _service,
        'date': _selectedDate.toIso8601String(),
        'slots': _service == 'grooming'
            ? [_selectedSingleSlot]
            : _selectedSlots.toList(),
        'status': 'confirmed',
        'paymentID': paymentID,
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _buildConfirmation();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pick a service, date & time',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // ── Service Selection ──────────────────────────────────────
          SectionCard(
            title: 'Select Service',
            child: Column(
              children: [
                _serviceOption('grooming', '✂️', 'Grooming'),
                _serviceOption('petsitting', '🐶', 'Pet Sitting'),
                _serviceOption('boarding', '🏠', 'Boarding'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Date & Time ────────────────────────────────────────────
          SectionCard(
            title: 'Select Date & Time',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📅 ${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kNavy,
                      ),
                    ),
                    Row(
                      children: [
                        _monthNavBtn(Icons.chevron_left, () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month - 1,
                              1,
                            );
                            _rebuildSlots();
                          });
                        }),
                        _monthNavBtn(Icons.chevron_right, () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month + 1,
                              1,
                            );
                            _rebuildSlots();
                          });
                        }),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Date strip
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 14,
                    itemBuilder: (ctx, i) {
                      final d = _today.add(Duration(days: i));
                      final isSelected =
                          d.year == _selectedDate.year &&
                          d.month == _selectedDate.month &&
                          d.day == _selectedDate.day;
                      final dow = d.weekday % 7;
                      final slots = _generateSlots(dow);
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedDate = d;
                          _rebuildSlots();
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 52,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? kNavy : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? kNavy : Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                [
                                  'Sun',
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                ][dow],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${d.day}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : kNavy,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  slots.length.clamp(0, 5),
                                  (_) => Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.greenAccent
                                          : kGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Hours badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _isSpecial
                        ? const Color(0xFFFEF3E8)
                        : const Color(0xFFE8F1FB),
                    border: Border.all(
                      color: _isSpecial
                          ? kOrange.withOpacity(0.3)
                          : kSky.withOpacity(0.25),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isSpecial ? '🕗' : '🕐',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _hoursLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isSpecial ? kOrange : kSky,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Slots label
                Text(
                  'Available slots — ${['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][_dow]}, ${_selectedDate.day} ${_monthName(_selectedDate.month)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kNavy,
                  ),
                ),
                const SizedBox(height: 10),

                // Multi-select hint & select all for boarding/petsitting
                if (_service == 'boarding') ...[
                  Container(
                    padding: const EdgeInsets.all(9),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: kPurple.withOpacity(0.07),
                      border: Border.all(color: kPurple.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text('🏠', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Tap slots to select hours. Price updates live. No delivery fee.',
                            style: TextStyle(fontSize: 11, color: kPurple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_service == 'petsitting') ...[
                  Container(
                    padding: const EdgeInsets.all(9),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: kGreen.withOpacity(0.07),
                      border: Border.all(color: kGreen.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text('🐶', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Tap slots to select hours. Delivery fee auto-calculated from your address.',
                            style: TextStyle(fontSize: 11, color: kGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_service != 'grooming') ...[
                  GestureDetector(
                    onTap: _toggleSelectAll,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedSlots.length == _allSlots.length
                              ? (_service == 'boarding' ? kPurple : kGreen)
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        color: _selectedSlots.length == _allSlots.length
                            ? (_service == 'boarding'
                                  ? kPurple.withOpacity(0.05)
                                  : kGreen.withOpacity(0.05))
                            : Colors.white,
                      ),
                      child: Text(
                        _selectedSlots.length == _allSlots.length
                            ? '☑ Deselect all slots'
                            : '☐ Select all ${_allSlots.length} slots',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _selectedSlots.length == _allSlots.length
                              ? (_service == 'boarding' ? kPurple : kGreen)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ],

                // Slot chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allSlots.map((s) {
                    final isSelSingle =
                        _service == 'grooming' && _selectedSingleSlot == s;
                    final isSelMulti =
                        _service != 'grooming' && _selectedSlots.contains(s);
                    Color bgColor = Colors.white;
                    Color borderColor = Colors.grey.shade300;
                    Color textColor = Colors.black87;
                    if (isSelSingle) {
                      bgColor = kNavy;
                      borderColor = kNavy;
                      textColor = Colors.white;
                    } else if (isSelMulti) {
                      bgColor = _service == 'boarding' ? kPurple : kGreen;
                      borderColor = bgColor;
                      textColor = Colors.white;
                    }
                    return GestureDetector(
                      onTap: () => _onSlotTap(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Boarding price bar
                if (_service == 'boarding' && _selectedSlots.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kNavy, kSky]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedSlots.length} slot${_selectedSlots.length > 1 ? 's' : ''} selected',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _currentBrdPrice != null
                                  ? 'Rs. ${_currentBrdPrice!.toLocaleString()}'
                                  : '—',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'No delivery fee',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            if (_selectedSlots.length < _allSlots.length &&
                                _getBrdPrice(_selectedSlots.length + 1) != null)
                              Text(
                                '+1 slot → Rs. ${_getBrdPrice(_selectedSlots.length + 1)!.toLocaleString()}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF4ADE80),
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            else if (_selectedSlots.length == _allSlots.length)
                              const Text(
                                'All slots selected',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF4ADE80),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: kNavy.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Text('✅', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Text(
                          'No delivery fee for boarding',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Pet sitting price bar
                if (_service == 'petsitting' && _selectedSlots.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kGreen, Color(0xFF1a6e3a)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedSlots.length} slot${_selectedSlots.length > 1 ? 's' : ''} selected',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _currentPsPrice != null
                                  ? 'Rs. ${_currentPsPrice!.toLocaleString()}'
                                  : '—',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'excl. delivery fee',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            if (_selectedSlots.length < _allSlots.length &&
                                _getPsPrice(_selectedSlots.length + 1) != null)
                              Text(
                                '+1 slot → Rs. ${_getPsPrice(_selectedSlots.length + 1)!.toLocaleString()}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF4ADE80),
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            else if (_selectedSlots.length == _allSlots.length)
                              const Text(
                                'All slots selected',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF4ADE80),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Auto delivery breakdown
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        // Owner address chip
                        Container(
                          padding: const EdgeInsets.all(9),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: kNavy.withOpacity(0.05),
                            border: Border.all(color: kNavy.withOpacity(0.12)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Text('📍', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your address (auto-detected)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: kNavy,
                                      ),
                                    ),
                                    Text(
                                      '12 Palm St, Colombo 03',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                '3.2 km away',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: kSky,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _breakdownRow(
                          'Pet sitting',
                          _currentPsPrice != null
                              ? 'Rs. ${_currentPsPrice!.toLocaleString()}'
                              : '—',
                        ),
                        _breakdownRow(
                          'Delivery fee (3.2 km)',
                          'Rs. $_autoDeliveryFee',
                          valueColor: kOrange,
                        ),
                        const Divider(height: 18),
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
                            Text(
                              _currentPsPrice != null
                                  ? 'Rs. ${(_currentPsPrice! + _autoDeliveryFee).toLocaleString()}'
                                  : '—',
                              style: const TextStyle(
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
                ],

                // Grooming single slot summary
                if (_service == 'grooming' && _selectedSingleSlot != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: kNavy.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text('🕐', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][_dow]}, ${_selectedDate.day} ${_monthName(_selectedDate.month)} · $_selectedSingleSlot',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: kNavy,
                              ),
                            ),
                            const Text(
                              'Tap another slot to change',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          '✓',
                          style: TextStyle(fontSize: 16, color: kGreen),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Payment Method ─────────────────────────────────────────
          SectionCard(
            title: 'Payment Method',
            child: Column(
              children: [
                // Card
                GestureDetector(
                  onTap: () => setState(() => _payMethod = 'card'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 13,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _payMethod == 'card'
                            ? kSky
                            : Colors.grey.shade200,
                      ),
                      color: _payMethod == 'card'
                          ? kSky.withOpacity(0.05)
                          : Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        _radioWidget(_payMethod == 'card'),
                        const SizedBox(width: 10),
                        const Text('💳', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        const Text(
                          'Credit / Debit Card',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Card details form — appears when card selected
                if (_payMethod == 'card') ...[
                  Container(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                    child: Column(
                      children: [
                        _cardField(
                          label: 'Card Number',
                          ctrl: _cardNumCtrl,
                          kb: TextInputType.number,
                          maxLength: 19,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _cardField(
                                label: 'Expiry MM/YY',
                                ctrl: _expiryCtrl,
                                kb: TextInputType.number,
                                maxLength: 5,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _cardField(
                                label: 'CVV',
                                ctrl: _cvvCtrl,
                                kb: TextInputType.number,
                                maxLength: 3,
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

                // Cash
                _payOption('cash', '💵', 'Cash on Arrival'),
                // Online Banking
                _payOption('bank', '🏦', 'Online Banking', last: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Confirm Button ─────────────────────────────────────────
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
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: _loading ? null : _confirm,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      _payMethod == 'card'
                          ? 'Pay & Confirm →'
                          : 'Confirm Booking →',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceOption(String id, String emoji, String name) {
    final sel = _service == id;
    return GestureDetector(
      onTap: () => setState(() {
        _service = id;
        _selectedSlots.clear();
        _selectedSingleSlot = null;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? kNavy : Colors.grey.shade200,
            width: sel ? 1.8 : 1,
          ),
          color: sel ? kNavy.withOpacity(0.05) : Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (sel)
              const Text('✓', style: TextStyle(color: kNavy, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _payOption(
    String id,
    String emoji,
    String label, {
    bool last = false,
  }) {
    final sel = _payMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _payMethod = id),
      child: Container(
        margin: EdgeInsets.only(bottom: last ? 0 : 7),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? kSky : Colors.grey.shade200),
          color: sel ? kSky.withOpacity(0.05) : Colors.grey.shade50,
        ),
        child: Row(
          children: [
            _radioWidget(sel),
            const SizedBox(width: 10),
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _radioWidget(bool selected) => Container(
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: selected ? kSky : Colors.transparent,
      border: Border.all(
        color: selected ? kSky : Colors.grey.shade400,
        width: 2,
      ),
    ),
    child: selected
        ? const Center(
            child: CircleAvatar(radius: 4, backgroundColor: Colors.white),
          )
        : null,
  );

  Widget _cardField({
    required String label,
    required TextEditingController ctrl,
    required TextInputType kb,
    required int maxLength,
    bool obscure = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: kSky,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        keyboardType: kb,
        obscureText: obscure,
        maxLength: maxLength,
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: kNavy, width: 1.8),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    ],
  );

  Widget _breakdownRow(String label, String value, {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      );

  Widget _monthNavBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(4),
      child: Icon(icon, color: kNavy, size: 18),
    ),
  );
  String _monthName(int m) => [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m];

  Widget _buildConfirmation() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, color: kGreen, size: 72),
          const SizedBox(height: 16),
          const Text(
            'Booking Confirmed!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _service == 'grooming'
                ? 'Grooming at $_selectedSingleSlot'
                : '${_service == 'boarding' ? 'Boarding' : 'Pet Sitting'} · ${_selectedSlots.length} slot${_selectedSlots.length > 1 ? 's' : ''}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Paid via ${_payMethod == 'card'
                ? 'Card'
                : _payMethod == 'cash'
                ? 'Cash'
                : 'Online Banking'}',
            style: const TextStyle(
              fontSize: 13,
              color: kGreen,
              fontWeight: FontWeight.w600,
            ),
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
            onPressed: () => setState(() {
              _done = false;
              _selectedSlots.clear();
              _selectedSingleSlot = null;
              _cardNumCtrl.clear();
              _expiryCtrl.clear();
              _cvvCtrl.clear();
            }),
            child: const Text('Book Another'),
          ),
        ],
      ),
    ),
  );
}

// Extension for number formatting
extension IntFormat on int {
  String toLocaleString() {
    final s = toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
