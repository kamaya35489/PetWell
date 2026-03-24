import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/petwell_logo.dart';
import '../widgets/dashboard_shell.dart';

class OwnerHomePage extends StatelessWidget {
  final String userName;
  const OwnerHomePage({super.key, this.userName = ''});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (ctx, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const PetWellLogo(imageSize: 44, fontSize: 24),
              const SizedBox(height: 6),
              Text(
                'Welcome back, ${userName.split(' ').first}!',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 28),
              _HomeCard(
                emoji: '📅',
                title: 'Book Appointment',
                sub: 'Choose a date, time slot & pay',
                color: kSky,
                navIdx: 2,
              ),
              const SizedBox(height: 12),
              _HomeCard(
                emoji: '🐾',
                title: 'Add Pet Profile',
                sub: 'Register your pet',
                color: kOrange,
                navIdx: 1,
              ),
              const SizedBox(height: 12),
              _HomeCard(
                emoji: '💬',
                title: 'Feedback',
                sub: 'Rate your experience',
                color: kGreen,
                navIdx: 4,
              ),
              const SizedBox(height: 12),
              _HomeCard(
                emoji: '🚚',
                title: 'My Deliveries',
                sub: 'Track your orders',
                color: kPurple,
                navIdx: 3,
              ),
              const SizedBox(height: 12),
              _HomeCard(
                emoji: '🛍',
                title: 'Store',
                sub: 'Browse pet products',
                color: kNavy,
                navIdx: 5,
              ),
              const SizedBox(height: 28),
              _HomeCard(
                emoji: '📹',
                title: 'CCTV Live Stream',
                sub: 'Monitor your pet live',
                color: kTeal,
                navIdx: 6,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ),
  );
}

class _HomeCard extends StatelessWidget {
  final String emoji, title, sub;
  final Color color;
  final int navIdx;
  const _HomeCard({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.color,
    required this.navIdx,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    child: Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          final s = context.findAncestorStateOfType<DashboardShellState>();
          s?.setState(() => s.idx = navIdx);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 15, color: color),
            ],
          ),
        ),
      ),
    ),
  );
}
