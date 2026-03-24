import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/dashboard_shell.dart';

class DeliveryEarningsPage extends StatelessWidget {
  const DeliveryEarningsPage({super.key});
  static const _dailyEarnings = [
    {
      'date': 'Mon, 12 Feb',
      'deliveries': 5,
      'amount': 'Rs. 2,500',
      'items': 'Dog Food, Cat Toy, Shampoo, Collar, Bird Seed',
    },
    {
      'date': 'Tue, 13 Feb',
      'deliveries': 3,
      'amount': 'Rs. 1,500',
      'items': 'Premium Dog Food, Pet Shampoo, Rabbit Hutch',
    },
    {
      'date': 'Wed, 14 Feb',
      'deliveries': 6,
      'amount': 'Rs. 3,000',
      'items': 'Cat Toy Bundle, Dog Food x2, Shampoo, Collar x2',
    },
    {
      'date': 'Thu, 15 Feb',
      'deliveries': 4,
      'amount': 'Rs. 2,000',
      'items': 'Bird Seed Mix, Dog Collar, Pet Shampoo, Cat Toy',
    },
    {
      'date': 'Fri, 16 Feb',
      'deliveries': 7,
      'amount': 'Rs. 3,500',
      'items': 'Premium Dog Food x3, Cat Toy x2, Collar, Shampoo',
    },
    {
      'date': 'Sat, 17 Feb',
      'deliveries': 5,
      'amount': 'Rs. 2,500',
      'items': 'Rabbit Hutch, Dog Food, Cat Toy, Collar, Shampoo',
    },
    {
      'date': 'Sun, 18 Feb',
      'deliveries': 4,
      'amount': 'Rs. 2,000',
      'items': 'Bird Seed Mix x2, Premium Dog Food, Pet Shampoo',
    },
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earnings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: kNavy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your revenue summary for February 2026',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kNavy, kSky],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: kNavy.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Total Revenue – February',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Rs. 17,000',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '34 Deliveries',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '↑ 12% vs last month',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            StatCard(number: '34', label: 'Total Deliveries', color: kNavy),
            SizedBox(width: 12),
            StatCard(number: '4.9', label: 'Avg/Day', color: kSky),
            SizedBox(width: 12),
            StatCard(
              number: 'Rs.500',
              label: 'Avg per Delivery',
              color: kOrange,
            ),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Daily Breakdown',
          child: Column(
            children: _dailyEarnings.asMap().entries.map((e) {
              final day = e.value;
              return Column(
                children: [
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(
                        left: 8,
                        bottom: 8,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: kSky.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${day['deliveries']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: kSky,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        day['date'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '${day['deliveries']} deliveries',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      trailing: Text(
                        day['amount'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kGreen,
                        ),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 14,
                                color: kNavy,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  day['items'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (e.key < _dailyEarnings.length - 1)
                    const Divider(height: 2),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}
