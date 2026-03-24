import 'package:flutter/material.dart';
import '../app_colors.dart';

class RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const RoleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kNavy, kSky]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kNavy.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    ),
  );
}
