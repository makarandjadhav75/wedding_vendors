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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                    ? Image.network(category.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _categoryPlaceholder())
                    : _categoryPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(category.name.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
