import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';
import '../widgets/dashboard_shell.dart';

class OwnerFeedbackPage extends StatefulWidget {
  const OwnerFeedbackPage({super.key});
  @override
  State<OwnerFeedbackPage> createState() => _OwnerFeedbackPageState();
}

class _OwnerFeedbackPageState extends State<OwnerFeedbackPage> {
  final _ctrl = TextEditingController();
  int _stars = 0;
  bool _submitted = false;
  final List<Map<String, dynamic>> _mine = [];
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0 || _ctrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a rating and comment.')),
      );
      return;
    }
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final fbSnap = await FirebaseFirestore.instance
          .collection('feedback')
          .get();
      final fbCount = fbSnap.size + 1;
      final fbID = 'feedback${fbCount.toString().padLeft(3, '0')}';
      await FirebaseFirestore.instance.collection('feedback').doc(fbID).set({
        'feedbackID': fbID,
        'userID': uid,
        'rating': _stars,
        'comment': _ctrl.text.trim(),
        'date': DateTime.now().toIso8601String(),
        'status': 'submitted',
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      return;
    }
    setState(() {
      _mine.insert(0, {
        'stars': _stars,
        'comment': _ctrl.text.trim(),
        'date': 'Just now',
      });
      _stars = 0;
      _ctrl.clear();
      _submitted = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _submitted = false);
    });
  }

  @override
  Widget build(BuildContext context) => dashBody(
    title: 'My Feedback',
    sub: 'Rate your experience with PetWell',
    content: Column(
      children: [
        SectionCard(
          title: 'Leave a Review',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Rating',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kNavy,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => setState(() => _stars = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        i < _stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 34,
                        color: i < _stars
                            ? const Color(0xFFF5A623)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Comment',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kNavy,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ctrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  contentPadding: const EdgeInsets.all(14),
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
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _submitted ? kGreen : kNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: _submit,
                  icon: Icon(
                    _submitted
                        ? Icons.check_circle_rounded
                        : Icons.send_rounded,
                    size: 18,
                  ),
                  label: Text(_submitted ? 'Submitted!' : 'Submit Feedback'),
                ),
              ),
            ],
          ),
        ),
        if (_mine.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionCard(
            title: 'My Reviews',
            child: Column(
              children: _mine
                  .asMap()
                  .entries
                  .map(
                    (e) => Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: kSky.withOpacity(0.15),
                              child: const Icon(
                                Icons.person_rounded,
                                color: kSky,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < e.value['stars']
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            size: 13,
                                            color: i < e.value['stars']
                                                ? const Color(0xFFF5A623)
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        e.value['date'],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    e.value['comment'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (e.key < _mine.length - 1) const Divider(height: 18),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    ),
  );
}
