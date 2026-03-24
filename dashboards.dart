import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';
import '../models/user_profile.dart';
import '../widgets/dashboard_shell.dart';
import 'owner_home_page.dart';
import 'pet_profiles_page.dart';
import 'bookings_page.dart';
import 'delivery_tracking_page.dart';
import 'owner_feedback_page.dart';
import 'store_page.dart';
import 'cctv_page.dart';
import 'delivery_home_page.dart';
import 'delivery_earnings_page.dart';
import 'feedback_page.dart';

// ═════════════════════════════════════════════════════════════
//  OWNER DASHBOARD
// ═════════════════════════════════════════════════════════════
class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});
  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  static const _nav = [
    NavItem(Icons.dashboard_rounded, 'Dashboard', Color(0xFF0B3B66)),
    NavItem(Icons.pets, 'Pets', Color(0xFFE67E22)),
    NavItem(Icons.calendar_month, 'Bookings', Color(0xFF1E7EC8)),
    NavItem(Icons.local_shipping, 'Delivery', Color(0xFF8E44AD)),
    NavItem(Icons.chat_bubble_outline, 'Feedback', Color(0xFF27AE60)),
    NavItem(Icons.store_rounded, 'Store', Color(0xFFE74C3C)),
    NavItem(Icons.videocam_rounded, 'CCTV', Color(0xFF00838F)),
    NavItem(Icons.settings, 'Settings', Color(0xFF546E7A)),
  ];

  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data()!;
    setState(() {
      _profile = UserProfile(
        name: data['userName'] ?? '',
        contact: data['phone'] ?? '',
        email: data['email'] ?? '',
        role: 'Pet Owner',
        avatarEmoji: '🧑',
        pets: [],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return DashboardShell(
      appBarTitle: 'Owner Dashboard',
      navItems: _nav,
      bottomNavCount: 6,
      profile: _profile!,
      pages: [
        OwnerHomePage(userName: _profile!.name),
        const PetProfilesPage(),
        const BookingsPage(),
        const DeliveryTrackingPage(),
        const OwnerFeedbackPage(),
        const StorePage(),
        const CctvPage(),
        placeholder('⚙️', 'Settings'),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  DELIVERY DASHBOARD
// ═════════════════════════════════════════════════════════════
class DeliveryDashboard extends StatelessWidget {
  const DeliveryDashboard({super.key});
  static const _nav = [
    NavItem(Icons.home_rounded, 'Home', Color(0xFF0B3B66)),
    NavItem(
      Icons.account_balance_wallet_rounded,
      'Earnings',
      Color(0xFF27AE60),
    ),
    NavItem(Icons.chat_bubble_outline, 'Feedback', Color(0xFF8E44AD)),
  ];
  @override
  Widget build(BuildContext context) => DashboardShell(
    appBarTitle: 'Delivery Panel',
    navItems: _nav,
    bottomNavCount: 3,
    profile: agentProfile,
    pages: [
      const DeliveryHomePage(),
      const DeliveryEarningsPage(),
      const FeedbackPage(),
    ],
  );
}

// ─── Helpers ───────────────────────────────────────────────────
Widget placeholder(String emoji, String label) => Center(
  child: Padding(
    padding: const EdgeInsets.all(60),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kNavy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Coming soon',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    ),
  ),
);
