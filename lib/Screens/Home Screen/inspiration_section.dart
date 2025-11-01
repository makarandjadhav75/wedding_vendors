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
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sample.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final s = sample[i];
              return Container(
                width: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(image: NetworkImage(s['image']!), fit: BoxFit.cover),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 10, offset: const Offset(0, 6))],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Colors.black54, Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(.9), borderRadius: BorderRadius.circular(10)),
                        child: const Text('Featured', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 10,
                      child: Text(
                        s['title']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
