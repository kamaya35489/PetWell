import 'package:flutter/material.dart';

class UserProfile {
  String name, contact, email, role;
  String? avatarEmoji;
  List<Map<String, String>> pets;
  UserProfile({
    required this.name,
    required this.contact,
    required this.email,
    required this.role,
    this.avatarEmoji,
    required this.pets,
  });
}

final agentProfile = UserProfile(
  name: 'Saman Fernando',
  contact: '0712345678',
  email: 'saman@petwell.lk',
  role: 'Delivery Agent',
  avatarEmoji: '🧑‍💼',
  pets: [],
);
