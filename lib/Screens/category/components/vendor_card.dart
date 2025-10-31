// lib/screens/category/components/vendor_card.dart
import 'package:flutter/material.dart';
import '../../../Models/vendor_model.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback? onBook;
  final VoidCallback? onTap;

  const VendorCard({Key? key, required this.vendor, this.onBook, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: vendor.imageUrl != null && vendor.imageUrl!.isNotEmpty
                  ? Image.network(vendor.imageUrl!, width: 110, height: 110, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Expanded(child: Text(vendor.ownerFullName, style: const TextStyle(fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [const Icon(Icons.star, size: 14, color: Colors.green), const SizedBox(width: 4), Text((vendor.ratingAvg ?? 0).toStringAsFixed(1), style: const TextStyle(fontSize: 12))]),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Text(vendor.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(vendor.gstNumber != null ? '\u20B9${vendor.gstNumber!.toString()}' : 'Contact', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: onBook,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Book'),
                    )
                  ],
                )
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(width: 110, height: 110, color: Colors.pink.shade50, child: const Icon(Icons.person, color: Colors.pink, size: 40));
  }
}
