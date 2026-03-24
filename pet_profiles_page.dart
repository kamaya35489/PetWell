import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';
import '../widgets/dashboard_shell.dart';

class PetProfilesPage extends StatefulWidget {
  const PetProfilesPage({super.key});
  @override
  State<PetProfilesPage> createState() => _PetProfilesPageState();
}

class _PetProfilesPageState extends State<PetProfilesPage> {
  final List<Map<String, String>> _pets = [];
  void _showSheet([Map<String, String>? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PetFormSheet(
        existing: existing,
        onSave: (pet) => setState(() {
          if (existing != null) {
            final i = _pets.indexOf(existing);
            _pets[i] = pet;
          } else
            _pets.add(pet);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => dashBody(
    title: 'Pet Profiles',
    sub: 'Manage your registered pets.',
    content: Column(
      children: [
        Row(
          children: [
            StatCard(number: '${_pets.length}', label: 'My Pets'),
            const SizedBox(width: 12),
            StatCard(
              number:
                  '${_pets.map((p) => p['type']).where((s) => s != null && s!.isNotEmpty).toSet().length}',
              label: 'Species',
              color: kSky,
            ),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'My Pets',
          child: Column(
            children: [
              ..._pets.asMap().entries.map(
                (e) => Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showSheet(e.value),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: kNavy.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                e.value['emoji']!,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.value['name']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${e.value['type']} · ${e.value['breed']} · ${e.value['age']} yrs',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    if (e.key < _pets.length - 1) const Divider(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kNavy,
                    side: const BorderSide(color: kNavy, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showSheet(),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: const Text(
                    'Add New Pet',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PetFormSheet extends StatefulWidget {
  final Map<String, String>? existing;
  final void Function(Map<String, String>) onSave;
  const _PetFormSheet({this.existing, required this.onSave});
  @override
  State<_PetFormSheet> createState() => _PetFormSheetState();
}

class _PetFormSheetState extends State<_PetFormSheet> {
  late final TextEditingController _name,
      _breed,
      _age,
      _owner,
      _address,
      _contact,
      _allergies,
      _medical;
  String _type = 'Dog';
  final _types = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  final _emojis = {
    'Dog': '🐶',
    'Cat': '🐱',
    'Bird': '🦜',
    'Rabbit': '🐰',
    'Other': '🐾',
  };

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?['name'] ?? '');
    _breed = TextEditingController(text: e?['breed'] ?? '');
    _age = TextEditingController(text: e?['age'] ?? '');
    _owner = TextEditingController(text: e?['owner'] ?? '');
    _address = TextEditingController(text: e?['address'] ?? '');
    _contact = TextEditingController(text: e?['contact'] ?? '');
    _allergies = TextEditingController(text: e?['allergies'] ?? '');
    _medical = TextEditingController(text: e?['medical'] ?? '');
    _type = e?['type'] ?? 'Dog';
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _breed,
      _age,
      _owner,
      _address,
      _contact,
      _allergies,
      _medical,
    ])
      c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pet name required')));
      return;
    }
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final petSnap = await FirebaseFirestore.instance.collection('pets').get();
      final petCount = petSnap.size + 1;
      final petID = 'pet${petCount.toString().padLeft(3, '0')}';
      final petRef = FirebaseFirestore.instance.collection('pets').doc(petID);
      await petRef.set({
        'petID': petID,
        'ownerID': uid,
        'name': _name.text.trim(),
        'type': _type,
        'breed': _breed.text.trim().isEmpty ? 'Unknown' : _breed.text.trim(),
        'age': _age.text.trim().isEmpty ? '?' : _age.text.trim(),
        'emoji': _emojis[_type]!,
        'owner': _owner.text.trim(),
        'address': _address.text.trim(),
        'contact': _contact.text.trim(),
        'allergies': _allergies.text.trim(),
        'medical': _medical.text.trim(),
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving pet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      return;
    }
    widget.onSave({
      'name': _name.text.trim(),
      'type': _type,
      'breed': _breed.text.trim().isEmpty ? 'Unknown' : _breed.text.trim(),
      'age': _age.text.trim().isEmpty ? '?' : _age.text.trim(),
      'emoji': _emojis[_type]!,
      'owner': _owner.text.trim(),
      'address': _address.text.trim(),
      'contact': _contact.text.trim(),
      'allergies': _allergies.text.trim(),
      'medical': _medical.text.trim(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  widget.existing == null ? 'Add New Pet' : 'Edit Pet',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kNavy,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Pet Type',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _types.map((t) {
                  final sel = t == _type;
                  return GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? kNavy : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _emojis[t]!,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            _tf(
              ctrl: _name,
              label: 'Pet Name *',
              hint: 'e.g. Bruno',
              icon: Icons.pets,
            ),
            _tf(
              ctrl: _breed,
              label: 'Breed',
              hint: 'e.g. Labrador',
              icon: Icons.category_outlined,
            ),
            _tf(
              ctrl: _age,
              label: 'Age (years)',
              hint: 'e.g. 3',
              icon: Icons.cake_outlined,
              kb: TextInputType.number,
            ),
            _tf(
              ctrl: _owner,
              label: 'Owner Name',
              hint: 'e.g. Kamal Perera',
              icon: Icons.person_outline,
            ),
            _tf(
              ctrl: _address,
              label: 'Address',
              hint: 'e.g. 12 Palm St',
              icon: Icons.location_on_outlined,
            ),
            _tf(
              ctrl: _contact,
              label: 'Contact Number',
              hint: 'e.g. 0771234567',
              icon: Icons.phone_outlined,
              kb: TextInputType.phone,
            ),
            _tf(
              ctrl: _allergies,
              label: 'Allergies',
              hint: 'e.g. Pollen, None',
              icon: Icons.warning_amber_outlined,
            ),
            _tf(
              ctrl: _medical,
              label: 'Medical History / Special Concerns',
              hint: 'e.g. Vaccinated',
              icon: Icons.medical_information_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _save,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text(
                  'Save Pet',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _tf({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType kb = TextInputType.text,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kNavy,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: kb,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: Colors.grey.shade500, size: 20)
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kNavy, width: 1.8),
            ),
          ),
        ),
      ],
    ),
  );
}
