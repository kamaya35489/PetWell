import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/dashboard_shell.dart';

class _Review {
  final String name, comment;
  final int stars;
  const _Review(this.name, this.stars, this.comment);
}

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});
  static final _reviews = [
    _Review('Sarah L.', 5, 'Great service and friendly staff.'),
    _Review('John D.', 4, 'Good experience but delivery was late.'),
    _Review('Priya K.', 5, 'My pets love PetWell. Highly recommend!'),
    _Review('Amal S.', 3, 'Average service. Room for improvement.'),
  ];
  @override
  Widget build(BuildContext context) => dashBody(
    title: 'User Feedback',
    sub: 'Recent reviews & ratings',
    content: Column(
      children: [
        Row(
          children: const [
            StatCard(number: '4.2', label: 'Avg Rating', color: kOrange),
            SizedBox(width: 12),
            StatCard(number: '4', label: 'Reviews', color: kSky),
            SizedBox(width: 12),
            StatCard(number: '2', label: '5 ★ Reviews', color: kGreen),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Reviews',
          child: Column(
            children: _reviews
                .asMap()
                .entries
                .map(
                  (e) => Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: kNavy.withOpacity(0.1),
                            child: Text(
                              e.value.name[0],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: kNavy,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      e.value.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < e.value.stars
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          size: 13,
                                          color: i < e.value.stars
                                              ? const Color(0xFFF5A623)
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  e.value.comment,
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
                      if (e.key < _reviews.length - 1)
                        const Divider(height: 20),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
}
