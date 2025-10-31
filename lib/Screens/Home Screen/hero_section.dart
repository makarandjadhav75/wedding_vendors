// lib/screens/home/components/hero_section.dart
import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  final void Function(String) onSearchSubmitted;
  final VoidCallback onFindVendors;

  const HeroSection({Key? key, required this.onSearchSubmitted, required this.onFindVendors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF1F3), Color(0xFFFFF7F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1400&q=60'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text('Welcome ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Find vendors, manage your services, and grow your business', style: TextStyle(color: Colors.white70)),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(8),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search services or cities (e.g., Catering, Mumbai)',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      ),
                      onSubmitted: onSearchSubmitted,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onFindVendors,
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
                  child: const Text('Find vendors'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
