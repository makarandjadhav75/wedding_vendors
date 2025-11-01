// lib/screens/home/components/hero_section.dart
import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  final void Function(String) onSearchSubmitted;
  final VoidCallback onFindVendors;

  const HeroSection({Key? key, required this.onSearchSubmitted, required this.onFindVendors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1400&q=60'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(.55), Colors.black.withOpacity(.15)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.pinkAccent),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text('Wedding', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600)),
                ],
              ),
              const Spacer(),
              const Text('Plan the perfect day', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Discover curated vendors, ideas and more', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      elevation: 0,
                      borderRadius: BorderRadius.circular(10),
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search vendors, venues, photographers',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        ),
                        onSubmitted: onSearchSubmitted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: onFindVendors,
                    icon: const Icon(Icons.bolt),
                    label: const Text('Find'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF5370),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
