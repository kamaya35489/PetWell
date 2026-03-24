import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/role_button.dart';

class ChooseRoleLogin extends StatelessWidget {
  const ChooseRoleLogin({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: kNavy),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Sign In",
        style: TextStyle(color: kNavy, fontWeight: FontWeight.bold),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleButton(
            icon: Icons.pets_rounded,
            label: "Pet Owner",
            onTap: () => Navigator.pushNamed(context, '/owner-login'),
          ),
          const SizedBox(height: 16),
          RoleButton(
            icon: Icons.delivery_dining_rounded,
            label: "Delivery Agent",
            onTap: () => Navigator.pushNamed(context, '/delivery-login'),
          ),
        ],
      ),
    ),
  );
}
