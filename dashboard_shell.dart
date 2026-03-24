import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../models/user_profile.dart';
import '../screens/profile_page.dart';
import '../widgets/petwell_logo.dart';
import '../widgets/profile_menu_button.dart';

class NavItem {
  final IconData icon;
  final String label;
  final Color color;
  const NavItem(this.icon, this.label, this.color);
}

class ColorfulNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int selected;
  final ValueChanged<int> onTap;
  const ColorfulNavBar({
    required this.items,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    child: SafeArea(
      top: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final isSelected = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 46 : 36,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item.color.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          item.icon,
                          size: isSelected ? 22 : 20,
                          color: isSelected ? item.color : Colors.grey.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? item.color : Colors.grey.shade400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 16 : 0,
                      height: isSelected ? 3 : 0,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}

class DashboardShell extends StatefulWidget {
  final List<NavItem> navItems;
  final List<Widget> pages;
  final String appBarTitle;
  final int bottomNavCount;
  final UserProfile profile;
  const DashboardShell({
    required this.navItems,
    required this.pages,
    required this.appBarTitle,
    this.bottomNavCount = 6,
    required this.profile,
  });
  @override
  State<DashboardShell> createState() => DashboardShellState();
}

class DashboardShellState extends State<DashboardShell> {
  int idx = 0;
  void _logout() =>
      Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final bottomItems = widget.navItems.take(widget.bottomNavCount).toList();
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const PetWellLogo(
          imageSize: 28,
          fontSize: 18,
          textColor: Colors.white,
        ),
        actions: [
          ProfileMenuButton(profile: widget.profile, onLogout: _logout),
        ],
      ),
      body: Row(
        children: [
          if (isWide)
            Sidebar(
              navItems: widget.navItems,
              selected: idx,
              onSelect: (i) => setState(() => idx = i),
              onLogout: _logout,
            ),
          Expanded(child: widget.pages[idx.clamp(0, widget.pages.length - 1)]),
        ],
      ),
      bottomNavigationBar: !isWide
          ? ColorfulNavBar(
              items: bottomItems,
              selected: idx.clamp(0, bottomItems.length - 1),
              onTap: (i) => setState(() => idx = i),
            )
          : null,
    );
  }
}

class Sidebar extends StatelessWidget {
  final List<NavItem> navItems;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  const Sidebar({
    required this.navItems,
    required this.selected,
    required this.onSelect,
    required this.onLogout,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: 210,
    color: kNavy,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        ...navItems.asMap().entries.map((e) {
          final sel = e.key == selected;
          return InkWell(
            onTap: () => onSelect(e.key),
            child: Container(
              color: sel ? Colors.white.withOpacity(0.12) : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Icon(e.value.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    e.value.label,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: const Text('Logout'),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── Shared UI ─────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String number, label;
  final Color color;
  const StatCard({
    required this.number,
    required this.label,
    this.color = kNavy,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: kNavy,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

Widget dashBody({
  required String title,
  required String sub,
  required Widget content,
}) => SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: kNavy,
        ),
      ),
      const SizedBox(height: 4),
      Text(sub, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      const SizedBox(height: 20),
      content,
    ],
  ),
);
