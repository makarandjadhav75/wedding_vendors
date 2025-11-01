import 'package:flutter/material.dart';

class ReviewSection extends StatelessWidget {
  const ReviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {
        'icon': Icons.location_on_outlined,
        'color': const Color(0xFFDFF6F5),
        'title': '2.8 Lakh+ trusted vendors across 40+ cities',
      },
      {
        'icon': Icons.favorite_outline,
        'color': const Color(0xFFEDE8FF),
        'title': '2.3 million connections with 60K+ vendors',
      },
      {
        'icon': Icons.emoji_emotions_outlined,
        'color': const Color(0xFFE7F0FF),
        'title': '20 Lakh+ and counting happy customers',
      },
      {
        'icon': Icons.verified_outlined,
        'color': const Color(0xFFFFF3E0),
        'title': 'Choose best vendors based on user reviews',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            "Why WeddingBazaar?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final item = data[i];
              return _WhyCard(
                icon: item['icon'] as IconData,
                color: item['color'] as Color,
                title: item['title'] as String,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WhyCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const _WhyCard({
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pinkAccent.withOpacity(.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [color, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white),
            ),
            child: Icon(icon, color: Colors.black54),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
