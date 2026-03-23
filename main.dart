import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app_colors.dart';
import 'screens/role_selection_screen.dart';
import 'screens/choose_role_login.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboards.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PetWellApp());
}

class PetWellApp extends StatelessWidget {
  const PetWellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetWell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: kNavy),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/':                   (ctx) => const RoleSelectionScreen(),
        '/choose-login':       (ctx) => const ChooseRoleLogin(),
        '/register':           (ctx) => const RegisterScreen(),
        '/owner-login':        (ctx) => const LoginScreen(role: 'Pet Owner'),
        '/delivery-login':     (ctx) => const LoginScreen(role: 'Delivery Agent'),
        '/owner-dashboard':    (ctx) => const OwnerDashboard(),
        '/delivery-dashboard': (ctx) => const DeliveryDashboard(),
      },
    );
  }
}
