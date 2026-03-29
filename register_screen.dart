import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      final uid = cred.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'userID': uid,
        'userName': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'role': 'petOwner',
      });
      final snap = await FirebaseFirestore.instance
          .collection('petOwners')
          .get();
      final count = snap.size + 1;
      final newID = 'owner${count.toString().padLeft(3, '0')}';

      await FirebaseFirestore.instance.collection('petOwners').doc(newID).set({
        'ownerID': newID,
        'userID': uid,
        'address': '',
        'petIDs': [],
      });
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/owner-dashboard',
        (_) => false,
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(backgroundColor: Colors.transparent),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create Account",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kNavy,
            ),
          ),
          const Text(
            "Join the PetWell community today",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          _buildRegField(_nameCtrl, 'Full Name', Icons.person_outline),
          const SizedBox(height: 18),
          _buildRegField(
            _phoneCtrl,
            'Phone Number',
            Icons.phone_outlined,
            kb: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          _buildRegField(
            _emailCtrl,
            'Email Address',
            Icons.email_outlined,
            kb: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          _buildRegField(
            _passCtrl,
            'Password',
            Icons.lock_outline,
            isPass: true,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Create Account",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildRegField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isPass = false,
    TextInputType kb = TextInputType.text,
  }) => TextField(
    controller: ctrl,
    obscureText: isPass,
    keyboardType: kb,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kNavy),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

