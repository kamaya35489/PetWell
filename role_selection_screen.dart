import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/petwell_logo.dart';
import '../widgets/role_button.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PetWellLogo(),
            const SizedBox(height: 40),
            RoleButton(
              icon: Icons.login_rounded,
              label: "Sign In",
              onTap: () => Navigator.pushNamed(context, '/choose-login'),
            ),
            const SizedBox(height: 16),
            RoleButton(
              icon: Icons.person_add_alt_1_rounded,
              label: "Sign Up",
              onTap: () => Navigator.pushNamed(context, '/register'),
            ),
          ],
        ),
      ),
    ),
  );
}
