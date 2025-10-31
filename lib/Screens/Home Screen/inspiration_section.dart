// lib/screens/home/components/inspiration_section.dart
import 'package:flutter/material.dart';

class InspirationSection extends StatelessWidget {
  const InspirationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sample = [
      {'title': 'Top wedding trends 2025', 'image': 'https://images.unsplash.com/photo-1519677100203-a0e668c92439?auto=format&fit=crop&w=800&q=60'},
      {'title': 'Decoration ideas', 'image': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=800&q=60'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Inspiration & Blogs', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sample.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final s = sample[i];
              return Container(
                width: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: NetworkImage(s['image']!), fit: BoxFit.cover),
                ),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(colors: [Colors.black26, Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.bottomLeft,
                  child: Text(s['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
