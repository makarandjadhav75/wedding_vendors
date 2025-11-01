// lib/screens/home/components/category_tile.dart
import 'package:flutter/material.dart';
import '../../../Models/categery_model.dart';

class CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryTile({Key? key, required this.category, this.onTap}) : super(key: key);

  Widget _categoryPlaceholder() {
    return Container(
      color: Colors.pink.shade50,
      child: const Center(child: Icon(Icons.photo, color: Colors.pink, size: 36)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.pinkAccent.withOpacity(.08)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Positioned.fill(
                child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                    ? Image.network(
                        category.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _categoryPlaceholder(),
                      )
                    : _categoryPlaceholder(),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black45],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name.replaceAll('_', ' '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(.85), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
