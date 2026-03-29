import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';
import '../models/user_profile.dart';

class ProfilePage extends StatefulWidget {
  final UserProfile profile;
  const ProfilePage({super.key, required this.profile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameCtrl, _contactCtrl, _emailCtrl;
  bool _editing = false;

  // ── Real stats from Firestore ──
  int _petCount      = 0;
  int _bookingCount  = 0;
  int _deliveryCount = 0;
  bool _statsLoading = true;

  final List<String> _avatarOptions = [
    '🧑', '🧑‍💼', '👩', '👨',
    '🧑‍🦰', '👩‍🦱', '👨‍🦳', '🧑‍🦲',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl    = TextEditingController(text: widget.profile.name);
    _contactCtrl = TextEditingController(text: widget.profile.contact);
    _emailCtrl   = TextEditingController(text: widget.profile.email);
    _loadStats();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Fetch real stats from Firestore ──────────────────────────────────────
  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _statsLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      if (mounted) setState(() => _statsLoading = false);
      return;
    }

    try {
      final isAgent = widget.profile.role == 'Delivery Agent';

      if (isAgent) {
        // Agents: only count completed deliveries
        final deliverySnap = await FirebaseFirestore.instance
            .collection('orders')
            .where('agentID', isEqualTo: uid)
            .where('status', isEqualTo: 'Delivered')
            .get();

        if (mounted) {
          setState(() {
            _deliveryCount = deliverySnap.size;
            _statsLoading  = false;
          });
        }
      } else {
        // Pet owners: count pets and bookings separately
        final petsSnap = await FirebaseFirestore.instance
            .collection('pets')
            .where('ownerID', isEqualTo: uid)
            .get();

        final bookingSnap = await FirebaseFirestore.instance
            .collection('bookings')
            .where('ownerID', isEqualTo: uid)
            .get();

        if (mounted) {
          setState(() {
            _petCount     = petsSnap.size;
            _bookingCount = bookingSnap.size;
            _statsLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Profile stats error: $e');
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  // ── Save profile ──────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'userName': _nameCtrl.text.trim(),
      'phone':    _contactCtrl.text.trim(),
      'email':    _emailCtrl.text.trim(),
    });
    setState(() {
      widget.profile.name    = _nameCtrl.text.trim();
      widget.profile.contact = _contactCtrl.text.trim();
      widget.profile.email   = _emailCtrl.text.trim();
      _editing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: kGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Avatar picker ─────────────────────────────────────────────────────────
  void _changeAvatar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('Choose Profile Picture',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kNavy)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16, runSpacing: 16,
              children: _avatarOptions.map((e) => GestureDetector(
                onTap: () { setState(() => widget.profile.avatarEmoji = e); Navigator.pop(context); },
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: widget.profile.avatarEmoji == e ? kNavy.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: widget.profile.avatarEmoji == e ? kNavy : Colors.transparent, width: 2),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 30))),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final isAgent = p.role == 'Delivery Agent';

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => _editing ? _saveProfile() : setState(() => _editing = true),
            child: Text(_editing ? 'Save' : 'Edit',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          if (_editing)
            TextButton(
              onPressed: () {
                setState(() {
                  _nameCtrl.text    = p.name;
                  _contactCtrl.text = p.contact;
                  _emailCtrl.text   = p.email;
                  _editing = false;
                });
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ── Avatar ──
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: kNavy.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: kNavy.withOpacity(0.2), width: 3),
                        ),
                        child: Center(child: Text(p.avatarEmoji ?? '🧑', style: const TextStyle(fontSize: 52))),
                      ),
                      Positioned(
                        right: 0, bottom: 0,
                        child: GestureDetector(
                          onTap: _changeAvatar,
                          child: Container(
                            width: 32, height: 32,
                            decoration: const BoxDecoration(color: kSky, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kNavy)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: kSky.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(p.role, style: const TextStyle(fontSize: 12, color: kSky, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Personal Information ──
            _profileCard(
              title: 'Personal Information',
              icon: Icons.person_rounded,
              child: Column(children: [
                _profileField(label: 'Full Name', ctrl: _nameCtrl,    icon: Icons.badge_outlined,         editing: _editing),
                _profileField(label: 'Contact',   ctrl: _contactCtrl, icon: Icons.phone_outlined,         editing: _editing, kb: TextInputType.phone),
                _profileField(label: 'Email',     ctrl: _emailCtrl,   icon: Icons.email_outlined,         editing: _editing, kb: TextInputType.emailAddress, isLast: true),
              ]),
            ),

            const SizedBox(height: 16),

            // ── My Pets ──
            if (p.pets.isNotEmpty) ...[
              _profileCard(
                title: 'My Pets (${p.pets.length})',
                icon: Icons.pets,
                child: Column(
                  children: p.pets.asMap().entries.map((e) {
                    final pet = e.value;
                    return Column(children: [
                      Row(children: [
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(color: kNavy.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(pet['emoji']!, style: const TextStyle(fontSize: 24))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(pet['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                          Text('${pet['type']} · ${pet['breed']} · ${pet['age']} yrs', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: kSky.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(pet['type']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kSky)),
                        ),
                      ]),
                      if (e.key < p.pets.length - 1) const Divider(height: 18),
                    ]);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Account Stats ──
            _profileCard(
              title: 'Account Stats',
              icon: Icons.bar_chart_rounded,
              child: _statsLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(color: kTeal, strokeWidth: 2),
                      ),
                    )
                  : isAgent
                      ? Center(child: _miniStat('$_deliveryCount', 'Deliveries Completed', kSky))
                      : Row(children: [
                          _miniStat('$_petCount',     'Pets',     kNavy),
                          _vDivider(),
                          _miniStat('$_bookingCount', 'Bookings', kSky),
                        ]),
            ),

            const SizedBox(height: 12),

            // ── Refresh Stats button ──
            GestureDetector(
              onTap: _loadStats,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: kSky.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kSky.withOpacity(0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.refresh_rounded, size: 14, color: kSky),
                  const SizedBox(width: 6),
                  Text('Refresh Stats', style: TextStyle(fontSize: 12, color: kSky, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),

            const SizedBox(height: 20),

            // ── Logout ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper widgets ────────────────────────────────────────────────────────

  Widget _profileCard({required String title, required IconData icon, required Widget child}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: kNavy.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: kNavy, size: 16)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kNavy)),
          ]),
          const SizedBox(height: 14),
          child,
        ]),
      );

  Widget _profileField({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
    required bool editing,
    TextInputType kb = TextInputType.text,
    bool isLast = false,
  }) =>
      Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
        child: editing
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kNavy)),
                const SizedBox(height: 5),
                TextField(
                  controller: ctrl, keyboardType: kb,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 18),
                    filled: true, fillColor: const Color(0xFFF8FAFF),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kNavy, width: 1.8)),
                  ),
                ),
              ])
            : Row(children: [
                Icon(icon, size: 16, color: kSky),
                const SizedBox(width: 10),
                Text('$label: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kNavy)),
                Expanded(child: Text(ctrl.text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
              ]),
      );

  Widget _miniStat(String val, String lbl, Color col) => Expanded(
    child: Column(children: [
      Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: col)),
      const SizedBox(height: 4),
      Text(lbl, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
    ]),
  );

  Widget _vDivider() => Container(width: 1, height: 40, color: Colors.grey.shade200);
}
